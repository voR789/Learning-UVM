package ua03_fixture_pkg;
    import uvm_pkg::*;
    import ua03_pkg::*;
    `include "uvm_macros.svh"

    class ua03_full_burst_cmd extends ua03_burst_cmd;
        `uvm_object_utils(ua03_full_burst_cmd)

        function new(string name = "ua03_full_burst_cmd");
            super.new(name);
        endfunction

        virtual function bit is_valid();
            return ((address[1:0] == 2'b00) &&
                    ((kind == UA03_READ) || (kind == UA03_WRITE)) &&
                    ((burst_len == 2) || (burst_len == 4) || (burst_len == 8)) &&
                    (byte_stride == 4));
        endfunction

        virtual function void do_copy(uvm_object rhs);
            ua03_full_burst_cmd rhs_burst;
            if (!$cast(rhs_burst, rhs)) return;
            address = rhs_burst.address;
            kind = rhs_burst.kind;
            burst_len = rhs_burst.burst_len;
            byte_stride = rhs_burst.byte_stride;
        endfunction

        virtual function bit do_compare(uvm_object rhs, uvm_comparer comparer);
            ua03_full_burst_cmd rhs_burst;
            if (!$cast(rhs_burst, rhs)) return 1'b0;
            return (address == rhs_burst.address) && (kind == rhs_burst.kind) &&
                   (burst_len == rhs_burst.burst_len) &&
                   (byte_stride == rhs_burst.byte_stride);
        endfunction
    endclass

    class ua03_extension_loss_cmd extends ua03_full_burst_cmd;
        `uvm_object_utils(ua03_extension_loss_cmd)

        function new(string name = "ua03_extension_loss_cmd");
            super.new(name);
        endfunction

        virtual function void do_copy(uvm_object rhs);
            ua03_full_burst_cmd rhs_burst;
            if (!$cast(rhs_burst, rhs)) return;
            address = rhs_burst.address;
            kind = rhs_burst.kind;
            // Deliberately omit burst_len and byte_stride.
        endfunction
    endclass

    class ua03_valid_fixture_test extends ua03_copy_test;
        `uvm_component_utils(ua03_valid_fixture_test)
        function new(string name, uvm_component parent);
            super.new(name, parent);
        endfunction
        virtual function void configure();
            ua03_burst_cmd::type_id::set_type_override(
                ua03_full_burst_cmd::get_type());
        endfunction
    endclass

    class ua03_extension_loss_test extends ua03_copy_test;
        `uvm_component_utils(ua03_extension_loss_test)
        function new(string name, uvm_component parent);
            super.new(name, parent);
        endfunction
        virtual function void configure();
            ua03_burst_cmd::type_id::set_type_override(
                ua03_extension_loss_cmd::get_type());
        endfunction
    endclass
endpackage
