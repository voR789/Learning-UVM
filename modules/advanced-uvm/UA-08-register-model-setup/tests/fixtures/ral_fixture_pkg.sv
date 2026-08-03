package ral_fixture_pkg;
    import uvm_pkg::*;
    import ua08_support_pkg::*;
    import ua08_pkg::*;
    `include "uvm_macros.svh"

    class ua08_reference_block extends ua08_reg_block;
        `uvm_object_utils(ua08_reference_block)
        bit wrong_offset;
        function new(string name = "ua08_reference_block");
            super.new(name);
        endfunction
        virtual function void build();
            uvm_reg_addr_t offset;
            control = ua08_control_reg::type_id::create("control");
            control.configure(this, null, "");
            control.build();
            default_map = create_map("default_map", 'h0, 4,
                UVM_LITTLE_ENDIAN, 1);
            if (wrong_offset)
                offset = 'h4;
            else
                offset = 'h0;
            default_map.add_reg(control, offset, "RW");
            lock_model();
        endfunction
    endclass

    class ua08_wrong_offset_block extends ua08_reference_block;
        `uvm_object_utils(ua08_wrong_offset_block)
        function new(string name = "ua08_wrong_offset_block");
            super.new(name);
            wrong_offset = 1'b1;
        endfunction
    endclass

    class ua08_reference_env extends ua08_env;
        `uvm_component_utils(ua08_reference_env)
        function new(string name, uvm_component parent);
            super.new(name, parent);
        endfunction
        function void build_phase(uvm_phase phase);
            super.build_phase(phase);
        endfunction
        function void connect_phase(uvm_phase phase);
            super.connect_phase(phase);
            model.default_map.set_sequencer(sequencer, adapter);
            model.default_map.set_auto_predict(0);
            predictor.map = model.default_map;
            predictor.adapter = adapter;
            driver.completed_ap.connect(predictor.bus_in);
        endfunction
    endclass

    class ua08_reference_test extends ua08_test;
        `uvm_component_utils(ua08_reference_test)
        function new(string name, uvm_component parent);
            super.new(name, parent);
        endfunction
        function void build_phase(uvm_phase phase);
            ua08_env::type_id::set_type_override(ua08_reference_env::get_type());
            ua08_reg_block::type_id::set_type_override(ua08_reference_block::get_type());
            super.build_phase(phase);
        endfunction
    endclass

    class ua08_wrong_offset_test extends ua08_test;
        `uvm_component_utils(ua08_wrong_offset_test)
        function new(string name, uvm_component parent);
            super.new(name, parent);
        endfunction
        function void build_phase(uvm_phase phase);
            ua08_env::type_id::set_type_override(ua08_reference_env::get_type());
            ua08_reg_block::type_id::set_type_override(ua08_wrong_offset_block::get_type());
            super.build_phase(phase);
        endfunction
    endclass
endpackage
