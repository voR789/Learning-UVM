package ua07_tests_pkg;
    import uvm_pkg::*;
    import ua07_support_pkg::*;
    `include "uvm_macros.svh"

    class ua07_base_test extends uvm_test;
        `uvm_component_utils(ua07_base_test)
        ua07_env env;
        bit common_run_completed;

        function new(string name, uvm_component parent);
            super.new(name, parent);
        endfunction

        function void build_phase(uvm_phase phase);
            super.build_phase(phase);
            env = ua07_env::type_id::create("env", this);
        endfunction

        virtual function ua07_scenario select_scenario();
            return null;
        endfunction

        task run_phase(uvm_phase phase);
            // TODO: Own the shared lifecycle for every derived test:
            // select and null-check the scenario, hold the objection across its
            // execution, require matching nonzero scenario/driver counts, emit
            // the trace and pass marker, and record common_run_completed.
            ua07_scenario scenario;
            scenario = select_scenario();
            if(scenario == null) 
                `uvm_fatal("UA07_SELECTION", "Invalid selected scenario")
            phase.raise_objection(this);
            
            scenario.start(env.sequencer); // Run scenario, responses block until driver has processed all
            
            if(scenario.verified == 0) begin
                `uvm_error("UA07_SCENARIO", "Verified count is zero")
            end
            if(scenario.verified !=  env.driver.driven) begin
                `uvm_error("UA07_MISMATCH", "Verified count is not equal to driven count")
            end
            $display("TRACE: Verified: %d, Driven %d", scenario.verified, env.driver.driven);
            $display("TEST_RESULT: PASS");
            common_run_completed = 1'b1;
            phase.drop_objection(this);
        endtask

        function void check_phase(uvm_phase phase);
            super.check_phase(phase);
            if (!common_run_completed)
                `uvm_fatal("UA07_CONTRACT",
                    "derived test bypassed or did not complete the shared base-test lifecycle")
        endfunction
    endclass

    class ua07_smoke_test extends ua07_base_test;
        `uvm_component_utils(ua07_smoke_test)
        function new(string name, uvm_component parent);
            super.new(name, parent);
        endfunction
        virtual function ua07_scenario select_scenario();
            ua07_smoke_scenario scenario;
            scenario = ua07_smoke_scenario::type_id::create("scenario");
            return scenario;
        endfunction
    endclass

    class ua07_stress_test extends ua07_base_test;
        `uvm_component_utils(ua07_stress_test)
        function new(string name, uvm_component parent);
            super.new(name, parent);
        endfunction
        virtual function ua07_scenario select_scenario();
            ua07_stress_scenario scenario;
            scenario = ua07_stress_scenario::type_id::create("scenario");
            return scenario;
        endfunction
    endclass
endpackage
