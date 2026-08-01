package ua05_fixture_pkg;
    import uvm_pkg::*;
    import ua05_pkg::*;
    `include "uvm_macros.svh"

    class ua05_reference_parallel_sequence extends ua05_parallel_sequence;
        `uvm_object_utils(ua05_reference_parallel_sequence)
        function new(string name = "ua05_reference_parallel_sequence");
            super.new(name);
        endfunction
        task body();
            prepare_children();
            fork
                first.start(m_sequencer, this);
                second.start(m_sequencer, this);
            join
        endtask
    endclass

    class ua05_sequential_sequence extends ua05_parallel_sequence;
        `uvm_object_utils(ua05_sequential_sequence)
        function new(string name = "ua05_sequential_sequence");
            super.new(name);
        endfunction
        task body();
            prepare_children();
            first.start(m_sequencer, this);
            second.start(m_sequencer, this);
        endtask
    endclass

    class ua05_valid_fixture_test extends ua05_test;
        `uvm_component_utils(ua05_valid_fixture_test)
        function new(string name, uvm_component parent);
            super.new(name, parent);
        endfunction
        virtual function void configure();
            ua05_parallel_sequence::type_id::set_type_override(
                ua05_reference_parallel_sequence::get_type());
        endfunction
    endclass

    class ua05_sequential_child_test extends ua05_test;
        `uvm_component_utils(ua05_sequential_child_test)
        function new(string name, uvm_component parent);
            super.new(name, parent);
        endfunction
        virtual function void configure();
            ua05_parallel_sequence::type_id::set_type_override(
                ua05_sequential_sequence::get_type());
        endfunction
    endclass
endpackage
