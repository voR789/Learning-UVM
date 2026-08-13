
  // Coverage
  class tcs_coverage extends uvm_component;  // Centralize and sync observations for coverage
    `uvm_component_utils(tcs_coverage)

    uvm_analysis_imp_cmd #(cmd_obs, tcs_coverage) cmd_imp; // Define port type as well as where the implementation lives
    uvm_analysis_imp_rsp #(rsp_obs, tcs_coverage) rsp_imp;
    uvm_analysis_imp_rst #(rst_obs, tcs_coverage) rst_imp; // Use to manage local state, not for coverage

    bit recovery_pending;
    cmd_obs pending_cmd[$];

    covergroup cmd_cg with function sample (
        // command observation
        bit [1:0] op,
        bit [7:0] a,
        bit [7:0] b,
        // corresponding response observation
        bit [1:0] status,

        // Special coverage flags
        bit stalled,
        bit multi_outstanding,
        bit reset_recovery
    );
      op_cp: coverpoint op {
        bins w_add = {0}; bins xor_op = {1}; bins s_add = {2}; bins invalid_op = {3};
      }
      status_cp: coverpoint status {
        bins normal = {0}; bins saturation = {1}; bins unsupported = {2};
      }

      overflow_cp: coverpoint ({1'b0,a} + {1'b0,b}) iff (op == 2'd0 || op == 2'd2) {
        bins no_overflow = {[0 : 255]}; bins overflow = {[256 : 510]};
      }

      stalled_cp: coverpoint stalled {bins seen = {1};}

      multi_outstanding_cp: coverpoint multi_outstanding {bins seen = {1};}

      reset_recovery_cp: coverpoint reset_recovery {bins seen = {1};}

      op_status_cx: cross op_cp, status_cp{
        bins w_add_status = binsof (op_cp.w_add) && binsof (status_cp.normal);
        bins xor_status = binsof (op_cp.xor_op) && binsof (status_cp.normal);
        bins s_add_status = binsof (op_cp.s_add) && binsof (status_cp.normal);
        bins s_add_status_sat = binsof (op_cp.s_add) && binsof (status_cp.saturation);
        bins invalid_op_status = binsof (op_cp.invalid_op) && binsof (status_cp.unsupported);

        ignore_bins w_add_saturation = binsof (op_cp.w_add) && binsof (status_cp.saturation);
        ignore_bins w_add_unsupported = binsof (op_cp.w_add) && binsof (status_cp.unsupported);
        ignore_bins xor_saturation = binsof (op_cp.xor_op) && binsof (status_cp.saturation);
        ignore_bins xor_unsupported = binsof (op_cp.xor_op) && binsof (status_cp.unsupported);
        ignore_bins s_add_unsupported = binsof (op_cp.s_add) && binsof (status_cp.unsupported);
        ignore_bins invalid_normal = binsof (op_cp.invalid_op) && binsof (status_cp.normal);
        ignore_bins invalid_saturation = binsof (op_cp.invalid_op) && binsof (status_cp.saturation);
      }

      op_overflow_cx: cross op_cp, overflow_cp{
        bins w_add = binsof (op_cp.w_add) && binsof (overflow_cp.no_overflow);
        bins w_add_overflow = binsof (op_cp.w_add) && binsof (overflow_cp.overflow);
        bins s_add = binsof (op_cp.s_add) && binsof (overflow_cp.no_overflow);
        bins s_add_overflow = binsof (op_cp.s_add) && binsof (overflow_cp.overflow);
      }
    endgroup

    function new(string name = "tcs_cmd_coverage", uvm_component parent = null);
      super.new(name, parent);
      cmd_cg  = new();
      cmd_imp = new("cmd_imp", this);
      rsp_imp = new("rsp_imp", this);
      rst_imp = new("rst_imp", this);
    endfunction

    function void write_cmd(cmd_obs t);
      // Add cmd obs to queue to sync with rsp later
      pending_cmd.push_back(t);
    endfunction

    function void write_rsp(rsp_obs t);
      // Take cmds from queue, and sample
      cmd_obs cmd;
      bit stalled;
      bit multi_outstanding;
      bit reset_recovery;

      stalled = t.stalled_obs;
      multi_outstanding = (pending_cmd.size() > 1); // If the size is larger than 1 before we pop...
      reset_recovery = recovery_pending;

      if (pending_cmd.size() == 0)
        `uvm_fatal("QUEUE_MISMATCH", "rsp written before cmd in coverage queue")

      cmd = pending_cmd.pop_front();

      if(recovery_pending)  // If we wrote after we reset on occupied, we have covered reset_recovery
        recovery_pending = 1'b0;

      cmd_cg.sample(cmd.cmd_op, cmd.cmd_a, cmd.cmd_b, t.rsp_status, stalled, multi_outstanding,
                    reset_recovery);
    endfunction

    function void write_rst(rst_obs t);
      // Start 2 step reset recovery flag, reset occupancy
      if (pending_cmd.size() > 0) recovery_pending = 1'b1;
      pending_cmd.delete();
    endfunction

  endclass


  // Predictor
  class tcs_model extends uvm_subscriber #(cmd_obs);
    `uvm_component_utils(tcs_model)

    // Send expected response to the scoreboard
    uvm_analysis_port #(rsp_obs) model_ap;

    function new(string name = "tcs_model", uvm_component parent = null);
      super.new(name, parent);
      model_ap = new("model_ap", this);
    endfunction

    function void write(cmd_obs t);
      rsp_obs expected;
      bit [7:0] result;
      bit [1:0] status;
      expected = rsp_obs::type_id::create();
      case (t.cmd_op)
        2'b00: begin
          result = t.cmd_a + t.cmd_b;
          status = 0;
        end
        2'b01: begin
          result = t.cmd_a ^ t.cmd_b;
          status = 0;
        end
        2'b10: begin
          if (9'(t.cmd_a) + 9'(t.cmd_b) > 255) begin
            result = 8'hFF;
            status = 1;
          end else begin
            result = t.cmd_a + t.cmd_b;
            status = 0;
          end
        end
        2'b11: begin
          result = '0;
          status = 2;
        end
      endcase
      expected.rsp_tag = t.cmd_tag;
      expected.rsp_data = result;
      expected.rsp_status = status;

      // Cycle calculation: rsp_cycle holds the minimum cycles for the op
      case (t.cmd_op)
        2'b00: begin
          expected.rsp_cycle = 1;
        end
        2'b01: begin
          expected.rsp_cycle = 2;
        end
        2'b10: begin
          expected.rsp_cycle = 3;
        end
        2'b11: begin
          expected.rsp_cycle = 1;
        end
      endcase
      model_ap.write(expected);
    endfunction
  endclass

  // Scoreboard
  class tcs_scoreboard extends uvm_component;
    `uvm_component_utils(tcs_scoreboard)
    int checked;
    int mismatches;
    // Monitor observations
    uvm_analysis_imp_cmd #(cmd_obs, tcs_scoreboard) cmd_imp;
    uvm_analysis_imp_rsp #(rsp_obs, tcs_scoreboard) rsp_imp;
    uvm_analysis_imp_rst #(rst_obs, tcs_scoreboard) rst_imp;

    // Predictor expected
    uvm_analysis_imp_exp #(rsp_obs, tcs_scoreboard) exp_imp;

    cmd_obs pending_cmd[$];
    rsp_obs pending_rsp[$];

    rsp_obs pending_exp[$];

    function new(string name, uvm_component parent);
      super.new(name, parent);
      cmd_imp = new("cmd_imp", this);
      rsp_imp = new("rsp_imp", this);
      rst_imp = new("rst_imp", this);
      exp_imp = new("exp_imp", this);
    endfunction

    function void write_cmd(cmd_obs t);
      pending_cmd.push_back(t);
    endfunction

    function void write_rsp(rsp_obs t);
      pending_rsp.push_back(t);
    endfunction

    function void write_rst(rst_obs t);
      // On reset, because predictor does not handle reset behavior, 
      // and only acts as a pure possible response channel, we have to clear outstanding expected responses + commands
      int outstanding = pending_cmd.size() - pending_rsp.size();
      for (int i = 0; i < outstanding; i++) begin
        pending_cmd.pop_back();
        pending_exp.pop_back();
      end
    endfunction

    function void write_exp(rsp_obs t);
      pending_exp.push_back(t);
    endfunction

    function void check_phase(uvm_phase phase);
      super.check_phase(phase);
      while (pending_exp.size() != 0 && pending_rsp.size() != 0 && pending_cmd.size() != 0) begin
        cmd_obs actual_cmd = pending_cmd.pop_front();
        rsp_obs actual_rsp = pending_rsp.pop_front();

        rsp_obs expected_rsp = pending_exp.pop_front();

        int actual_latency = actual_rsp.rsp_cycle - actual_cmd.acc_cycle;

        if (actual_rsp.rsp_tag != expected_rsp.rsp_tag) begin
          `uvm_error("TAG_MISMATCH", $sformatf("Expected rsp_tag= %0h, Actual rsp_tag= %0h",
                                               expected_rsp.rsp_tag, actual_rsp.rsp_tag))
          mismatches++;
        end
        if (actual_rsp.rsp_data != expected_rsp.rsp_data) begin
          `uvm_error("DATA_MISMATCH", $sformatf("Expected rsp_data= %0h, Actual rsp_data= %0h, cmd: %0s",
                                                expected_rsp.rsp_data, actual_rsp.rsp_data, actual_cmd.convert2string()))
          mismatches++;
        end
        if (actual_rsp.rsp_status != expected_rsp.rsp_status) begin
          `uvm_error("STATUS_MISMATCH", $sformatf(
                                            "Expected rsp_status= %0h, Actual rsp_status= %0h",
                                            expected_rsp.rsp_status, actual_rsp.rsp_status))
          mismatches++;
        end
        if (actual_latency < expected_rsp.rsp_cycle) begin
          `uvm_error("LATENCY_MISMATCH", $sformatf("Expected min latency= %0h, Actual latency= %0h",
                                                   expected_rsp.rsp_cycle, actual_latency))
          mismatches++;
        end
        checked++;
      end
      if (checked == 0) `uvm_error("NONE_CHECKED", "checked count is zero")
      $display("trace: Expected rsp queue size: %0d Actual rsp queue size: %0d, Actual cmd queue size: %0d", pending_exp.size(), pending_rsp.size(), pending_cmd.size());
      if (pending_exp.size() != 0 || pending_rsp.size() != 0 || pending_cmd.size() != 0) begin
        `uvm_error("QUEUE_MISMATCH", "One or more queues has outstanding items")
        mismatches++;
      end
    endfunction

    function void report_phase(uvm_phase phase);
      super.report_phase(phase);
      $display("=========================");
      $display("checked= %0d, mismatches= %0d", checked, mismatches);
      if(mismatches == 0) 
        $display("TEST_RESULT: PASS");
    endfunction
  endclass
