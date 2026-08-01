package ua05_pkg;
    import uvm_pkg::*;
    `include "uvm_macros.svh"

    class ua05_item extends uvm_sequence_item;
        `uvm_object_utils(ua05_item)
        int unsigned lane;
        int unsigned token;
        int unsigned result;

        function new(string name = "ua05_item");
            super.new(name);
        endfunction
    endclass

    class ua05_gate extends uvm_object;
        `uvm_object_utils(ua05_gate)
        uvm_event release_event;
        int unsigned arrivals;

        function new(string name = "ua05_gate");
            super.new(name);
            release_event = new("release_event");
        endfunction

        task arrive_and_wait();
            bit released;
            arrivals++;
            if (arrivals == 2) begin
                release_event.trigger();
            end else begin
                fork
                    begin
                        release_event.wait_trigger();
                        released = 1'b1;
                    end
                    begin
                        #10ns;
                    end
                join_any
                disable fork;
                if (!released)
                    `uvm_error("UA05_CONCURRENCY", "second child did not become active before the rendezvous timeout")
            end
        endtask
    endclass

    class ua05_sequencer extends uvm_sequencer #(ua05_item);
        `uvm_component_utils(ua05_sequencer)
        function new(string name, uvm_component parent);
            super.new(name, parent);
        endfunction
    endclass

    class ua05_driver extends uvm_driver #(ua05_item);
        `uvm_component_utils(ua05_driver)
        int unsigned driven;
        int unsigned lane_count[2];

        function new(string name, uvm_component parent);
            super.new(name, parent);
        endfunction

        task run_phase(uvm_phase phase);
            ua05_item req;
            ua05_item rsp;
            forever begin
                seq_item_port.get_next_item(req);
                #1ns;
                rsp = ua05_item::type_id::create("rsp");
                rsp.set_id_info(req);
                rsp.lane = req.lane;
                rsp.token = req.token;
                rsp.result = req.token + 1;
                driven++;
                if (req.lane < 2)
                    lane_count[req.lane]++;
                seq_item_port.item_done(rsp);
            end
        endtask
    endclass

    class ua05_leaf_sequence extends uvm_sequence #(ua05_item);
        `uvm_object_utils(ua05_leaf_sequence)
        ua05_gate gate;
        int unsigned lane;
        int unsigned first_token;
        int unsigned verified;

        function new(string name = "ua05_leaf_sequence");
            super.new(name);
        endfunction

        task body();
            ua05_item req;
            ua05_item rsp;
            if (gate == null)
                `uvm_fatal("UA05_GATE", "leaf sequence did not receive the shared gate")
            gate.arrive_and_wait();
            for (int unsigned i = 0; i < 3; i++) begin
                req = ua05_item::type_id::create($sformatf("req_%0d", i));
                start_item(req);
                req.lane = lane;
                req.token = first_token + i;
                finish_item(req);
                get_response(rsp);
                if ((rsp.lane != lane) || (rsp.token != first_token + i) ||
                    (rsp.result != first_token + i + 1))
                    `uvm_fatal("UA05_RESPONSE", "response was routed to the wrong child or contained incorrect data")
                verified++;
            end
        endtask
    endclass

    class ua05_parallel_sequence extends uvm_sequence #(ua05_item);
        `uvm_object_utils(ua05_parallel_sequence)
        ua05_gate gate;
        ua05_leaf_sequence first;
        ua05_leaf_sequence second;

        function new(string name = "ua05_parallel_sequence");
            super.new(name);
        endfunction

        function void prepare_children();
            gate = ua05_gate::type_id::create("gate");
            first = ua05_leaf_sequence::type_id::create("first");
            second = ua05_leaf_sequence::type_id::create("second");
            first.gate = gate;
            second.gate = gate;
            first.lane = 0;
            second.lane = 1;
            first.first_token = 8'h10;
            second.first_token = 8'h20;
        endfunction

        task body();
            prepare_children();
            // TODO: Start both distinct children concurrently on m_sequencer,
            // pass this sequence as parent context, and wait for both to finish.
            fork
                first.start(m_sequencer, this);
                second.start(m_sequencer, this);
            join
        endtask
    endclass

    class ua05_test extends uvm_test;
        `uvm_component_utils(ua05_test)
        ua05_sequencer sequencer;
        ua05_driver driver;

        function new(string name, uvm_component parent);
            super.new(name, parent);
        endfunction

        virtual function void configure();
        endfunction

        function void build_phase(uvm_phase phase);
            super.build_phase(phase);
            configure();
            sequencer = ua05_sequencer::type_id::create("sequencer", this);
            driver = ua05_driver::type_id::create("driver", this);
        endfunction

        function void connect_phase(uvm_phase phase);
            super.connect_phase(phase);
            driver.seq_item_port.connect(sequencer.seq_item_export);
        endfunction

        task run_phase(uvm_phase phase);
            ua05_parallel_sequence scenario;
            uvm_report_server server;
            int errors;
            int fatals;

            phase.raise_objection(this);
            scenario = ua05_parallel_sequence::type_id::create("scenario");
            scenario.start(sequencer);
            if ((scenario.first == null) || (scenario.second == null) ||
                (scenario.gate == null))
                `uvm_fatal("UA05_COUNT", "parallel scenario did not prepare both children and gate")
            server = uvm_report_server::get_server();
            errors = server.get_severity_count(UVM_ERROR);
            fatals = server.get_severity_count(UVM_FATAL);
            if ((scenario.gate.arrivals != 2) || (scenario.first.verified != 3) ||
                (scenario.second.verified != 3) || (driver.driven != 6) ||
                (driver.lane_count[0] != 3) || (driver.lane_count[1] != 3) ||
                (errors != 0) || (fatals != 0))
                `uvm_fatal("UA05_COUNT", $sformatf("arrivals=%0d first=%0d second=%0d driven=%0d lane0=%0d lane1=%0d errors=%0d fatals=%0d",
                    scenario.gate.arrivals, scenario.first.verified,
                    scenario.second.verified, driver.driven,
                    driver.lane_count[0], driver.lane_count[1], errors, fatals))
            $display("UA05_TRACE arrivals=%0d first=%0d second=%0d driven=%0d lane0=%0d lane1=%0d",
                scenario.gate.arrivals, scenario.first.verified,
                scenario.second.verified, driver.driven,
                driver.lane_count[0], driver.lane_count[1]);
            $display("TEST_RESULT: PASS");
            phase.drop_objection(this);
        endtask
    endclass
endpackage
