package dv01_pkg;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  class dv01_observation extends uvm_sequence_item;
    int unsigned result;
    `uvm_object_utils_begin(dv01_observation)
      `uvm_field_int(result, UVM_DEFAULT)
    `uvm_object_utils_end
    function new(string name = "dv01_observation"); super.new(name); endfunction
  endclass
  class dv01_publisher extends uvm_component;
    `uvm_component_utils(dv01_publisher)
    uvm_analysis_port #(dv01_observation) observed_ap;
    function new(string name, uvm_component parent);
      super.new(name, parent); observed_ap = new("observed_ap", this);
    endfunction
    task run_phase(uvm_phase phase);
      dv01_observation observation;
      int unsigned values[2] = '{3, 7};
`ifdef DV01_REUSED_HANDLE_FAULT
      observation = dv01_observation::type_id::create("reused_observation");
`endif
      for (int unsigned index = 0; index < 2; index++) begin
`ifndef DV01_REUSED_HANDLE_FAULT
        observation = dv01_observation::type_id::create($sformatf("observation_%0d", index));
`endif
        observation.result = values[index];
        `uvm_info("DV01_PUBLISH", $sformatf("index=%0d result=%0d handle=%0d",
                  index, observation.result, observation.get_inst_id()), UVM_LOW)
        observed_ap.write(observation);
      end
    endtask
  endclass
  class dv01_scoreboard extends uvm_component;
    `uvm_component_utils(dv01_scoreboard)
    uvm_tlm_analysis_fifo #(dv01_observation) observed_fifo;
    int unsigned checked, mismatches;
    function new(string name, uvm_component parent);
      super.new(name, parent); observed_fifo = new("observed_fifo", this);
    endfunction
    task run_phase(uvm_phase phase);
      dv01_observation observation;
      int unsigned expected[2] = '{3, 7};
      for (int unsigned index = 0; index < 2; index++) begin
        observed_fifo.get(observation);
        `uvm_info("DV01_CHECK", $sformatf("index=%0d expected=%0d observed=%0d handle=%0d",
                  index, expected[index], observation.result, observation.get_inst_id()), UVM_LOW)
        checked++;
        if (observation.result != expected[index]) begin
          mismatches++;
          `uvm_error("DV01_MISMATCH", $sformatf("index=%0d expected=%0d observed=%0d",
                     index, expected[index], observation.result))
        end
      end
    endtask
  endclass
  class dv01_env extends uvm_env;
    `uvm_component_utils(dv01_env)
    dv01_publisher publisher; dv01_scoreboard scoreboard;
    function new(string name, uvm_component parent); super.new(name, parent); endfunction
    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      publisher = dv01_publisher::type_id::create("publisher", this);
      scoreboard = dv01_scoreboard::type_id::create("scoreboard", this);
    endfunction
    function void connect_phase(uvm_phase phase);
      super.connect_phase(phase);
      publisher.observed_ap.connect(scoreboard.observed_fifo.analysis_export);
    endfunction
  endclass
  class dv01_test extends uvm_test;
    `uvm_component_utils(dv01_test)
    dv01_env env;
    function new(string name, uvm_component parent); super.new(name, parent); endfunction
    function void build_phase(uvm_phase phase);
      super.build_phase(phase); env = dv01_env::type_id::create("env", this);
    endfunction
    task run_phase(uvm_phase phase);
      phase.raise_objection(this);
      wait (env.scoreboard.checked == 2); #1ns;
      if (env.scoreboard.mismatches != 0)
        `uvm_error("DV01_RESULT", $sformatf("checked=%0d mismatches=%0d",
                   env.scoreboard.checked, env.scoreboard.mismatches))
      else begin
        `uvm_info("DV01_PASS", "checked=2 mismatches=0", UVM_NONE)
        $display("TEST_RESULT: PASS");
      end
      phase.drop_objection(this);
    endtask
  endclass
endpackage
