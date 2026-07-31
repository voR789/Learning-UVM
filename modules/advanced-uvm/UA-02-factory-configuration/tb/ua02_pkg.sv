package ua02_pkg;
    import uvm_pkg::*;
    `include "uvm_macros.svh"

    class ua02_policy_cfg extends uvm_object;
        `uvm_object_utils(ua02_policy_cfg)
        int unsigned operand;
        bit          enabled = 1'b1;

        function new(string name = "ua02_policy_cfg");
            super.new(name);
        endfunction
    endclass

    class ua02_base_policy extends uvm_component;
        `uvm_component_utils(ua02_base_policy)
        ua02_policy_cfg cfg;

        function new(string name, uvm_component parent);
            super.new(name, parent);
        endfunction

        function void build_phase(uvm_phase phase);
            super.build_phase(phase);
            if (!uvm_config_db #(ua02_policy_cfg)::get(this, "", "cfg", cfg))
                `uvm_fatal("UA02_CFG", $sformatf("%s did not receive cfg", get_full_name()))
        endfunction

        virtual function int unsigned apply(int unsigned value);
            return value;
        endfunction

        virtual function string policy_name();
            return "base";
        endfunction
    endclass

    class ua02_add_policy extends ua02_base_policy;
        `uvm_component_utils(ua02_add_policy)

        function new(string name, uvm_component parent);
            super.new(name, parent);
        endfunction

        virtual function int unsigned apply(int unsigned value);
            if (cfg.enabled)
                return value + cfg.operand;
            return value;
        endfunction

        virtual function string policy_name();
            return "add";
        endfunction
    endclass

    class ua02_xor_policy extends ua02_base_policy;
        `uvm_component_utils(ua02_xor_policy)

        function new(string name, uvm_component parent);
            super.new(name, parent);
        endfunction

        virtual function int unsigned apply(int unsigned value);
            if (cfg.enabled)
                return value ^ cfg.operand;
            return value;
        endfunction

        virtual function string policy_name();
            return "xor";
        endfunction
    endclass

    class ua02_env extends uvm_env;
        `uvm_component_utils(ua02_env)
        ua02_base_policy left;
        ua02_base_policy right;

        function new(string name, uvm_component parent);
            super.new(name, parent);
        endfunction

        function void build_phase(uvm_phase phase);
            super.build_phase(phase);
            left  = ua02_base_policy::type_id::create("left", this);
            right = ua02_base_policy::type_id::create("right", this);
        endfunction
    endclass

    class ua02_base_test extends uvm_test;
        `uvm_component_utils(ua02_base_test)
        ua02_env        env;
        ua02_policy_cfg left_cfg;
        ua02_policy_cfg right_cfg;
        string          expected_left_policy;
        string          expected_right_policy;
        int unsigned    expected_left_result;
        int unsigned    expected_right_result;

        function new(string name, uvm_component parent);
            super.new(name, parent);
        endfunction

        virtual function void configure();
        endfunction

        function void install_configs(int unsigned left_operand,
                                      int unsigned right_operand);

            left_cfg = ua02_policy_cfg::type_id::create("left_cfg");
            right_cfg = ua02_policy_cfg::type_id::create("right_cfg");
            left_cfg.operand = left_operand;
            right_cfg.operand = right_operand;
            uvm_config_db #(ua02_policy_cfg)::set(
                this, "env.left", "cfg", left_cfg
            );
            uvm_config_db #(ua02_policy_cfg)::set(
                this, "env.right", "cfg", right_cfg
            );
        endfunction

        function void build_phase(uvm_phase phase);
            super.build_phase(phase);
            configure();
            env = ua02_env::type_id::create("env", this);
        endfunction

        task run_phase(uvm_phase phase);
            int unsigned left_result;
            int unsigned right_result;
            string left_policy;
            string right_policy;
            bit mismatch;

            phase.raise_objection(this);
            left_result = env.left.apply(8'h12);
            right_result = env.right.apply(8'h12);
            left_policy = env.left.policy_name();
            right_policy = env.right.policy_name();

            mismatch = 1'b0;
            if ((left_policy != expected_left_policy) ||
                (right_policy != expected_right_policy) ||
                (left_result != expected_left_result) ||
                (right_result != expected_right_result)) begin
                mismatch = 1'b1;
                `uvm_error("UA02_OVERRIDE",
                    $sformatf("left=%s/%0d expected=%s/%0d right=%s/%0d expected=%s/%0d",
                        left_policy, left_result,
                        expected_left_policy, expected_left_result,
                        right_policy, right_result,
                        expected_right_policy, expected_right_result))
            end

            $display("UA02_TRACE test=%s left=%s/%0d right=%s/%0d",
                get_type_name(), left_policy, left_result,
                right_policy, right_result);
            if (!mismatch)
                $display("TEST_RESULT: PASS");
            phase.drop_objection(this);
        endtask
    endclass

    class ua02_type_override_test extends ua02_base_test;
        `uvm_component_utils(ua02_type_override_test)

        function new(string name, uvm_component parent);
            super.new(name, parent);
        endfunction

        virtual function void configure();
            install_configs(3, 7);
            expected_left_policy = "add";
            expected_right_policy = "add";
            expected_left_result = 8'h15;
            expected_right_result = 8'h19;

            // TODO: Install one type override so every later factory request
            // for ua02_base_policy creates ua02_add_policy.
            ua02_base_policy::type_id::set_type_override(ua02_add_policy::get_type());
        endfunction
    endclass

    class ua02_instance_override_test extends ua02_base_test;
        `uvm_component_utils(ua02_instance_override_test)

        function new(string name, uvm_component parent);
            super.new(name, parent);
        endfunction

        virtual function void configure();
            install_configs(3, 7);
            expected_left_policy = "base";
            expected_right_policy = "xor";
            expected_left_result = 8'h12;
            expected_right_result = 8'h15;

            // TODO: Install one instance override so only
            // uvm_test_top.env.right creates ua02_xor_policy.
            ua02_base_policy::type_id::set_inst_override(
                ua02_xor_policy::get_type(), // Type
                "uvm_test_top.env.right" // Path string
            );
        endfunction
    endclass
endpackage
