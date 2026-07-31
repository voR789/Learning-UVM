package ua02_fixture_pkg;
    import uvm_pkg::*;
    import ua02_pkg::*;
    `include "uvm_macros.svh"

    class ua02_valid_type_test extends ua02_base_test;
        `uvm_component_utils(ua02_valid_type_test)

        function new(string name, uvm_component parent);
            super.new(name, parent);
        endfunction

        virtual function void configure();
            install_configs(3, 7);
            expected_left_policy = "add";
            expected_right_policy = "add";
            expected_left_result = 8'h15;
            expected_right_result = 8'h19;
            ua02_base_policy::type_id::set_type_override(
                ua02_add_policy::get_type()
            );
        endfunction
    endclass

    class ua02_valid_instance_test extends ua02_base_test;
        `uvm_component_utils(ua02_valid_instance_test)

        function new(string name, uvm_component parent);
            super.new(name, parent);
        endfunction

        virtual function void configure();
            install_configs(3, 7);
            expected_left_policy = "base";
            expected_right_policy = "xor";
            expected_left_result = 8'h12;
            expected_right_result = 8'h15;
            ua02_base_policy::type_id::set_inst_override(
                ua02_xor_policy::get_type(),
                "uvm_test_top.env.right"
            );
        endfunction
    endclass

    class ua02_wrong_path_test extends ua02_base_test;
        `uvm_component_utils(ua02_wrong_path_test)

        function new(string name, uvm_component parent);
            super.new(name, parent);
        endfunction

        virtual function void configure();
            install_configs(3, 7);
            expected_left_policy = "base";
            expected_right_policy = "xor";
            expected_left_result = 8'h12;
            expected_right_result = 8'h15;
            ua02_base_policy::type_id::set_inst_override(
                ua02_xor_policy::get_type(),
                "uvm_test_top.env.missing"
            );
        endfunction
    endclass
endpackage
