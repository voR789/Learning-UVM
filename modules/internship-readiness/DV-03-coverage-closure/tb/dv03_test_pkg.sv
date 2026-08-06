package dv03_test_pkg;
  import uvm_pkg::*;
  import dv03_support_pkg::*;
  import dv03_target_pkg::*;
  `include "uvm_macros.svh"

  class dv03_test extends uvm_test;
    `uvm_component_utils(dv03_test)
    dv03_env env;
    function new(string name, uvm_component parent); super.new(name, parent); endfunction
    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      env = dv03_env::type_id::create("env", this);
    endfunction
    task run_phase(uvm_phase phase);
      dv03_target_sequence target_sequence;
      int unsigned observed;
      phase.raise_objection(this);
      target_sequence = dv03_target_sequence::type_id::create("target_sequence");
      target_sequence.start(env.sequencer);
      observed = env.coverage.observed_required();
      for (int index = 0; index < 6; index++)
        if (!env.coverage.seen[index])
          `uvm_error("DV03_HOLE", $sformatf("required_scenario=%0d was not observed", index))
      if (observed != 6)
        `uvm_error("DV03_RESULT",
          $sformatf("observed_required=%0d/6 samples=%0d", observed, env.coverage.samples))
      else begin
        `uvm_info("DV03_PASS",
          $sformatf("observed_required=6/6 samples=%0d", env.coverage.samples), UVM_NONE)
        $display("TEST_RESULT: PASS");
      end
      phase.drop_objection(this);
    endtask
  endclass
endpackage
