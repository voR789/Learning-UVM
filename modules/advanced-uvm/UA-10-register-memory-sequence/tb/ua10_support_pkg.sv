package ua10_support_pkg;
    import uvm_pkg::*;
    `include "uvm_macros.svh"

    class ua10_bus_item extends uvm_sequence_item;
        `uvm_object_utils(ua10_bus_item)
        uvm_access_e kind;
        uvm_reg_addr_t addr;
        uvm_reg_data_t data;
        uvm_status_e status;

        function new(string name = "ua10_bus_item");
            super.new(name);
            status = UVM_NOT_OK;
        endfunction
    endclass

    class ua10_bus_sequencer extends uvm_sequencer #(ua10_bus_item);
        `uvm_component_utils(ua10_bus_sequencer)
        function new(string name, uvm_component parent);
            super.new(name, parent);
        endfunction
    endclass

    class ua10_bus_driver extends uvm_driver #(ua10_bus_item);
        `uvm_component_utils(ua10_bus_driver)
        uvm_reg_data_t storage[4];
        int unsigned completed;
        int unsigned reads_by_index[4];
        int unsigned writes_by_index[4];

        function new(string name, uvm_component parent);
            super.new(name, parent);
        endfunction

        virtual function bit decode_index(uvm_reg_addr_t addr,
                                          output int unsigned index);
            if ((addr < 'h10) || (addr > 'h1C) ||
                (((addr - 'h10) % 4) != 0)) begin
                index = 0;
                return 0;
            end
            index = (addr - 'h10) / 4;
            return 1;
        endfunction

        task run_phase(uvm_phase phase);
            ua10_bus_item req;
            int unsigned index;
            forever begin
                seq_item_port.get_next_item(req);
                #1ns;
                if (decode_index(req.addr, index)) begin
                    if (req.kind == UVM_WRITE) begin
                        storage[index] = req.data;
                        writes_by_index[index]++;
                    end else begin
                        req.data = storage[index];
                        reads_by_index[index]++;
                    end
                    req.status = UVM_IS_OK;
                end else begin
                    req.status = UVM_NOT_OK;
                end
                completed++;
                seq_item_port.item_done();
            end
        endtask
    endclass

    class ua10_reg_adapter extends uvm_reg_adapter;
        `uvm_object_utils(ua10_reg_adapter)
        function new(string name = "ua10_reg_adapter");
            super.new(name);
            provides_responses = 0;
        endfunction

        virtual function uvm_sequence_item reg2bus(const ref uvm_reg_bus_op rw);
            ua10_bus_item item;
            item = ua10_bus_item::type_id::create("item");
            item.kind = rw.kind;
            item.addr = rw.addr;
            item.data = rw.data;
            item.status = UVM_NOT_OK;
            return item;
        endfunction

        virtual function void bus2reg(uvm_sequence_item bus_item,
                                      ref uvm_reg_bus_op rw);
            ua10_bus_item item;
            if (!$cast(item, bus_item))
                `uvm_fatal("UA10_ADAPTER", "adapter received the wrong item type")
            rw.kind = item.kind;
            rw.addr = item.addr;
            rw.data = item.data;
            rw.status = item.status;
        endfunction
    endclass

    class ua10_reg_block extends uvm_reg_block;
        `uvm_object_utils(ua10_reg_block)
        uvm_mem scratch;

        function new(string name = "ua10_reg_block");
            super.new(name, UVM_NO_COVERAGE);
        endfunction

        virtual function void build();
            scratch = new("scratch", 4, 32, "RW", UVM_NO_COVERAGE); // KEY idea: use basic instantiation (new()) because block "owns" the mem. Only use factory when replacement is a real goal
            scratch.configure(this, "");
            default_map = create_map("default_map", 'h0, 4,
                UVM_LITTLE_ENDIAN, 1);
            default_map.add_mem(scratch, 'h10, "RW");
            lock_model();
        endfunction
    endclass

    class ua10_env extends uvm_env;
        `uvm_component_utils(ua10_env)
        ua10_bus_sequencer sequencer;
        ua10_bus_driver driver;
        ua10_reg_adapter adapter;
        ua10_reg_block model;

        function new(string name, uvm_component parent);
            super.new(name, parent);
        endfunction

        function void build_phase(uvm_phase phase);
            super.build_phase(phase);
            sequencer = ua10_bus_sequencer::type_id::create("sequencer", this);
            driver = ua10_bus_driver::type_id::create("driver", this);
            adapter = ua10_reg_adapter::type_id::create("adapter");
            model = ua10_reg_block::type_id::create("model");
            model.build();
        endfunction

        function void connect_phase(uvm_phase phase);
            super.connect_phase(phase);
            driver.seq_item_port.connect(sequencer.seq_item_export);
            model.default_map.set_sequencer(sequencer, adapter);
        endfunction
    endclass
endpackage
