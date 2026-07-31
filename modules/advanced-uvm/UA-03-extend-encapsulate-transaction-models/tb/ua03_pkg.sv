package ua03_pkg;
    import uvm_pkg::*;
    `include "uvm_macros.svh"

    typedef enum int unsigned {UA03_READ, UA03_WRITE} ua03_kind_e;

    class ua03_cmd extends uvm_sequence_item;
        `uvm_object_utils(ua03_cmd)
        protected bit [7:0] address;
        protected ua03_kind_e kind;

        function new(string name = "ua03_cmd");
            super.new(name);
        endfunction

        function void configure_cmd(bit [7:0] configured_address,
                                    ua03_kind_e configured_kind);
            address = configured_address;
            kind = configured_kind;
        endfunction

        function bit is_valid();
            return ((address[1:0] == 2'b00) &&
                    ((kind == UA03_READ) || (kind == UA03_WRITE)));
        endfunction

        virtual function void do_copy(uvm_object rhs); //  UVM object method
            ua03_cmd rhs_cmd; // Create a safe handle to access cmd object properties
            if (!$cast(rhs_cmd, rhs)) begin // cast it
                `uvm_error("UA03_TYPE", "base copy received an incompatible object")
                return;
            end
            super.do_copy(rhs); // Call do copy on the parent handle
            address = rhs_cmd.address; // Copy over data on the child handle
            kind = rhs_cmd.kind;
        endfunction

        virtual function bit do_compare(uvm_object rhs, uvm_comparer comparer); //  UVM object method
            ua03_cmd rhs_cmd;
            if (!$cast(rhs_cmd, rhs)) return 1'b0;
            return super.do_compare(rhs, comparer) &&
                   (address == rhs_cmd.address) && (kind == rhs_cmd.kind);
        endfunction

        virtual function string convert2string(); //  UVM object method
            return $sformatf("addr=0x%0h kind=%s", address,
                (kind == UA03_WRITE) ? "WRITE" : "READ");
        endfunction
    endclass

    class ua03_burst_cmd extends ua03_cmd;
        `uvm_object_utils(ua03_burst_cmd)
        protected int unsigned burst_len;
        protected int unsigned byte_stride;

        function new(string name = "ua03_burst_cmd");
            super.new(name);
        endfunction

        function void configure_burst(int unsigned configured_len,
                                      int unsigned configured_stride);
            burst_len = configured_len;
            byte_stride = configured_stride;
        endfunction

        virtual function bit is_valid();
            // TODO: Preserve the base contract and add the burst contract:
            // length is 2, 4, or 8; stride is four bytes.
            return (super.is_valid() && (burst_len inside {2,4,8}) && byte_stride == 4);
        endfunction

        virtual function void do_copy(uvm_object rhs);
            ua03_burst_cmd rhs_burst;
            // TODO: Check the derived source type, copy the base portion,
            // then preserve both burst fields.
            if(!$cast(rhs_burst, rhs)) begin
                `uvm_error("UA03_TYPE", "derived copy recieved incompatible object")
                return;
            end
            super.do_copy(rhs);
            burst_len = rhs_burst.burst_len;
            byte_stride = rhs_burst.byte_stride;

        endfunction

        virtual function bit do_compare(uvm_object rhs, uvm_comparer comparer);
            ua03_burst_cmd rhs_burst;
            // TODO: Reject an incompatible object, require base equivalence,
            // then compare both burst fields.
            if(!$cast(rhs_burst, rhs)) begin
                `uvm_error("UA03_TYPE", "derived compare recieved incompatible object")
                return 1'b0;
            end
            return (super.do_compare(rhs, comparer) && (rhs_burst.burst_len == burst_len) && (rhs_burst.byte_stride == byte_stride));
        endfunction

        virtual function string convert2string();
            return {super.convert2string(),
                    $sformatf(" len=%0d stride=%0d", burst_len, byte_stride)};
        endfunction
    endclass

    class ua03_copy_test extends uvm_test;
        `uvm_component_utils(ua03_copy_test)

        function new(string name, uvm_component parent);
            super.new(name, parent);
        endfunction

        virtual function void configure();
        endfunction

        function void build_phase(uvm_phase phase);
            super.build_phase(phase);
            configure();
        endfunction

        task run_phase(uvm_phase phase);
            ua03_burst_cmd source;
            ua03_burst_cmd cloned;

            phase.raise_objection(this);
            source = ua03_burst_cmd::type_id::create("source");
            cloned = ua03_burst_cmd::type_id::create("cloned");
            source.configure_cmd(8'h20, UA03_WRITE);
            source.configure_burst(4, 4);

            if (!source.is_valid())
                `uvm_fatal("UA03_VALID", "supplied source transaction is invalid")

            cloned.copy(source);
            if (!cloned.compare(source))
                `uvm_error("UA03_COPY", $sformatf("clone lost state: source={%s} clone={%s}",
                    source.convert2string(), cloned.convert2string()))

            cloned.configure_burst(8, 4);
            if (cloned.compare(source))
                `uvm_error("UA03_COMPARE", "burst mutation was not observed")

            $display("UA03_TRACE test=%s source={%s} clone={%s}",
                get_type_name(), source.convert2string(), cloned.convert2string());
            if (uvm_report_server::get_server().get_severity_count(UVM_ERROR) == 0)
                $display("TEST_RESULT: PASS");
            phase.drop_objection(this);
        endtask
    endclass
endpackage
