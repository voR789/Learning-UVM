package ub02_pkg;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  class ub02_worker extends uvm_component;
    `uvm_component_utils(ub02_worker)
    int unsigned ticks;
    function new(string name, uvm_component parent);
      super.new(name, parent);
    endfunction
  endclass

  class ub02_test extends uvm_test;
    `uvm_component_utils(ub02_test)
    ub02_worker worker;

    function new(string name, uvm_component parent);
      super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
    endfunction

    task run_phase(uvm_phase phase);
      phase.raise_objection(this);
      if (worker == null)
        `uvm_fatal("UB02_STRUCTURE", "worker was not constructed")
      phase.drop_objection(this);
    endtask
  endclass
endpackage
