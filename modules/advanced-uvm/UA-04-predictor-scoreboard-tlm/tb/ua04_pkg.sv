package ua04_pkg;
    import uvm_pkg::*;
    `include "uvm_macros.svh"

    typedef enum bit {UA04_ADD, UA04_XOR} ua04_op_e;

    class ua04_cmd extends uvm_sequence_item;
        `uvm_object_utils(ua04_cmd)
        int unsigned id;
        ua04_op_e    op;
        bit [7:0]    a;
        bit [7:0]    b;

        function new(string name = "ua04_cmd");
            super.new(name);
        endfunction

        function string convert2string();
            return $sformatf("id=%0d op=%s a=0x%02h b=0x%02h", id,
                (op == UA04_ADD) ? "ADD" : "XOR", a, b);
        endfunction
    endclass

    class ua04_result extends uvm_sequence_item;
        `uvm_object_utils(ua04_result)
        int unsigned id;
        bit [7:0]    value;

        function new(string name = "ua04_result");
            super.new(name);
        endfunction

        function string convert2string();
            return $sformatf("id=%0d value=0x%02h", id, value);
        endfunction
    endclass

    class ua04_source extends uvm_component;
        `uvm_component_utils(ua04_source)
        uvm_analysis_port #(ua04_cmd)    command_ap;
        uvm_analysis_port #(ua04_result) actual_ap;
        int fault_index = -1;
        int unsigned emitted;

        function new(string name, uvm_component parent);
            super.new(name, parent);
            command_ap = new("command_ap", this);
            actual_ap = new("actual_ap", this);
        endfunction

        function void build_phase(uvm_phase phase);
            super.build_phase(phase);
            void'(uvm_config_db #(int)::get(this, "", "fault_index", fault_index));
        endfunction

        task publish(int unsigned id, ua04_op_e op, bit [7:0] a, bit [7:0] b);
            ua04_cmd command;
            ua04_result actual;
            command = ua04_cmd::type_id::create($sformatf("command_%0d", id));
            actual = ua04_result::type_id::create($sformatf("actual_%0d", id));
            command.id = id;
            command.op = op;
            command.a = a;
            command.b = b;
            actual.id = id;
            if (op == UA04_ADD)
                actual.value = a + b;
            else
                actual.value = a ^ b;
            if (fault_index == int'(id))
                actual.value = actual.value ^ 8'h01;

            command_ap.write(command);
            #1ns;
            actual_ap.write(actual);
            emitted++;
        endtask

        task run_phase(uvm_phase phase);
            publish(0, UA04_ADD, 8'h05, 8'h07);
            publish(1, UA04_XOR, 8'hA5, 8'h3C);
            publish(2, UA04_ADD, 8'hFF, 8'h02);
        endtask
    endclass

    class ua04_predictor extends uvm_subscriber #(ua04_cmd);
        `uvm_component_utils(ua04_predictor)
        uvm_analysis_port #(ua04_result) expected_ap;
        int unsigned predicted;

        function new(string name, uvm_component parent);
            super.new(name, parent);
            expected_ap = new("expected_ap", this);
        endfunction

        function void write(ua04_cmd t);
            ua04_result expected;
            // TODO: Create one independent expected result, preserve command
            // identity, calculate the specified ADD/XOR value, and publish it.
            expected = ua04_result::type_id::create();
            expected.id = t.id;
            if(t.op == UA04_ADD) begin
                expected.value =  t.a + t.b; 
            end else if (t.op == UA04_XOR) begin
                expected.value = t.a ^ t.b;
            end
            predicted++;
            expected_ap.write(expected);
        endfunction
    endclass

    class ua04_scoreboard extends uvm_component;
        `uvm_component_utils(ua04_scoreboard)
        uvm_tlm_analysis_fifo #(ua04_result) expected_fifo;
        uvm_tlm_analysis_fifo #(ua04_result) actual_fifo;
        int unsigned checked;
        int unsigned mismatches;

        function new(string name, uvm_component parent);
            super.new(name, parent);
            expected_fifo = new("expected_fifo", this);
            actual_fifo = new("actual_fifo", this);
        endfunction

        task run_phase(uvm_phase phase);
            ua04_result expected;
            ua04_result actual;
            // TODO: Repeatedly consume one object from each FIFO. Check both
            // identity and value, report UA04_MISMATCH, and count every pair.
            forever begin
                expected_fifo.get(expected);
                actual_fifo.get(actual);

                if(expected.id != actual.id || expected.value != actual.value) begin
                    `uvm_error("UA04_MISMATCH", "Expected values not equal to actual")
                    mismatches++;
                end 
                checked++;
            end
        endtask
    endclass

    class ua04_env extends uvm_env;
        `uvm_component_utils(ua04_env)
        ua04_source source;
        ua04_predictor predictor;
        ua04_scoreboard scoreboard;

        function new(string name, uvm_component parent);
            super.new(name, parent);
        endfunction

        function void build_phase(uvm_phase phase);
            super.build_phase(phase);
            source = ua04_source::type_id::create("source", this);
            predictor = ua04_predictor::type_id::create("predictor", this);
            scoreboard = ua04_scoreboard::type_id::create("scoreboard", this);
        endfunction

        function void connect_phase(uvm_phase phase);
            super.connect_phase(phase);
            source.command_ap.connect(predictor.analysis_export);
            predictor.expected_ap.connect(scoreboard.expected_fifo.analysis_export);
            source.actual_ap.connect(scoreboard.actual_fifo.analysis_export);
        endfunction
    endclass

    class ua04_test extends uvm_test;
        `uvm_component_utils(ua04_test)
        ua04_env env;

        function new(string name, uvm_component parent);
            super.new(name, parent);
        endfunction

        virtual function void configure();
        endfunction

        function void build_phase(uvm_phase phase);
            super.build_phase(phase);
            configure();
            env = ua04_env::type_id::create("env", this);
        endfunction

        task run_phase(uvm_phase phase);
            phase.raise_objection(this);
            #20ns;
            if ((env.source.emitted != 3) || (env.predictor.predicted != 3) ||
                (env.scoreboard.checked != 3))
                `uvm_fatal("UA04_COUNT", $sformatf("emitted=%0d predicted=%0d checked=%0d",
                    env.source.emitted, env.predictor.predicted, env.scoreboard.checked))
            if (env.scoreboard.mismatches != 0)
                `uvm_fatal("UA04_MISMATCH", $sformatf("mismatches=%0d", env.scoreboard.mismatches))
            $display("UA04_TRACE emitted=%0d predicted=%0d checked=%0d mismatches=%0d",
                env.source.emitted, env.predictor.predicted,
                env.scoreboard.checked, env.scoreboard.mismatches);
            $display("TEST_RESULT: PASS");
            phase.drop_objection(this);
        endtask
    endclass
endpackage
