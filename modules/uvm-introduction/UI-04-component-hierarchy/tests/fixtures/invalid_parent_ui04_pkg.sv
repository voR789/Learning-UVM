package ui04_pkg;
    import uvm_pkg::*;
    `include "uvm_macros.svh"
    class ui04_leaf extends uvm_component;
        `uvm_component_utils(ui04_leaf)
        function new(string name, uvm_component parent); super.new(name, parent); endfunction
    endclass
    class ui04_container extends uvm_component;
        `uvm_component_utils(ui04_container)
        ui04_leaf leaf;
        function new(string name, uvm_component parent); super.new(name, parent); endfunction
        function void build_phase(uvm_phase phase);
            super.build_phase(phase);
            leaf = ui04_leaf::type_id::create("leaf", get_parent());
        endfunction
    endclass
    class ui04_hierarchy_test extends uvm_test;
        `uvm_component_utils(ui04_hierarchy_test)
        ui04_container container;
        function new(string name, uvm_component parent); super.new(name, parent); endfunction
        function void build_phase(uvm_phase phase);
            super.build_phase(phase);
            container = ui04_container::type_id::create("container", this);
        endfunction
        task run_phase(uvm_phase phase);
            phase.raise_objection(this);
            uvm_top.print_topology();
            if (container.leaf.get_full_name() != "uvm_test_top.container.leaf") begin
                $display("TEST_RESULT: FAIL wrong_parent actual=%s", container.leaf.get_full_name());
                `uvm_fatal("UI04_HIER", "leaf attached to wrong parent")
            end
            $display("TEST_RESULT: PASS");
            phase.drop_objection(this);
        endtask
    endclass
endpackage
