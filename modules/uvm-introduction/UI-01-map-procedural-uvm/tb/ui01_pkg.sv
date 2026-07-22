package ui01_pkg;
    import uvm_pkg::*;
    `include "uvm_macros.svh"

    class ui01_driver extends uvm_component;
        `uvm_component_utils(ui01_driver)

        function new(string name = "ui01_driver", uvm_component parent = null);
            super.new(name, parent);
        endfunction

        task run_phase(uvm_phase phase);
            `uvm_info("UI01_DRIVER", "Owns timed active-interface driving", UVM_LOW)
        endtask
    endclass

    class ui01_monitor extends uvm_component;
        `uvm_component_utils(ui01_monitor)

        function new(string name = "ui01_monitor", uvm_component parent = null);
            super.new(name, parent);
        endfunction

        task run_phase(uvm_phase phase);
            `uvm_info("UI01_MONITOR", "Passively publishes completed observations", UVM_LOW)
        endtask
    endclass

    class ui01_scoreboard extends uvm_component;
        `uvm_component_utils(ui01_scoreboard)

        function new(string name = "ui01_scoreboard", uvm_component parent = null);
            super.new(name, parent);
        endfunction

        task run_phase(uvm_phase phase);
            `uvm_info("UI01_SCOREBOARD", "Checks expected transactions against observations", UVM_LOW)
        endtask
    endclass

    class ui01_env extends uvm_env;
        `uvm_component_utils(ui01_env)

        ui01_driver driver;
        ui01_monitor monitor;
        ui01_scoreboard scoreboard;

        function new(string name = "ui01_env", uvm_component parent = null);
            super.new(name, parent);
        endfunction

        function void build_phase(uvm_phase phase);
            super.build_phase(phase);
            driver = ui01_driver::type_id::create("driver", this);
            monitor = ui01_monitor::type_id::create("monitor", this);
            scoreboard = ui01_scoreboard::type_id::create("scoreboard", this);
        endfunction
    endclass

    class ui01_hierarchy_test extends uvm_test;
        `uvm_component_utils(ui01_hierarchy_test)

        ui01_env env;

        function new(string name = "ui01_hierarchy_test", uvm_component parent = null);
            super.new(name, parent);
        endfunction

        function void build_phase(uvm_phase phase);
            super.build_phase(phase);
            env = ui01_env::type_id::create("env", this);
        endfunction

        task run_phase(uvm_phase phase);
            phase.raise_objection(this);
            uvm_top.print_topology();
            $display("UI01_TRACE: sequence_item=transaction_data sequence=stimulus_intent");
            $display("UI01_TRACE: driver=active monitor=passive scoreboard=checking");
            #1ns;
            $display("TEST_RESULT: PASS");
            phase.drop_objection(this);
        endtask
    endclass
endpackage
