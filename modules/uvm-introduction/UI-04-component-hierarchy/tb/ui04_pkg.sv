package ui04_pkg;
    import uvm_pkg::*;
    `include "uvm_macros.svh"

    class ui04_leaf extends uvm_component;
        `uvm_component_utils(ui04_leaf) // Use macro to register ui04_leaf

        function new(string name, uvm_component parent);
            super.new(name, parent); // Base constructor, passes info to uvm_component 
        endfunction

        task run_phase(uvm_phase phase);
            `uvm_info("UI04_LEAF", $sformatf("running at %s", get_full_name()), UVM_LOW) // When run, print this
        endtask
    endclass

    class ui04_container extends uvm_component;
        `uvm_component_utils(ui04_container)

        ui04_leaf leaf; // Each container owns a leaf

        function new(string name, uvm_component parent);
            super.new(name, parent);
        endfunction

        function void build_phase(uvm_phase phase);
            super.build_phase(phase);
            leaf = ui04_leaf::type_id::create("leaf", this); // When we are building this, make a leaf instance with this info
        endfunction
    endclass

    class ui04_hierarchy_test extends uvm_test;
        `uvm_component_utils(ui04_hierarchy_test)

        ui04_container container;

        function new(string name, uvm_component parent);
            super.new(name, parent);
        endfunction

        function void build_phase(uvm_phase phase);
            super.build_phase(phase);
            container = ui04_container::type_id::create("container", this);
        endfunction

        task run_phase(uvm_phase phase);
            phase.raise_objection(this);
            uvm_top.print_topology();

            if (container == null)
                `uvm_fatal("UI04_HIER", "uvm_test_top.container was not created")
            if (container.get_full_name() != "uvm_test_top.container")
                `uvm_fatal("UI04_HIER", $sformatf("wrong container path: %s", container.get_full_name()))
            if (container.leaf == null)
                `uvm_fatal("UI04_HIER", "uvm_test_top.container.leaf was not created")
            if (container.leaf.get_full_name() != "uvm_test_top.container.leaf")
                `uvm_fatal("UI04_HIER", $sformatf("wrong leaf path: %s", container.leaf.get_full_name()))

            $display("HIERARCHY_TRACE: test=%s container=%s leaf=%s",
                     get_full_name(), container.get_full_name(),
                     container.leaf.get_full_name());
            $display("TEST_RESULT: PASS");
            phase.drop_objection(this);
        endtask
    endclass
endpackage
