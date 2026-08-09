package dvc1_tb_pkg;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  // Describe how we want our driver to interpret our requests,
  // either hold it until accepted, pulse once, or probe not-valid
  // abstract packet behavior to make things way easier
  typedef enum logic[1:0] { 
    HOLD_ACCEPT, PULSE, IDLE 
  } DRIVE_POLICY;

  class cmd_req extends uvm_sequence_item;
    // Don't use logic because we would never want to req X or Z
    bit cmd_valid;
    bit [3:0] cmd_tag;
    bit [1:0] cmd_op;
    bit [7:0] cmd_a;
    bit [7:0] cmd_b;
    DRIVE_POLICY drive_mode;
    `uvm_object_utils(cmd_req)

    function new(string name = "cmd_req");
      super.new(name);
    endfunction

    function string convert2string();
      return $sformatf("cmd_valid=%0h cmd_tag=0x%0h cmd_op=0x%0h cmd_a=0x%0h cmd_b=%0h", cmd_valid, cmd_tag, cmd_op,
                       cmd_a, cmd_b);
    endfunction
  endclass

  class rsp_req extends uvm_sequence_item;
    // Don't use logic because we would never want to req X or Z
    bit rsp_ready;
    `uvm_object_utils(rsp_req)

    function new(string name = "rsp_req");
      super.new(name);
    endfunction

    function string convert2string();
      return $sformatf("rsp_ready=%0h", rsp_ready);
    endfunction
  endclass

  class rst_req extends uvm_sequence_item;
    bit rst_n;
    `uvm_object_utils(rst_req)

    function new(string name = "rst_req");
      super.new(name);
    endfunction

    function string convert2string();
      return $sformatf("rst_n=%0h", rst_n);
    endfunction
  endclass

  class cmd_obs extends uvm_object;
    bit cmd_valid;
    bit cmd_ready;
    bit [3:0] cmd_tag;
    bit [1:0] cmd_op;
    bit [7:0] cmd_a;
    bit [7:0] cmd_b;
    int acc_cycle;

    `uvm_object_utils(cmd_obs)
    function new(string name = "cmd_obs");
      super.new(name);
    endfunction

    function string convert2string();
      return $sformatf(
          "cmd_valid=%0h cmd_ready=%0h cmd_tag=0x%0h cmd_op=0x%0h cmd_a=0x%0h cmd_b=%0h acc_cycle=%0d",
          cmd_valid,
          cmd_ready,
          cmd_tag,
          cmd_op,
          cmd_a,
          cmd_b,
          acc_cycle
      );
    endfunction
  endclass

  class rsp_obs extends uvm_object;
    bit rsp_valid;
    bit rsp_ready;
    bit [3:0] rsp_tag;
    bit [1:0] rsp_status;
    bit [7:0] rsp_data;
    int rsp_cycle;

    `uvm_object_utils(rsp_obs)
    function new(string name = "rsp_obs");
      super.new(name);
    endfunction

    function string convert2string();
      return $sformatf(
          "rsp_valid=%0h rsp_ready=%0h rsp_tag=%0h rsp_status=%0h rsp_data=%0h rsp_cycle=%0d",
          rsp_valid,
          rsp_ready,
          rsp_tag,
          rsp_status,
          rsp_data,
          rsp_cycle
      );
    endfunction
  endclass

  class rst_obs extends uvm_object;
    bit rst_n;

    `uvm_object_utils(rst_obs)
    function new(string name = "rst_obs");
      super.new(name);
    endfunction

    function string convert2string();
      return $sformatf("rst_n=%0h", rst_n);
    endfunction
  endclass


  // cmd helper sequence
  class issue_cmd extends uvm_sequence #(cmd_req);
    bit cmd_valid;
    bit [3:0] cmd_tag;
    bit [1:0] cmd_op;
    bit [7:0] cmd_a;
    bit [7:0] cmd_b;
    DRIVE_POLICY drive_mode;

    `uvm_component_utils(issue_cmd);

    function new(string name = "issue_cmd");
      super.new(name);
    endfunction

    function configure(bit vld, bit [3:0] tag, bit [1:0] op, bit [7:0] a, bit [7:0] b, DRIVE_POLICY dm);
      cmd_valid = vld;
      cmd_tag = tag;
      cmd_op = op;
      cmd_a = a;
      cmd_b = b;
      drive_mode = dm;
    endfunction

    // Basic send command side request, with no response handling (handled in higher levels)
    task body();
      cmd_req req;
      req = cmd_req::type_id::create("cmd_req");
      start_item(req);
      req.cmd_valid = cmd_valid;
      req.cmd_tag = cmd_tag;
      req.cmd_op = cmd_op;
      req.cmd_a = cmd_a;
      req.cmd_b = cmd_b;
      req.drive_mode = drive_mode;
      finish_item(req);
    endtask
  endclass

  // always rsp ready sequence
  class rsp_always_ready extends uvm_sequence #(rsp_req);
    `uvm_component_utils(rsp_always_ready)

    function new(string name = "rsp_always_ready");
      super.new(name);
    endfunction

    task body();
      rsp_req req;
      req = rsp_req::type_id::create("rsp_req");
      start_item(req);
      rsp.rsp_ready = 1'b1;
      finish_item(req);

    endtask
  endclass

  // apply reset sequence
  class rst_apply_reset extends uvm_sequence #(rst_req);
    `uvm_component_utils(rst_apply_reset)

    function new(string name = "rst_apply_reset");
      super.new(name);
    endfunction

    task body();
      rst_req req;

      // Assert reset
      req = rsp_req::type_id::create("rst_req0");
      start_item(req);
      rsp.rst_n = 1'b0;
      finish_item(req);
      // Deassert reset
      req = rsp_req::type_id::create("rst_req1");
      start_item(req);
      rsp.rst_n = 1'b1;
      finish_item(req);
    endtask
  endclass

  // virtual smoke sequence
  class tcs_seq_smoke extends uvm_sequence;
    `uvm_object_utils(tcs_seq_smoke)
    `uvm_declare_p_sequencer(tcs_virtual_sequencer)

    function new(string name = "tcs_seq_smoke");
      super.new(name);
    endfunction

    task body();
      issue_cmd cmd_seq;
      rsp_always_ready rsp_seq;
      rst_apply_reset rst_seq;

      cmd_seq = issue_cmd::type_id::create();
      rsp_seq = rsp_always_ready::type_id::create();
      rst_seq = rst_apply_reset::type_id::create();

      rst_seq.start(p_sequencer.rst_sequencer);

      // Set sequence properties
      cmd_seq.configure(1'b1, 4'h1, 2'h0, 8'h1, 8'h2, HOLD_ACCEPT);  // Wrapping add, 1 + 2
      fork
        cmd_seq.start(p_sequencer.cmd_sequencer);
        rsp_seq.start(p_sequencer.rsp_sequencer);
      join

    endtask
  endclass

  // sequencers
  class tcs_cmd_sequencer extends uvm_sequencer #(cmd_req);
    `uvm_component_utils(tcs_cmd_sequencer)
    function new(string name = "tcs_cmd_sequencer");
      super.new(name);
    endfunction
  endclass

  class tcs_rsp_sequencer extends uvm_sequencer #(rsp_req);
    `uvm_component_utils(tcs_rsp_sequencer)
    function new(string name = "tcs_rsp_sequencer");
      super.new(name);
    endfunction
  endclass

  class tcs_rst_sequencer extends uvm_sequencer #(rst_req);
    `uvm_component_utils(tcs_rst_sequencer)
    function new(string name = "tcs_rst_sequencer");
      super.new(name);
    endfunction
  endclass

  class tcs_virtual_sequencer extends uvm_sequencer;
    `uvm_component_utils(tcs_virtual_sequencer)
    tcs_cmd_sequencer cmd_sequencer;
    tcs_rsp_sequencer rsp_sequencer;
    tcs_rst_sequencer rst_sequencer;

    cmd_sequencer = tcs_cmd_sequencer::type_id::create("cmd_sequencer");
    rsp_sequencer = tcs_rsp_sequencer::type_id::create("rsp_sequencer");
    rst_sequencer = tcs_rst_sequencer::type_id::create("rst_sequencer");

    function new(string name = "tcs_virtual_sequencer");
      super.new(name);
    endfunction
  endclass

  // Protocol indpendent drivers
  class tcs_cmd_driver extends uvm_driver #(cmd_req);
    `uvm_component_utils(tcs_cmd_driver)

    virtual tcs_if vif;

    function new(string name = "tcs_cmd_driver")
      super.new(name);
    endfunction

    function void build_phase(uvm_phase phase); // Phase handle is a reference to the UVM lifecycle phase, mainly used for objections 
      super.build_phase(phase);

      if(!uvm_config_db#(virtual tcs_if)::get(this, "", "vif", vif))
        `uvm_fatal("NO_VIF", "tcs_if was not configred!")
    endfunction

    task run_phase();
      cmd_req req;
      req = cmd_req::type_id::create("cmd_req");
      forever begin
        @(negedge clk);
        seq_item_port.get_next_item(req);
        vif.cmd_valid = req.cmd_valid;
        vif.cmd_tag = req.cmd_tag;
        vif.cmd_op = req.cmd_op;
        vif.cmd_a = req.cmd_a;
        vif.cmd_b = req.cmd_b;

        // Drive policy handles how we end driving transaction
        if(req.drive_mode == HOLD_ACCEPT) begin
          
        end else if() req.drive_mode == PULSE) begin
          
        end else if(req.drive_mode == IDLE) begin
          
        end
      end
    endtask
  endclass

  class tcs_rsp_driver extends uvm_driver #(rsp_req);
  endclass

  class tcs_rst_driver extends uvm_driver #(rst_req);
  endclass

  // Observation monitors
  class tcs_cmd_mon extends uvm_monitor;
  endclass

  class tcs_rsp_mon extends uvm_monitor;
  endclass

  class tcs_rst_mon extends uvm_monitor;
  endclass

  // Agents
  class tcs_cmd_agent extends uvm_agent;
  endclass

  class tcs_rsp_agent extends uvm_agent;
  endclass

  class tcs_rst_agent extends uvm_agent;
  endclass

  // Coverage
  class tcs_cmd_coverage extends uvm_subscriber #(cmd_obs);
  endclass

  class tcs_rsp_coverage extends uvm_subscriber #(rsp_obs);
  endclass

  // Predictor
  class tcs_model extends uvm_subscriber #(cmd_obs);
  endclass

  // Scoreboard
  class tcs_scoreboard extends uvm_component;
  endclass

  class tcs_env extends uvm_env;
  endclass

  class tcs_base_test extends uvm_test;
  endclass

  class tcs_smoke_test extends tcs_base_test;
  endclass
endpackage
