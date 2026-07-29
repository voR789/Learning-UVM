package ub08_check_pkg;
  import uvm_pkg::*;
  import ub08_pkg::*;
  `include "uvm_macros.svh"

  class ub08_source extends uvm_component;
    `uvm_component_utils(ub08_source)
    uvm_analysis_port #(ub08_observation) observed_ap;
    bit inject_fault;
    bit done;

    function new(string name, uvm_component parent);
      super.new(name, parent);
      observed_ap = new("observed_ap", this);
    endfunction

    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      void'(uvm_config_db#(bit)::get(this, "", "inject_fault", inject_fault));
    endfunction

    task run_phase(uvm_phase phase);
      ub08_observation observation;
      int transaction_handle;

      done = 0;
      for (int unsigned i = 0; i < 5; i++) begin
        observation = ub08_observation::type_id::create($sformatf("observation_%0d", i));
        observation.id = i;
        observation.expected = $urandom_range(8'hff, 8'h00);
        observation.observed = observation.expected;
        if (inject_fault && i == 3)
          observation.observed ^= 8'h01;

        observation.accept_tr($time);
        transaction_handle = observation.begin_tr();
        observed_ap.write(observation);
        observation.end_tr();
        #1ns;
      end
      done = 1;
    endtask
  endclass

  class ub08_base_test extends uvm_test;
    `uvm_component_utils(ub08_base_test)
    ub08_source source;
    ub08_audit audit;
    bit fault_mode;

    function new(string name, uvm_component parent);
      super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
      uvm_config_db#(bit)::set(this, "source", "inject_fault", fault_mode);
      super.build_phase(phase);
      source = ub08_source::type_id::create("source", this);
      audit = ub08_audit::type_id::create("audit", this);
    endfunction

    function void connect_phase(uvm_phase phase);
      super.connect_phase(phase);
      source.observed_ap.connect(audit.analysis_export);
    endfunction

    task run_phase(uvm_phase phase);
      phase.raise_objection(this);
      wait (source.done);
      #1ps;
      if (audit.checked != 5)
        `uvm_fatal("UB08_COUNT", "audit did not check all five observations")
      if (fault_mode && audit.mismatches != 1)
        `uvm_fatal("UB08_DETECTION", "audit did not account for the injected mismatch")
      if (!fault_mode && audit.mismatches != 0)
        `uvm_fatal("UB08_CLEAN", "clean run reported a mismatch")
      $display("TEST_RESULT: PASS");
      phase.drop_objection(this);
    endtask
  endclass

  class ub08_clean_test extends ub08_base_test;
    `uvm_component_utils(ub08_clean_test)
    function new(string name, uvm_component parent);
      super.new(name, parent);
      fault_mode = 0;
    endfunction
  endclass

  class ub08_fault_test extends ub08_base_test;
    `uvm_component_utils(ub08_fault_test)
    function new(string name, uvm_component parent);
      super.new(name, parent);
      fault_mode = 1;
    endfunction
  endclass
endpackage
