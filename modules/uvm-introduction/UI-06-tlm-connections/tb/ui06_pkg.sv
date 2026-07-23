package ui06_pkg;
    import uvm_pkg::*;
    `include "uvm_macros.svh"

    class ui06_item extends uvm_object; // This is our transaction object
        `uvm_object_utils(ui06_item)
        int id;
        int payload;
        function new(string name = "ui06_item"); super.new(name); endfunction
    endclass

    class ui06_producer extends uvm_component; // This is our "driver"
        `uvm_component_utils(ui06_producer)
        uvm_blocking_put_port #(ui06_item) item_out; // Establish blocking output ports
        uvm_blocking_put_port #(ui06_item) audit_out;
        function new(string name, uvm_component parent);
            super.new(name, parent);
            item_out = new("item_out", this); // Instantiate them in new()
            audit_out = new("audit_out", this);
        endfunction
        task run_phase(uvm_phase phase);
            ui06_item item;
            item = ui06_item::type_id::create("item");
            item.id = 7;
            item.payload = 42;
            item_out.put(item); // Output them
            audit_out.put(item);
            `uvm_info("UI06_PRODUCER", "published id=7 payload=42", UVM_LOW)
        endtask
    endclass

    class ui06_consumer extends uvm_component;
        `uvm_component_utils(ui06_consumer)
        uvm_blocking_get_port #(ui06_item) item_in;
        uvm_barrier done_barrier;
        int checks;
        function new(string name, uvm_component parent);
            super.new(name, parent);
            item_in = new("item_in", this);
        endfunction
        task run_phase(uvm_phase phase);
            ui06_item item;
            item_in.get(item);
            if ((item.id != 7) || (item.payload != 42))
                `uvm_fatal("UI06_CONSUMER", "consumer received incorrect item")
            checks++;
            `uvm_info("UI06_CONSUMER", "checked FIFO item", UVM_LOW)
            done_barrier.wait_for();
        endtask
    endclass

    class ui06_audit_sink extends uvm_component;
        `uvm_component_utils(ui06_audit_sink)
        uvm_blocking_put_imp #(ui06_item, ui06_audit_sink) in_imp;
        uvm_barrier done_barrier;
        int checks;
        function new(string name, uvm_component parent);
            super.new(name, parent); 
            in_imp = new("in_imp", this);
        endfunction
        task put(ui06_item item);
            if ((item.id != 7) || (item.payload != 42))
                `uvm_fatal("UI06_AUDIT", "audit received incorrect item")
            checks++;
            `uvm_info("UI06_AUDIT", "checked direct put item", UVM_LOW)
            done_barrier.wait_for();
        endtask
    endclass

    class ui06_env extends uvm_env;
        `uvm_component_utils(ui06_env)
        uvm_barrier done_barrier;
        ui06_producer producer;
        ui06_consumer consumer;
        ui06_audit_sink audit;
        uvm_tlm_fifo #(ui06_item) fifo;
        function new(string name, uvm_component parent); super.new(name, parent); endfunction
        function void build_phase(uvm_phase phase);
            super.build_phase(phase);
            if (done_barrier == null) `uvm_fatal("UI06_CFG", "done_barrier missing")
            producer = ui06_producer::type_id::create("producer", this);
            consumer = ui06_consumer::type_id::create("consumer", this);
            audit = ui06_audit_sink::type_id::create("audit", this);
            fifo = new("fifo", this, 1);
            consumer.done_barrier = done_barrier;
            audit.done_barrier = done_barrier;
        endfunction
        function void connect_phase(uvm_phase phase);
            super.connect_phase(phase);
            // TODO: connect producer.item_out to fifo.put_export.
            producer.item_out.connect(fifo.put_export);
            // TODO: connect consumer.item_in to fifo.get_export.
            consumer.item_in.connect(fifo.get_export);
            // TODO: connect producer.audit_out to audit.in_imp.
            producer.audit_out.connect(audit.in_imp);
        endfunction
    endclass

    class ui06_tlm_test extends uvm_test;
        `uvm_component_utils(ui06_tlm_test)
        uvm_barrier done_barrier;
        ui06_env env;
        function new(string name, uvm_component parent); super.new(name, parent); endfunction
        function void build_phase(uvm_phase phase);
            super.build_phase(phase);
            done_barrier = new("done_barrier", 3);
            env = ui06_env::type_id::create("env", this);
            env.done_barrier = done_barrier;
        endfunction
        task run_phase(uvm_phase phase);
            phase.raise_objection(this);
            done_barrier.wait_for();
            if ((env.consumer.checks != 1) || (env.audit.checks != 1))
                `uvm_fatal("UI06_COUNT", "each destination must check exactly one item")
            $display("TLM_TRACE: consumer_checks=%0d audit_checks=%0d fifo_used=%0d",
                     env.consumer.checks, env.audit.checks, env.fifo.used());
            $display("TEST_RESULT: PASS");
            phase.drop_objection(this);
        endtask
    endclass
endpackage
