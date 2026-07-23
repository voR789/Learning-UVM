package ui07_pkg;
    import uvm_pkg::*;
    `include "uvm_macros.svh"

    class ui07_item extends uvm_sequence_item;
        `uvm_object_utils(ui07_item)
        int id;
        int payload;
        function new(string name="ui07_item"); super.new(name); endfunction
    endclass

    class ui07_sequence extends uvm_sequence #(ui07_item);
        `uvm_object_utils(ui07_sequence)
        function new(string name="ui07_sequence"); super.new(name); endfunction
        task body();
            ui07_item req;
            for (int i=0; i<3; i++) begin
                req = ui07_item::type_id::create($sformatf("req_%0d", i));
                // TODO: request permission with start_item(req).
                req.id = i;
                req.payload = (i+1)*10;
                // TODO: submit and wait for completion with finish_item(req).
            end
        endtask
    endclass

    class ui07_sequencer extends uvm_sequencer #(ui07_item);
        `uvm_component_utils(ui07_sequencer)
        function new(string name,uvm_component parent);super.new(name,parent);endfunction
    endclass

    class ui07_driver extends uvm_driver #(ui07_item);
        `uvm_component_utils(ui07_driver)
        int completed;
        function new(string name,uvm_component parent);super.new(name,parent);endfunction
        task run_phase(uvm_phase phase);
            ui07_item req;
            for (int expected_id=0; expected_id<3; expected_id++) begin
                // TODO: block for the next request with get_next_item(req).
                if ((req.id != expected_id) || (req.payload != (expected_id+1)*10))
                    `uvm_fatal("UI07_DRIVER","request order or payload mismatch")
                completed++;
                `uvm_info("UI07_DRIVER",$sformatf("completed id=%0d payload=%0d",req.id,req.payload),UVM_LOW)
                // TODO: acknowledge completion with item_done().
            end
        endtask
    endclass

    class ui07_agent extends uvm_agent;
        `uvm_component_utils(ui07_agent)
        ui07_sequencer sequencer;
        ui07_driver driver;
        function new(string name,uvm_component parent);super.new(name,parent);endfunction
        function void build_phase(uvm_phase phase);
            super.build_phase(phase);
            sequencer=ui07_sequencer::type_id::create("sequencer",this);
            driver=ui07_driver::type_id::create("driver",this);
        endfunction
        function void connect_phase(uvm_phase phase);
            super.connect_phase(phase);
            // TODO: connect driver.seq_item_port to sequencer.seq_item_export.
        endfunction
    endclass

    class ui07_test extends uvm_test;
        `uvm_component_utils(ui07_test)
        ui07_agent agent;
        function new(string name,uvm_component parent);super.new(name,parent);endfunction
        function void build_phase(uvm_phase phase);
            super.build_phase(phase);
            agent=ui07_agent::type_id::create("agent",this);
        endfunction
        task run_phase(uvm_phase phase);
            ui07_sequence seq;
            phase.raise_objection(this);
            seq=ui07_sequence::type_id::create("seq");
            seq.start(agent.sequencer);
            if (agent.driver.completed != 3)
                `uvm_fatal("UI07_COUNT","driver must complete exactly three items")
            $display("HANDSHAKE_TRACE: completed=%0d",agent.driver.completed);
            $display("TEST_RESULT: PASS");
            phase.drop_objection(this);
        endtask
    endclass
endpackage
