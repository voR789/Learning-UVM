package memory_fixture_pkg;
    import uvm_pkg::*;
    import ua10_support_pkg::*;
    import ua10_pkg::*;
    `include "uvm_macros.svh"

    class ua10_reference_seq extends ua10_memory_check_seq;
        `uvm_object_utils(ua10_reference_seq)
        function new(string name = "ua10_reference_seq");
            super.new(name);
        endfunction

        virtual task body();
            uvm_status_e status;
            uvm_reg_data_t observed;
            uvm_reg_data_t expected0;
            uvm_reg_data_t expected1;

            if (model == null)
                `uvm_fatal("UA10_MODEL", "sequence register model is null")
            expected0 = 32'hD00D_0001;
            expected1 = 32'hC0DE_0002;

            model.scratch.write(status, 0, expected0, UVM_FRONTDOOR,
                model.default_map, this);
            if (status != UVM_IS_OK)
                `uvm_fatal("UA10_STATUS", "write to scratch index 0 failed")

            model.scratch.write(status, 1, expected1, UVM_FRONTDOOR,
                model.default_map, this);
            if (status != UVM_IS_OK)
                `uvm_fatal("UA10_STATUS", "write to scratch index 1 failed")

            model.scratch.read(status, 0, observed, UVM_FRONTDOOR,
                model.default_map, this);
            if (status != UVM_IS_OK)
                `uvm_fatal("UA10_STATUS", "read from scratch index 0 failed")
            if (observed != expected0)
                `uvm_fatal("UA10_DATA", $sformatf(
                    "index 0 expected=0x%0h observed=0x%0h",
                    expected0, observed))
            verified++;

            model.scratch.read(status, 1, observed, UVM_FRONTDOOR,
                model.default_map, this);
            if (status != UVM_IS_OK)
                `uvm_fatal("UA10_STATUS", "read from scratch index 1 failed")
            if (observed != expected1)
                `uvm_fatal("UA10_DATA", $sformatf(
                    "index 1 expected=0x%0h observed=0x%0h",
                    expected1, observed))
            verified++;
        endtask
    endclass

    class ua10_alias_driver extends ua10_bus_driver;
        `uvm_component_utils(ua10_alias_driver)
        function new(string name, uvm_component parent);
            super.new(name, parent);
        endfunction

        virtual function bit decode_index(uvm_reg_addr_t addr,
                                          output int unsigned index);
            int unsigned decoded;
            if (!super.decode_index(addr, decoded)) begin
                index = 0;
                return 0;
            end
            index = 0;
            return 1;
        endfunction
    endclass

    class ua10_reference_test extends ua10_test;
        `uvm_component_utils(ua10_reference_test)
        function new(string name, uvm_component parent);
            super.new(name, parent);
        endfunction

        virtual function ua10_memory_check_seq create_memory_sequence();
            return ua10_reference_seq::type_id::create("seq");
        endfunction
    endclass

    class ua10_alias_memory_test extends ua10_reference_test;
        `uvm_component_utils(ua10_alias_memory_test)
        function new(string name, uvm_component parent);
            super.new(name, parent);
        endfunction

        function void build_phase(uvm_phase phase);
            ua10_bus_driver::type_id::set_type_override(
                ua10_alias_driver::get_type());
            super.build_phase(phase);
        endfunction
    endclass
endpackage
