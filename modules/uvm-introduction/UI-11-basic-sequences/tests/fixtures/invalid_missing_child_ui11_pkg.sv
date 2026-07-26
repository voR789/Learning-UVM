package ui11_pkg;
    import uvm_pkg::*;
    `include "uvm_macros.svh"

    class ui11_item extends uvm_sequence_item;
        `uvm_object_utils(ui11_item)
        int id;

        function new(string name = "item");
            super.new(name);
        endfunction
    endclass

    class ui11_burst_sequence extends uvm_sequence #(ui11_item);
        `uvm_object_utils(ui11_burst_sequence)

        function new(string name = "burst");
            super.new(name);
        endfunction

        task body();
            ui11_item req;

            for (int i = 0; i < 3; i++) begin
                req = ui11_item::type_id::create("req");
                start_item(req);
                req.id = i;
                finish_item(req);
            end
        endtask
    endclass

    class ui11_composite_sequence extends uvm_sequence #(ui11_item);
        `uvm_object_utils(ui11_composite_sequence)

        function new(string name = "composite");
            super.new(name);
        endfunction

        task body();
            ui11_burst_sequence first;

            first = ui11_burst_sequence::type_id::create("first");
            first.start(m_sequencer, this);

            // Intentional fault: the second child sequence is omitted.
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

        function new(string name, uvm_component parent);
            super.new(name, parent);
        endfunction

        task run_phase(uvm_phase phase);
            ui11_item req;

            for (int i = 0; i < 6; i++) begin
                seq_item_port.get_next_item(req);
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
            sequencer = ui11_sequencer::type_id::create("sequencer", this);
            driver = ui11_driver::type_id::create("driver", this);
        endfunction

        function void connect_phase(uvm_phase phase);
            super.connect_phase(phase);
            driver.seq_item_port.connect(sequencer.seq_item_export);
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
            env = ui11_env::type_id::create("env", this);
        endfunction

        task run_phase(uvm_phase phase);
            ui11_composite_sequence scenario;

            phase.raise_objection(this);
            scenario = ui11_composite_sequence::type_id::create("scenario");
            scenario.start(env.sequencer);

            // This point is reached after the first child returns, but the
            // driver remains blocked waiting for items four through six.
            #2us;
            $display("TEST_RESULT: PASS");
            phase.drop_objection(this);
        endtask
    endclass
endpackage
