package ub02_pkg;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  class ub02_worker extends uvm_component;
    `uvm_component_utils(ub02_worker)
    int unsigned ticks;

    function new(string name, uvm_component parent);
      super.new(name, parent);
    endfunction

    task run_phase(uvm_phase phase);
      repeat (3) begin
        #1ns;
        ticks++;
      end
    endtask
  endclass

  class ub02_test extends uvm_test;
    `uvm_component_utils(ub02_test)
    ub02_worker worker;

    function new(string name, uvm_component parent);
      super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      worker = ub02_worker::type_id::create("worker", this);
    endfunction

    task run_phase(uvm_phase phase);
      phase.raise_objection(this);
      if (worker == null)
        `uvm_fatal("UB02_STRUCTURE", "worker was not constructed")
      else begin
        wait (worker.ticks == 3);
        if (worker.get_full_name() != "uvm_test_top.worker")
          `uvm_fatal("UB02_STRUCTURE", "worker has the wrong hierarchy")
        if (worker.ticks != 3)
          `uvm_fatal("UB02_COUNT", "worker did not produce exactly three ticks")
        $display("UB02_TRACE: worker=%s ticks=%0d",
                 worker.get_full_name(), worker.ticks);
        $display("TEST_RESULT: PASS");
      end
      phase.drop_objection(this);
    endtask
  endclass
endpackage
