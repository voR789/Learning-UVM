package smoke_pkg;
    import uvm_pkg::*;
    `include "uvm_macros.svh"

    class smoke_base_test extends uvm_test;
        `uvm_component_utils(smoke_base_test)

        virtual smoke_if vif;

        function new(string name = "smoke_base_test", uvm_component parent = null);
            super.new(name, parent);
        endfunction

        function void build_phase(uvm_phase phase);
            super.build_phase(phase);
            if (!uvm_config_db#(virtual smoke_if)::get(this, "", "vif", vif))
                `uvm_fatal("NO_VIF", "smoke_if was not provided through uvm_config_db")
        endfunction

        task reset_dut();
            vif.rst_n  = 1'b0;
            vif.enable = 1'b0;
            repeat (2) @(negedge vif.clk);
            vif.rst_n = 1'b1;
            @(negedge vif.clk);
        endtask
    endclass

    class smoke_pass_test extends smoke_base_test;
        `uvm_component_utils(smoke_pass_test)

        function new(string name = "smoke_pass_test", uvm_component parent = null);
            super.new(name, parent);
        endfunction

        task run_phase(uvm_phase phase);
            phase.raise_objection(this);
            reset_dut();

            if (vif.count !== 4'd0)
                `uvm_fatal("RESET", $sformatf("Expected count 0 after reset, got %0d", vif.count))

            vif.enable = 1'b1;
            for (int expected = 1; expected <= 3; expected++) begin
                @(posedge vif.clk);
                #1ps;
                if (vif.count !== expected[3:0])
                    `uvm_fatal("COUNT", $sformatf("Expected count %0d, got %0d", expected, vif.count))
            end

            @(negedge vif.clk);
            vif.enable = 1'b0;
            @(posedge vif.clk);
            #1ps;
            if (vif.count !== 4'd3)
                `uvm_fatal("HOLD", $sformatf("Expected held count 3, got %0d", vif.count))

            $display("TEST_RESULT: PASS");
            phase.drop_objection(this);
        endtask
    endclass

    class smoke_expected_fail_test extends smoke_base_test;
        `uvm_component_utils(smoke_expected_fail_test)

        function new(string name = "smoke_expected_fail_test", uvm_component parent = null);
            super.new(name, parent);
        endfunction

        task run_phase(uvm_phase phase);
            phase.raise_objection(this);
            reset_dut();

            vif.enable = 1'b1;
            @(posedge vif.clk);
            #1ps;

            `uvm_error("EXPECTED_FAILURE", "Deliberate UVM error used to verify runner failure detection")
            $display("TEST_RESULT: INTENTIONAL_FAIL");
            phase.drop_objection(this);
        endtask
    endclass
endpackage

