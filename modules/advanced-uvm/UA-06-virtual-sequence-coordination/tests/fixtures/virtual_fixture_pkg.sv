package ua06_fixture_pkg;
    import uvm_pkg::*;
    import ua06_pkg::*;
    `include "uvm_macros.svh"

    class ua06_reference_virtual_sequence extends ua06_virtual_sequence;
        `uvm_object_utils(ua06_reference_virtual_sequence)
        function new(string name = "ua06_reference_virtual_sequence");
            super.new(name);
        endfunction
        task body();
            prepare_children();
            if (p_sequencer == null)
                `uvm_fatal("UA06_VSEQR", "virtual sequence did not receive a virtual sequencer")
            if ((p_sequencer.control_sequencer == null) ||
                (p_sequencer.data_sequencer == null))
                `uvm_fatal("UA06_VSEQR", "virtual sequencer is missing a physical sequencer handle")
            fork
                control_sequence.start(p_sequencer.control_sequencer, this);
                data_sequence.start(p_sequencer.data_sequencer, this);
            join
        endtask
    endclass

    class ua06_reference_env extends ua06_env;
        `uvm_component_utils(ua06_reference_env)
        function new(string name, uvm_component parent);
            super.new(name, parent);
        endfunction
        function void connect_phase(uvm_phase phase);
            control_driver.seq_item_port.connect(control_sequencer.seq_item_export);
            data_driver.seq_item_port.connect(data_sequencer.seq_item_export);
            virtual_sequencer.control_sequencer = control_sequencer;
            virtual_sequencer.data_sequencer = data_sequencer;
        endfunction
    endclass

    class ua06_missing_data_env extends ua06_env;
        `uvm_component_utils(ua06_missing_data_env)
        function new(string name, uvm_component parent);
            super.new(name, parent);
        endfunction
        function void connect_phase(uvm_phase phase);
            control_driver.seq_item_port.connect(control_sequencer.seq_item_export);
            data_driver.seq_item_port.connect(data_sequencer.seq_item_export);
            virtual_sequencer.control_sequencer = control_sequencer;
        endfunction
    endclass

    class ua06_valid_fixture_test extends ua06_test;
        `uvm_component_utils(ua06_valid_fixture_test)
        function new(string name, uvm_component parent);
            super.new(name, parent);
        endfunction
        virtual function void configure();
            ua06_env::type_id::set_type_override(ua06_reference_env::get_type());
            ua06_virtual_sequence::type_id::set_type_override(
                ua06_reference_virtual_sequence::get_type());
        endfunction
    endclass

    class ua06_missing_data_handle_test extends ua06_test;
        `uvm_component_utils(ua06_missing_data_handle_test)
        function new(string name, uvm_component parent);
            super.new(name, parent);
        endfunction
        virtual function void configure();
            ua06_env::type_id::set_type_override(ua06_missing_data_env::get_type());
            ua06_virtual_sequence::type_id::set_type_override(
                ua06_reference_virtual_sequence::get_type());
        endfunction
    endclass
endpackage
