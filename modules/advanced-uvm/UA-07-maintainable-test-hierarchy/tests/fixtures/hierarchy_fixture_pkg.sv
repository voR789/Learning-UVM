package hierarchy_fixture_pkg;
    import uvm_pkg::*;
    import ua07_support_pkg::*;
    import ua07_tests_pkg::*;
    `include "uvm_macros.svh"

    class ua07_reference_base_test extends ua07_base_test;
        `uvm_component_utils(ua07_reference_base_test)
        function new(string name, uvm_component parent);
            super.new(name, parent);
        endfunction
        task run_phase(uvm_phase phase);
            ua07_scenario scenario;
            phase.raise_objection(this);
            scenario = select_scenario();
            if (scenario == null)
                `uvm_fatal("UA07_SELECTION", "test did not select a scenario")
            scenario.start(env.sequencer);
            if ((scenario.verified == 0) ||
                (scenario.verified != env.driver.driven))
                `uvm_fatal("UA07_COUNT", $sformatf(
                    "verified=%0d driven=%0d", scenario.verified, env.driver.driven))
            common_run_completed = 1'b1;
            $display("UA07_TRACE test=%s verified=%0d driven=%0d",
                get_type_name(), scenario.verified, env.driver.driven);
            $display("TEST_RESULT: PASS");
            phase.drop_objection(this);
        endtask
    endclass

    class ua07_reference_smoke_test extends ua07_reference_base_test;
        `uvm_component_utils(ua07_reference_smoke_test)
        function new(string name, uvm_component parent);
            super.new(name, parent);
        endfunction
        virtual function ua07_scenario select_scenario();
            ua07_smoke_scenario scenario;
            scenario = ua07_smoke_scenario::type_id::create("scenario");
            return scenario;
        endfunction
    endclass

    class ua07_reference_stress_test extends ua07_reference_base_test;
        `uvm_component_utils(ua07_reference_stress_test)
        function new(string name, uvm_component parent);
            super.new(name, parent);
        endfunction
        virtual function ua07_scenario select_scenario();
            ua07_stress_scenario scenario;
            scenario = ua07_stress_scenario::type_id::create("scenario");
            return scenario;
        endfunction
    endclass

    class ua07_bypass_common_run_test extends ua07_base_test;
        `uvm_component_utils(ua07_bypass_common_run_test)
        function new(string name, uvm_component parent);
            super.new(name, parent);
        endfunction
        task run_phase(uvm_phase phase);
            ua07_smoke_scenario scenario;
            phase.raise_objection(this);
            scenario = ua07_smoke_scenario::type_id::create("scenario");
            scenario.start(env.sequencer);
            phase.drop_objection(this);
        endtask
    endclass
endpackage
