package ua04_fixture_pkg;
    import uvm_pkg::*;
    import ua04_pkg::*;
    `include "uvm_macros.svh"

    class ua04_reference_predictor extends ua04_predictor;
        `uvm_component_utils(ua04_reference_predictor)
        function new(string name, uvm_component parent);
            super.new(name, parent);
        endfunction
        function void write(ua04_cmd t);
            ua04_result expected;
            expected = ua04_result::type_id::create("expected");
            expected.id = t.id;
            if (t.op == UA04_ADD)
                expected.value = t.a + t.b;
            else
                expected.value = t.a ^ t.b;
            expected_ap.write(expected);
            predicted++;
        endfunction
    endclass

    class ua04_reference_scoreboard extends ua04_scoreboard;
        `uvm_component_utils(ua04_reference_scoreboard)
        function new(string name, uvm_component parent);
            super.new(name, parent);
        endfunction
        task run_phase(uvm_phase phase);
            ua04_result expected;
            ua04_result actual;
            forever begin
                expected_fifo.get(expected);
                actual_fifo.get(actual);
                if ((expected.id != actual.id) || (expected.value != actual.value)) begin
                    mismatches++;
                    `uvm_error("UA04_MISMATCH", $sformatf("expected={%s} actual={%s}",
                        expected.convert2string(), actual.convert2string()))
                end
                checked++;
            end
        endtask
    endclass

    class ua04_valid_fixture_test extends ua04_test;
        `uvm_component_utils(ua04_valid_fixture_test)
        function new(string name, uvm_component parent);
            super.new(name, parent);
        endfunction
        virtual function void configure();
            ua04_predictor::type_id::set_type_override(
                ua04_reference_predictor::get_type());
            ua04_scoreboard::type_id::set_type_override(
                ua04_reference_scoreboard::get_type());
        endfunction
    endclass

    class ua04_corrupt_actual_test extends ua04_valid_fixture_test;
        `uvm_component_utils(ua04_corrupt_actual_test)
        function new(string name, uvm_component parent);
            super.new(name, parent);
        endfunction
        virtual function void configure();
            super.configure();
            uvm_config_db #(int)::set(this, "env.source", "fault_index", 1);
        endfunction
    endclass
endpackage
