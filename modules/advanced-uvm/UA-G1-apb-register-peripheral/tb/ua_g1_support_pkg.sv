package ua_g1_support_pkg;
    import uvm_pkg::*;
    `include "uvm_macros.svh"

    localparam uvm_reg_addr_t CTRL_ADDR   = 'h00;
    localparam uvm_reg_addr_t GAIN_ADDR   = 'h04;
    localparam uvm_reg_addr_t DATA_ADDR   = 'h08;
    localparam uvm_reg_addr_t STATUS_ADDR = 'h0C;
    localparam uvm_reg_addr_t RESULT_ADDR = 'h10;

    class ua_g1_apb_item extends uvm_sequence_item;
        `uvm_object_utils(ua_g1_apb_item)
        bit                write;
        uvm_reg_addr_t     addr;
        uvm_reg_data_t     wdata;
        uvm_reg_data_t     rdata;
        bit                error;

        function new(string name = "ua_g1_apb_item");
            super.new(name);
        endfunction

        function string convert2string();
            return $sformatf("write=%0b addr=0x%0h wdata=0x%0h rdata=0x%0h error=%0b",
                write, addr, wdata, rdata, error);
        endfunction
    endclass

    class ua_g1_apb_sequencer extends uvm_sequencer #(ua_g1_apb_item);
        `uvm_component_utils(ua_g1_apb_sequencer)
        function new(string name, uvm_component parent);
            super.new(name, parent);
        endfunction
    endclass

    class ua_g1_apb_driver extends uvm_driver #(ua_g1_apb_item);
        `uvm_component_utils(ua_g1_apb_driver)
        virtual apb_if vif;
        int unsigned driven;

        function new(string name, uvm_component parent);
            super.new(name, parent);
        endfunction

        function void build_phase(uvm_phase phase);
            super.build_phase(phase);
            if (!uvm_config_db #(virtual apb_if)::get(this, "", "vif", vif))
                `uvm_fatal("UAG1_VIF", "driver did not receive apb_if")
        endfunction

        task run_phase(uvm_phase phase);
            ua_g1_apb_item req;
            wait (vif.presetn === 1'b1);
            forever begin
                seq_item_port.get_next_item(req);

                @(negedge vif.pclk);
                vif.psel    = 1'b1;
                vif.penable = 1'b0;
                vif.pwrite  = req.write;
                vif.paddr   = req.addr[7:0];
                vif.pwdata  = req.wdata;

                @(negedge vif.pclk);
                vif.penable = 1'b1;

                @(posedge vif.pclk);
                while (!vif.pready)
                    @(posedge vif.pclk);
                req.rdata = vif.prdata;
                req.error = vif.pslverr;
                driven++;

                @(negedge vif.pclk);
                vif.psel    = 1'b0;
                vif.penable = 1'b0;
                vif.pwrite  = 1'b0;
                vif.paddr   = '0;
                vif.pwdata  = '0;
                seq_item_port.item_done();
            end
        endtask
    endclass

    class ua_g1_reg_adapter extends uvm_reg_adapter;
        `uvm_object_utils(ua_g1_reg_adapter)

        function new(string name = "ua_g1_reg_adapter");
            super.new(name);
            provides_responses = 0;
        endfunction

        virtual function uvm_sequence_item reg2bus(const ref uvm_reg_bus_op rw);
            ua_g1_apb_item item;
            item = ua_g1_apb_item::type_id::create("item");
            item.write = (rw.kind == UVM_WRITE);
            item.addr = rw.addr;
            item.wdata = rw.data;
            return item;
        endfunction

        virtual function void bus2reg(uvm_sequence_item bus_item,
                                      ref uvm_reg_bus_op rw);
            ua_g1_apb_item item;
            if (!$cast(item, bus_item))
                `uvm_fatal("UAG1_ADAPTER", "adapter received wrong item type")
            rw.kind = item.write ? UVM_WRITE : UVM_READ;
            rw.addr = item.addr;
            rw.data = item.write ? item.wdata : item.rdata;
            rw.status = item.error ? UVM_NOT_OK : UVM_IS_OK;
        endfunction
    endclass

    class ua_g1_value_reg extends uvm_reg;
        `uvm_object_utils(ua_g1_value_reg)
        uvm_reg_field value;
        string access_policy;

        function new(string name = "ua_g1_value_reg");
            super.new(name, 32, UVM_NO_COVERAGE);
            access_policy = "RW";
        endfunction

        virtual function void build();
            value = new("value");
            value.configure(this, 32, 0, access_policy, 0, 0, 1, 0, 0);
        endfunction
    endclass

    class ua_g1_reg_block extends uvm_reg_block;
        `uvm_object_utils(ua_g1_reg_block)
        ua_g1_value_reg control;
        ua_g1_value_reg gain;
        ua_g1_value_reg data;
        ua_g1_value_reg status;
        ua_g1_value_reg result;

        function new(string name = "ua_g1_reg_block");
            super.new(name, UVM_NO_COVERAGE);
        endfunction

        virtual function void build();
            control = new("control");
            gain = new("gain");
            data = new("data");
            status = new("status");
            result = new("result");

            control.access_policy = "RW";
            gain.access_policy = "RW";
            data.access_policy = "WO";
            status.access_policy = "RO";
            result.access_policy = "RO";

            control.configure(this, null, "");
            gain.configure(this, null, "");
            data.configure(this, null, "");
            status.configure(this, null, "");
            result.configure(this, null, "");
            control.build();
            gain.build();
            data.build();
            status.build();
            result.build();

            default_map = create_map("default_map", 'h0, 4,
                UVM_LITTLE_ENDIAN, 1);
            default_map.add_reg(control, CTRL_ADDR, "RW");
            default_map.add_reg(gain, GAIN_ADDR, "RW");
            default_map.add_reg(data, DATA_ADDR, "WO");
            default_map.add_reg(status, STATUS_ADDR, "RO");
            default_map.add_reg(result, RESULT_ADDR, "RO");
            lock_model();
        endfunction
    endclass
endpackage
