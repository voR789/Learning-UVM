package ua08_pkg;
    import uvm_pkg::*;
    import ua08_support_pkg::*;
    `include "uvm_macros.svh"
    // Register abstraction layer (RAL), provides an easy way to model memory mapped registers, gives easy access
    class ua08_control_reg extends uvm_reg;
        `uvm_object_utils(ua08_control_reg)
        rand uvm_reg_field enable; // Given option to be random
        rand uvm_reg_field mode;

        function new(string name = "ua08_control_reg");
            super.new(name, 32, UVM_NO_COVERAGE); // name, bits, coverage?
        endfunction

        virtual function void build();
            enable = uvm_reg_field::type_id::create("enable");
            mode = uvm_reg_field::type_id::create("mode");
            enable.configure(this, 1, 0, "RW", 0, 0, 1, 0, 0);
            /*
            <uvm_reg_field>.configure(
                parent,
                size,
                lsb_pos,
                access,
                volatile,
                reset,
                has_reset,
                is_rand,
                individually_accessible
            )
            */
            mode.configure(this, 2, 1, "RW", 0, 0, 1, 0, 0);
        endfunction
    endclass

    class ua08_reg_block extends uvm_reg_block; // Holds 1+ abstract register instances
        `uvm_object_utils(ua08_reg_block)
        rand ua08_control_reg control;

        function new(string name = "ua08_reg_block");
            super.new(name, UVM_NO_COVERAGE);
        endfunction

        virtual function void build();
            // TODO: Construct the control register and its default byte-addressed
            // little-endian map from the local register specification, then lock
            // the completed model.
            control = ua08_control_reg::type_id::create();
            control.configure(this, null, ""); // Configure the block
            control.build();
            default_map = create_map( // Configure the map for the reg
                "default_map", // Name
                'h0, // Base
                4, // Length
                UVM_LITTLE_ENDIAN, // Endianess
                1 // Addressing width (byte addressed map)
            );
            default_map.add_reg(control, 'h0, "RW"); // Reg, base, rights : add the reg to the map
            lock_model();
        endfunction
    endclass

    class ua08_env extends uvm_env;
        `uvm_component_utils(ua08_env)
        ua08_bus_sequencer sequencer;
        ua08_bus_driver driver;
        ua08_reg_adapter adapter;
        uvm_reg_predictor #(ua08_bus_item) predictor;
        ua08_reg_block model;

        function new(string name, uvm_component parent);
            super.new(name, parent);
        endfunction

        function void build_phase(uvm_phase phase);
            super.build_phase(phase);
            sequencer = ua08_bus_sequencer::type_id::create("sequencer", this);
            driver = ua08_bus_driver::type_id::create("driver", this);
            adapter = ua08_reg_adapter::type_id::create("adapter");
            predictor = uvm_reg_predictor #(ua08_bus_item)::type_id::create("predictor", this);
            model = ua08_reg_block::type_id::create("model");
            model.build();
            model.reset();
        endfunction

        function void connect_phase(uvm_phase phase);
            super.connect_phase(phase);
            driver.seq_item_port.connect(sequencer.seq_item_export);
            // TODO: Connect the RAL frontdoor map to sequencer+adapter and the
            // completed bus observation path to predictor+map+adapter. Disable
            // automatic prediction so the observation path owns mirror updates.
            model.default_map.set_sequencer(sequencer, adapter); // Setup sequencer ability to send write() calls to dut MM control bus
            model.default_map.set_auto_predict(0); // Auto predict on write() call vs monitor observation
            predictor.map = model.default_map; // Give the UVM MM predictor the map and adapter
            predictor.adapter = adapter;
            driver.completed_ap.connect(predictor.bus_in); // Connect the "monitor" to the predictor
        endfunction
    endclass

    class ua08_test extends uvm_test;
        `uvm_component_utils(ua08_test)
        ua08_env env;

        function new(string name, uvm_component parent);
            super.new(name, parent);
        endfunction

        function void build_phase(uvm_phase phase);
            super.build_phase(phase);
            env = ua08_env::type_id::create("env", this);
        endfunction

        task run_phase(uvm_phase phase);
            uvm_status_e status;
            uvm_reg_data_t mirrored;
            phase.raise_objection(this);

            if (env == null)
                `uvm_fatal("UA08_MODEL", "environment was not built")
            if (env.model == null)
                `uvm_fatal("UA08_MODEL", "register block was not built")
            if (env.model.control == null)
                `uvm_fatal("UA08_MODEL", "control register was not built")
            if (env.model.default_map == null)
                `uvm_fatal("UA08_MODEL", "default map was not built")

            env.model.control.write(status, 32'h0000_0005,
                UVM_FRONTDOOR, env.model.default_map);
            if (status != UVM_IS_OK)
                `uvm_fatal("UA08_STATUS", "frontdoor control write did not complete successfully")

            mirrored = env.model.control.get_mirrored_value();
            if ((env.driver.stored_control != 32'h0000_0005) ||
                (mirrored != 32'h0000_0005) ||
                (env.driver.completed != 1))
                `uvm_fatal("UA08_RESULT", $sformatf(
                    "stored=0x%0h mirrored=0x%0h completed=%0d",
                    env.driver.stored_control, mirrored, env.driver.completed))

            $display("UA08_TRACE stored=0x%0h mirrored=0x%0h completed=%0d",
                env.driver.stored_control, mirrored, env.driver.completed);
            $display("TEST_RESULT: PASS");
            phase.drop_objection(this);
        endtask
    endclass
endpackage
