package ua08_support_pkg;
    import uvm_pkg::*;
    `include "uvm_macros.svh"

    class ua08_bus_item extends uvm_sequence_item;
        `uvm_object_utils(ua08_bus_item)
        uvm_access_e kind;
        uvm_reg_addr_t addr;
        uvm_reg_data_t data;
        uvm_status_e status;
        function new(string name = "ua08_bus_item");
            super.new(name);
            status = UVM_NOT_OK;
        endfunction
    endclass

    class ua08_bus_sequencer extends uvm_sequencer #(ua08_bus_item);
        `uvm_component_utils(ua08_bus_sequencer)
        function new(string name, uvm_component parent);
            super.new(name, parent);
        endfunction
    endclass

    class ua08_bus_driver extends uvm_driver #(ua08_bus_item);
        `uvm_component_utils(ua08_bus_driver)
        uvm_analysis_port #(ua08_bus_item) completed_ap;
        uvm_reg_data_t stored_control;
        int unsigned completed;

        function new(string name, uvm_component parent);
            super.new(name, parent);
            completed_ap = new("completed_ap", this);
        endfunction

        task run_phase(uvm_phase phase);
            ua08_bus_item req;
            forever begin
                seq_item_port.get_next_item(req);
                #1ns;
                if (req.addr == 'h0) begin
                    if (req.kind == UVM_WRITE)
                        stored_control = req.data;
                    else
                        req.data = stored_control;
                    req.status = UVM_IS_OK;
                end else begin
                    req.status = UVM_NOT_OK;
                end
                completed++;
                completed_ap.write(req);
                seq_item_port.item_done();
            end
        endtask
    endclass

    class ua08_reg_adapter extends uvm_reg_adapter;
        `uvm_object_utils(ua08_reg_adapter)
        function new(string name = "ua08_reg_adapter");
            super.new(name);
            provides_responses = 0;
        endfunction

        virtual function uvm_sequence_item reg2bus(const ref uvm_reg_bus_op rw);
            ua08_bus_item item;
            item = ua08_bus_item::type_id::create("item");
            item.kind = rw.kind;
            item.addr = rw.addr;
            item.data = rw.data;
            item.status = UVM_NOT_OK;
            return item;
        endfunction

        virtual function void bus2reg(uvm_sequence_item bus_item,
                                      ref uvm_reg_bus_op rw);
            ua08_bus_item item;
            if (!$cast(item, bus_item))
                `uvm_fatal("UA08_ADAPTER", "adapter received the wrong bus item type")
            rw.kind = item.kind;
            rw.addr = item.addr;
            rw.data = item.data;
            rw.status = item.status;
        endfunction
    endclass
endpackage
