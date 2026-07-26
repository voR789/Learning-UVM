package ui11_pkg;
    import uvm_pkg::*;
    `include "uvm_macros.svh"

    class ui11_item extends uvm_sequence_item;
        `uvm_object_utils(ui11_item)
        int id;
        int payload;
        function new(string name = "ui11_item");
            super.new(name);
        endfunction
    endclass

    class ui11_burst_sequence extends uvm_sequence #(ui11_item);
        `uvm_object_utils(ui11_burst_sequence)
        int first_id;
        int first_payload;
        int item_count;

        function new(string name = "ui11_burst_sequence");
            super.new(name);
            item_count = 3;
        endfunction

        task body();
            ui11_item req;
            // TODO 1: Generate item_count items through the explicit item
            // handshake. IDs and payloads increment from configured bases.
            for(int i = 0; i < item_count; i++) begin
                req = ui11_item::type_id::create($sformatf("req_%d", i));
                start_item(req);
                req.id = first_id + i;
                req.payload = first_payload + i;
                finish_item(req);
            end
        endtask
    endclass

    class ui11_composite_sequence extends uvm_sequence #(ui11_item);
        `uvm_object_utils(ui11_composite_sequence)
        int subsequences_completed;

        function new(string name = "ui11_composite_sequence");
            super.new(name);
        endfunction

        task body(); // Composite sequence, nests leaves
            ui11_burst_sequence first;
            ui11_burst_sequence second;

            // TODO 2: Factory-create first, configure bases 0/10 and count 3,
            // start it on m_sequencer with this as parent, then increment
            // subsequences_completed.
            first = ui11_burst_sequence::type_id::create("first");
            first.first_id = 0;
            first.first_payload = 10;
            first.item_count = 3;
            first.start(m_sequencer, this); // Pass down the same sequencer to leaves
            subsequences_completed++;

            // TODO 3: Factory-create second, configure bases 3/20 and count 3,
            // start it the same way, then increment subsequences_completed.
            second = ui11_burst_sequence::type_id::create("second");
            second.first_id = 3;
            second.first_payload = 20;
            second.item_count = 3;
            second.start(m_sequencer, this); // Pass down the same sequencer to leaves
            subsequences_completed++;
        endtask
    endclass

    class ui11_sequencer extends uvm_sequencer #(ui11_item);
        `uvm_component_utils(ui11_sequencer)
        function new(string name, uvm_component parent);
            super.new(name, parent);
        endfunction
    endclass

    class ui11_driver extends uvm_driver #(ui11_item);
        `uvm_component_utils(ui11_driver)
        int completed;

        function new(string name, uvm_component parent);
            super.new(name, parent);
        endfunction

        task run_phase(uvm_phase phase);
            ui11_item req;
            int expected_payload;
            // TODO 4: Receive exactly six items with get_next_item().
            // Expected ID equals loop index. Payload is 10+index for IDs 0..2
            // and 17+index for IDs 3..5. Fatal on incorrect fields.
            // Increment completed and call exactly one item_done per item.
            for(int i = 0; i < 6; i++) begin
                seq_item_port.get_next_item(req);
                if(req.id != i) begin
                    `uvm_fatal("UI11_MISMATCH", "Id does not match expected!")
                end 
                if(i < 3) begin
                    if(req.payload != (10 + i)) begin
                        `uvm_fatal("UI11_MISMATCH", "Payload does not match expected!")
                    end
                end else begin
                    if(req.payload != (17 + i)) begin
                        `uvm_fatal("UI11_MISMATCH", "Payload does not match expected!")
                    end
                end
                completed++;
                seq_item_port.item_done();
            end
        endtask
    endclass

    class ui11_env extends uvm_env;
        `uvm_component_utils(ui11_env)
        ui11_sequencer sequencer;
        ui11_driver driver;

        function new(string name, uvm_component parent);
            super.new(name, parent);
        endfunction

        function void build_phase(uvm_phase phase);
            super.build_phase(phase);
            // TODO 5: Factory-create sequencer and driver with exact names.
            sequencer = ui11_sequencer::type_id::create("sequencer", this);
            driver = ui11_driver::type_id::create("driver", this);
        endfunction

        function void connect_phase(uvm_phase phase);
            super.connect_phase(phase);
            // TODO 6: Connect driver.seq_item_port to
            // sequencer.seq_item_export.
            driver.seq_item_port.connect(sequencer.seq_item_export); // Connect port to imp
        endfunction
    endclass

    class ui11_test extends uvm_test;
        `uvm_component_utils(ui11_test)
        ui11_env env;

        function new(string name, uvm_component parent);
            super.new(name, parent);
        endfunction

        function void build_phase(uvm_phase phase);
            super.build_phase(phase);
            // TODO 7: Factory-create env as child "env".
            env = ui11_env::type_id::create("env", this);
        endfunction

        task run_phase(uvm_phase phase);
            ui11_composite_sequence scenario;
            uvm_report_server server;
            int error_count;
            int fatal_count;

            // TODO 8: Raise the objection, factory-create scenario, and start
            // it on env.sequencer.
            phase.raise_objection(this);
            scenario = ui11_composite_sequence::type_id::create("scenario");
            scenario.start(env.sequencer); // Begins the sequence with our special sequencer
            // TODO 9: Query global error/fatal counts and fatal unless
            // driver.completed=6, scenario.subsequences_completed=2, and both
            // global counts are zero.
            server = uvm_report_server::get_server();
            error_count = server.get_severity_count(UVM_ERROR);
            fatal_count = server.get_severity_count(UVM_FATAL);
            
            if( env.driver.completed != 6 ||
                scenario.subsequences_completed !=  2 ||
                error_count != 0  ||
                fatal_count != 0)
                `uvm_fatal("UI11_VERDICT", "One or more fields is not correct")
            // TODO 10: Print exactly:
            // SEQUENCE_TRACE: completed=6 subsequences=2 errors=0 fatals=0
            // TEST_RESULT: PASS
            // Then drop the objection.
            $display("SEQUENCE_TRACE: completed=%0d subsequences=%0d errors=%0d fatals=%0d",
                     env.driver.completed, scenario.subsequences_completed,
                     error_count, fatal_count);
            $display("TEST_RESULT: PASS");
            phase.drop_objection(this);
        endtask
    endclass
endpackage
