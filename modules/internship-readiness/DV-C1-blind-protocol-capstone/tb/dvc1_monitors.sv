  // Observation monitors
  class tcs_cmd_mon extends uvm_monitor;
    `uvm_component_utils(tcs_cmd_mon)

    virtual tcs_if vif;
    uvm_analysis_port #(cmd_obs) cmd_obs_ap;
    int counter;  // Count cycles for latency

    function new(string name = "tcs_cmd_mon", uvm_component parent = null);
      super.new(name, parent);
      cmd_obs_ap = new("cmd_obs_ap", this);  // Use normal constructor for simple, not reused port
      counter = 0;
    endfunction

    function void build_phase(uvm_phase phase);
      super.build_phase(phase);

      if (!uvm_config_db#(virtual tcs_if)::get(this, "", "vif", vif))
        `uvm_fatal("NO_VIF", "tcs_if is not configured")
    endfunction

    task run_phase(uvm_phase phase);
      cmd_obs obs;
      forever begin
        @(posedge vif.clk) counter++;
        if(vif.cmd_valid && vif.cmd_ready && vif.rst_n) begin // ONLY observe accepted transactions
          obs = cmd_obs::type_id::create();
          obs.cmd_tag = vif.cmd_tag;
          obs.cmd_op = vif.cmd_op;
          obs.cmd_a = vif.cmd_a;
          obs.cmd_b = vif.cmd_b;
          obs.acc_cycle = counter;
          cmd_obs_ap.write(obs);
        end
      end
    endtask
  endclass


  class tcs_rsp_mon extends uvm_monitor;
    `uvm_component_utils(tcs_rsp_mon)

    bit stalled_flag;
    bit [3:0] stalled_tag;
    bit [1:0] stalled_status;
    bit [7:0] stalled_data;

    virtual tcs_if vif;
    uvm_analysis_port #(rsp_obs) rsp_obs_ap;
    int counter;

    function new(string name = "tcs_rsp_mon", uvm_component parent = null);
      super.new(name, parent);
      rsp_obs_ap = new("rsp_obs_ap", this);
      counter = 0;
    endfunction

    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      if (!uvm_config_db#(virtual tcs_if)::get(this, "", "vif", vif))
        `uvm_fatal("NO_VIF", "tcs_if is not configured");
    endfunction

    task run_phase(uvm_phase phase);
      rsp_obs obs;
      forever begin
        @(posedge vif.clk);
        counter++;
        if (vif.rsp_ready && vif.rsp_valid && vif.rst_n) begin
          obs = rsp_obs::type_id::create();
          obs.rsp_tag = vif.rsp_tag;
          obs.rsp_status = vif.rsp_status;
          obs.rsp_data = vif.rsp_data;
          obs.rsp_cycle = counter;

          if (stalled_flag) begin  // Stalled flag for coverage
            obs.stalled_obs = 1'b1;
            stalled_flag = 1'b0;
          end else obs.stalled_obs = 1'b0;

          rsp_obs_ap.write(obs);
        end else if (!vif.rsp_ready && vif.rsp_valid && vif.rst_n) begin  // Stalled state
          if(stalled_flag) begin
            // if stalled for 1+ cycles, check data is stable
            if(stalled_tag != vif.rsp_tag || stalled_status != vif.rsp_status || stalled_data != vif.rsp_data)
              `uvm_error("STALL_ERROR", "stalled data is not stable (data fields)")
          end else begin
            // on first stalled cycle, latch data and set flag
            stalled_flag = 1'b1;
            stalled_tag = vif.rsp_tag;
            stalled_status = vif.rsp_status;
            stalled_data = vif.rsp_data;
          end
        end else if (!vif.rsp_valid && vif.rst_n) begin // DUT withdrew valid BEFORE a valid response came through
          if(stalled_flag) begin 
            `uvm_error("STALL_ERROR", "stalled data is not stable (rsp_valid)")
            stalled_flag = 1'b0; // Stall technically stopped so we continue operation
          end
        end 
        if (!vif.rst_n) begin
          stalled_flag = 1'b0;  // Clear stalled flag on reset
        end
      end
    endtask
  endclass

  class tcs_rst_mon extends uvm_monitor;
    `uvm_component_utils(tcs_rst_mon)

    virtual tcs_if vif;
    uvm_analysis_port #(rst_obs) rst_obs_ap;

    function new(string name = "tcs_rst_mon", uvm_component parent);
      super.new(name, parent);
      rst_obs_ap = new("rst_obs_ap", this);
    endfunction

    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      if (!uvm_config_db#(virtual tcs_if)::get(this, "", "vif", vif))
        `uvm_fatal("NO_VIF", "tcs_if is not configured")
    endfunction

    task run_phase(uvm_phase phase);
      rst_obs obs;
      forever begin
        @(posedge vif.clk);
        if (!vif.rst_n) begin
          obs = rst_obs::type_id::create();
          obs.reset = 1'b1;  // Observe reset occured
          rst_obs_ap.write(obs);
        end
      end
    endtask
  endclass
