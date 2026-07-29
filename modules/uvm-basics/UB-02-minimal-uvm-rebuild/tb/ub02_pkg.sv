package ub02_pkg;
    import uvm_pkg::*;
    `include "uvm_macros.svh"

    class ub02_worker extends uvm_component;
    int unsigned ticks;

    // TODO: Make this component factory-compatible.
    `uvm_component_utils(ub02_worker)
    function new(string name, uvm_component parent);
        // TODO: Initialize the UVM component correctly.
        super.new(name, parent);
        ticks = 0;
    endfunction

    task run_phase(uvm_phase phase);
        super.run_phase(phase);
        // TODO: Produce exactly three observable ticks over simulation time.
        repeat(3) begin
            #1ns;
            ticks++;
        end
    endtask

    endclass

    class ub02_test extends uvm_test;
        ub02_worker worker;

        // TODO: Make this test selectable through run_test.
        `uvm_component_utils(ub02_test)
        function new(string name, uvm_component parent);
            // TODO: Initialize the UVM test correctly.
            super.new(name, parent);
        endfunction

        function void build_phase(uvm_phase phase);
            // TODO: Build the required hierarchy through the factory.
            super.build_phase(phase);
            worker = ub02_worker::type_id::create("worker", this);
        endfunction

        task run_phase(uvm_phase phase);
            // TODO: Own termination, wait for completed work, validate the observable
            // contract, and report the deterministic result.
            phase.raise_objection(this);
            if(worker != null) begin
                wait(worker.ticks == 3);
                $display("TRACE: Ticks: %0d", worker.ticks);
                if(worker.ticks != 3)
                    `uvm_fatal("UVM_VERDICT", "ticks is not equal to expected")
                $display("TEST_RESULT: PASS");
            end else begin
                `uvm_fatal("UVM_STRUCTURE", "worker is null")
            end
            phase.drop_objection(this);
        endtask
    endclass
endpackage
