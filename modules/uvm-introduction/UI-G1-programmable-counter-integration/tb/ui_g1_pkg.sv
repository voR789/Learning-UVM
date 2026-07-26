package ui_g1_pkg;
    import uvm_pkg::*;
    `include "uvm_macros.svh"

    class counter_txn extends uvm_sequence_item;
        `uvm_object_utils(counter_txn)
        bit       is_reset;
        bit [1:0] cmd;
        bit [7:0] load_value;
        bit [7:0] observed_count;
        function new(string name = "counter_txn"); super.new(name); endfunction
    endclass

    class counter_scenario extends uvm_sequence #(counter_txn);
        `uvm_object_utils(counter_scenario)
        function new(string name = "counter_scenario"); super.new(name); endfunction
        task body();
            counter_txn req;
            // TODO 1: Generate the nine operations in README order using the
            // explicit item handshake. Set is_reset only for RESET and set
            // load_value only as specified.
        endtask
    endclass

    class counter_sequencer extends uvm_sequencer #(counter_txn);
        `uvm_component_utils(counter_sequencer)
        function new(string name, uvm_component parent); super.new(name,parent); endfunction
    endclass

    class counter_driver extends uvm_driver #(counter_txn);
        `uvm_component_utils(counter_driver)
        virtual counter_if vif;
        int completed;
        function new(string name, uvm_component parent); super.new(name,parent); endfunction
        function void build_phase(uvm_phase phase);
            super.build_phase(phase);
            // TODO 2: Get virtual interface "vif" from config_db or fatal.
        endfunction
        task run_phase(uvm_phase phase);
            counter_txn req;
            // TODO 3: Initialize the interface inactive, then drive every
            // request before a rising edge. For RESET drive rst_n low and
            // cmd_valid low; otherwise drive rst_n high and cmd_valid high.
            // Return the interface inactive after the sampled edge; complete
            // and acknowledge exactly nine items.
        endtask
    endclass

    class counter_monitor extends uvm_component;
        `uvm_component_utils(counter_monitor)
        virtual counter_if vif;
        uvm_analysis_port #(counter_txn) observed_ap;
        int published;
        function new(string name, uvm_component parent);
            super.new(name,parent);
            observed_ap = new("observed_ap",this);
        endfunction
        function void build_phase(uvm_phase phase);
            super.build_phase(phase);
            // TODO 4: Get virtual interface "vif" from config_db or fatal.
        endfunction
        task run_phase(uvm_phase phase);
            counter_txn observed;
            // TODO 5: On each rising edge when reset is asserted or cmd_valid
            // is high, wait 1 ps for the DUT NBA update, capture
            // is_reset/command/load/count, publish once, and increment published.
        endtask
    endclass

    class counter_scoreboard extends uvm_component;
        `uvm_component_utils(counter_scoreboard)
        uvm_analysis_imp #(counter_txn,counter_scoreboard) observed_imp;
        bit [7:0] expected_count;
        int checks;
        function new(string name, uvm_component parent);
            super.new(name,parent);
            observed_imp = new("observed_imp",this);
        endfunction
        function void write(counter_txn observed);
            // TODO 6: Give observed reset priority, otherwise predict
            // LOAD/INC/DEC/CLEAR independently. Compare observed_count, fatal
            // with useful fields on mismatch, and increment checks.
        endfunction
    endclass

    class counter_coverage extends uvm_subscriber #(counter_txn);
        `uvm_component_utils(counter_coverage)
        bit [1:0] sampled_cmd;
        bit [7:0] sampled_count;
        bit       sampled_reset;
        int samples;
        covergroup counter_cg;
            option.per_instance = 1;
            // TODO 7: cp_cmd with load/inc/dec/clear bins, sampled only when
            // sampled_reset is false so RESET cannot falsely fill the LOAD bin.
            // TODO 8: cp_count with zero, middle[1:254], maximum bins.
        endgroup
        function new(string name, uvm_component parent);
            super.new(name,parent);
            // TODO 9: Construct embedded counter_cg.
        endfunction
        function void write(counter_txn observed);
            // TODO 10: Copy observed reset/command/count fields, sample exactly
            // once per published operation, and increment samples.
        endfunction
    endclass

    class counter_agent extends uvm_agent;
        `uvm_component_utils(counter_agent)
        counter_sequencer sequencer;
        counter_driver driver;
        counter_monitor monitor;
        function new(string name, uvm_component parent); super.new(name,parent); endfunction
        function void build_phase(uvm_phase phase);
            super.build_phase(phase);
            // TODO 11: Factory-create sequencer, driver, and monitor.
        endfunction
        function void connect_phase(uvm_phase phase);
            super.connect_phase(phase);
            // TODO 12: Connect driver request port to sequencer export.
        endfunction
    endclass

    class counter_env extends uvm_env;
        `uvm_component_utils(counter_env)
        counter_agent agent;
        counter_scoreboard scoreboard;
        counter_coverage coverage;
        function new(string name,uvm_component parent); super.new(name,parent); endfunction
        function void build_phase(uvm_phase phase);
            super.build_phase(phase);
            // TODO 13: Factory-create agent, scoreboard, and coverage.
        endfunction
        function void connect_phase(uvm_phase phase);
            super.connect_phase(phase);
            // TODO 14: Broadcast monitor observations to scoreboard and coverage.
        endfunction
    endclass

    class counter_test extends uvm_test;
        `uvm_component_utils(counter_test)
        counter_env env;
        function new(string name,uvm_component parent); super.new(name,parent); endfunction
        function void build_phase(uvm_phase phase);
            super.build_phase(phase);
            env = counter_env::type_id::create("env",this);
        endfunction
        task run_phase(uvm_phase phase);
            counter_scenario scenario;
            uvm_report_server server;
            real coverage_pct;
            int errors, fatals;
            // TODO 15: Raise objection, create/start scenario, allow final
            // monitor publication, query coverage and report counts, and fatal
            // unless driver/monitor/scoreboard/coverage counts are all 9,
            // coverage is 100%, and errors/fatals are zero.
            // Print exact:
            // INTEGRATION_TRACE: driven=9 observed=9 checked=9 sampled=9 coverage=100.00 errors=0 fatals=0
            // TEST_RESULT: PASS
            // Drop objection.
        endtask
    endclass
endpackage
