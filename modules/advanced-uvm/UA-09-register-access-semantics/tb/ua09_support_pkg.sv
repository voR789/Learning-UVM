package ua09_support_pkg;
    import uvm_pkg::*;
    `include "uvm_macros.svh"

    class ua09_bus_item extends uvm_sequence_item;
        `uvm_object_utils(ua09_bus_item)
        uvm_access_e kind;
        uvm_reg_addr_t addr;
        uvm_reg_data_t data;
        uvm_status_e status;

        function new(string name = "ua09_bus_item");
            super.new(name);
            status = UVM_NOT_OK;
        endfunction
    endclass

    class ua09_bus_sequencer extends uvm_sequencer #(ua09_bus_item);
        `uvm_component_utils(ua09_bus_sequencer)
        function new(string name, uvm_component parent);
            super.new(name, parent);
        endfunction
    endclass

    class ua09_bus_driver extends uvm_driver #(ua09_bus_item);
        `uvm_component_utils(ua09_bus_driver)
        uvm_analysis_port #(ua09_bus_item) completed_ap;
        uvm_reg_data_t stored_control;
        int unsigned completed;
        int unsigned external_updates;

        function new(string name, uvm_component parent);
            super.new(name, parent);
            completed_ap = new("completed_ap", this);
        endfunction

        function void external_write(uvm_reg_data_t value);
            stored_control = value;
            external_updates++;
        endfunction

        task run_phase(uvm_phase phase);
            ua09_bus_item req;
            forever begin
                seq_item_port.get_next_item(req);
                #1ns;
                if (req.addr == 'h0) begin
                    if (req.kind == UVM_WRITE)
                        stored_control = req.data;
                    else
                        req.data = stored_control;
                    req.status = UVM_IS_OK;
                end else begin
                    req.status = UVM_NOT_OK;
                end
                completed++;
                completed_ap.write(req);
                seq_item_port.item_done();
            end
        endtask
    endclass

    class ua09_reg_adapter extends uvm_reg_adapter;
        `uvm_object_utils(ua09_reg_adapter)
        function new(string name = "ua09_reg_adapter");
            super.new(name);
            provides_responses = 0;
        endfunction

        virtual function uvm_sequence_item reg2bus(const ref uvm_reg_bus_op rw);
            ua09_bus_item item;
            item = ua09_bus_item::type_id::create("item");
            item.kind = rw.kind;
            item.addr = rw.addr;
            item.data = rw.data;
            item.status = UVM_NOT_OK;
            return item;
        endfunction

        virtual function void bus2reg(uvm_sequence_item bus_item,
                                      ref uvm_reg_bus_op rw);
            ua09_bus_item item;
            if (!$cast(item, bus_item))
                `uvm_fatal("UA09_ADAPTER", "adapter received the wrong item type")
            rw.kind = item.kind;
            rw.addr = item.addr;
            rw.data = item.data;
            rw.status = item.status;
        endfunction
    endclass

    class ua09_control_reg extends uvm_reg;
        `uvm_object_utils(ua09_control_reg)
        rand uvm_reg_field enable;
        rand uvm_reg_field mode;

        function new(string name = "ua09_control_reg");
            super.new(name, 32, UVM_NO_COVERAGE);
        endfunction

        virtual function void build();
            enable = uvm_reg_field::type_id::create("enable");
            mode = uvm_reg_field::type_id::create("mode");
            enable.configure(this, 1, 0, "RW", 0, 0, 1, 0, 0);
            mode.configure(this, 2, 1, "RW", 0, 0, 1, 0, 0);
        endfunction
    endclass

    class ua09_reg_block extends uvm_reg_block;
        `uvm_object_utils(ua09_reg_block)
        rand ua09_control_reg control;

        function new(string name = "ua09_reg_block");
            super.new(name, UVM_NO_COVERAGE);
        endfunction

        virtual function void build();
            control = ua09_control_reg::type_id::create("control");
            control.configure(this, null, "");
            control.build();
            default_map = create_map("default_map", 'h0, 4,
                UVM_LITTLE_ENDIAN, 1);
            default_map.add_reg(control, 'h0, "RW");
            lock_model();
        endfunction
    endclass

    class ua09_storage_backdoor extends uvm_object;
        `uvm_object_utils(ua09_storage_backdoor)
        ua09_bus_driver storage;
        int unsigned reads;

        function new(string name = "ua09_storage_backdoor");
            super.new(name);
        endfunction

        task read(output uvm_status_e status,
                  output uvm_reg_data_t value);
            if (storage == null)
                `uvm_fatal("UA09_BACKDOOR", "backdoor storage handle is null")
            value = storage.stored_control;
            reads++;
            status = UVM_IS_OK;
        endtask
    endclass

    class ua09_env extends uvm_env;
        `uvm_component_utils(ua09_env)
        ua09_bus_sequencer sequencer;
        ua09_bus_driver driver;
        ua09_reg_adapter adapter;
        uvm_reg_predictor #(ua09_bus_item) predictor;
        ua09_reg_block model;
        ua09_storage_backdoor backdoor;

        function new(string name, uvm_component parent);
            super.new(name, parent);
        endfunction

        function void build_phase(uvm_phase phase);
            super.build_phase(phase);
            sequencer = ua09_bus_sequencer::type_id::create("sequencer", this);
            driver = ua09_bus_driver::type_id::create("driver", this);
            adapter = ua09_reg_adapter::type_id::create("adapter");
            predictor = uvm_reg_predictor #(ua09_bus_item)::type_id::create(
                "predictor", this);
            model = ua09_reg_block::type_id::create("model");
            backdoor = ua09_storage_backdoor::type_id::create("backdoor");
            model.build();
            model.reset();
            backdoor.storage = driver;
        endfunction

        function void connect_phase(uvm_phase phase);
            super.connect_phase(phase);
            driver.seq_item_port.connect(sequencer.seq_item_export);
            model.default_map.set_sequencer(sequencer, adapter);
            model.default_map.set_auto_predict(0);
            predictor.map = model.default_map;
            predictor.adapter = adapter;
            driver.completed_ap.connect(predictor.bus_in);
        endfunction
    endclass

    class ua09_base_test extends uvm_test;
        `uvm_component_utils(ua09_base_test)
        ua09_env env;

        function new(string name, uvm_component parent);
            super.new(name, parent);
        endfunction

        function void build_phase(uvm_phase phase);
            super.build_phase(phase);
            env = ua09_env::type_id::create("env", this);
        endfunction

        virtual task resynchronize_from_hardware(output uvm_status_e status);
            status = UVM_NOT_OK;
        endtask

        virtual function void stage_desired(input uvm_reg_data_t value);
        endfunction

        virtual task commit_desired(output uvm_status_e status);
            status = UVM_NOT_OK;
        endtask

        task run_phase(uvm_phase phase);
            uvm_status_e status;
            uvm_reg_data_t mirrored;
            uvm_reg_data_t desired;

            phase.raise_objection(this);
            if (env == null)
                `uvm_fatal("UA09_MODEL", "environment was not built")
            if (env.model == null)
                `uvm_fatal("UA09_MODEL", "register block was not built")
            if (env.model.control == null)
                `uvm_fatal("UA09_MODEL", "control register was not built")
            if (env.model.default_map == null)
                `uvm_fatal("UA09_MODEL", "default map was not built")
            if (env.backdoor == null)
                `uvm_fatal("UA09_MODEL", "register backdoor was not built")

            env.model.control.write(status, 32'h5, UVM_FRONTDOOR,
                env.model.default_map);
            if (status != UVM_IS_OK)
                `uvm_fatal("UA09_FRONTDOOR", "initial frontdoor write failed")

            env.driver.external_write(32'h6);
            mirrored = env.model.control.get_mirrored_value();
            desired = env.model.control.get();
            if ((env.driver.stored_control != 32'h6) ||
                (mirrored != 32'h5) || (desired != 32'h5) ||
                (env.driver.completed != 1))
                `uvm_fatal("UA09_STALE", "external update did not create the expected stale model")

            resynchronize_from_hardware(status);
            mirrored = env.model.control.get_mirrored_value();
            desired = env.model.control.get();
            if ((status != UVM_IS_OK) ||
                (env.driver.stored_control != 32'h6) ||
                (mirrored != 32'h6) || (desired != 32'h6) ||
                (env.backdoor.reads != 1) ||
                (env.driver.completed != 1))
                `uvm_fatal("UA09_SYNC", $sformatf(
                    "actual=0x%0h mirrored=0x%0h desired=0x%0h frontdoor=%0d backdoor_reads=%0d",
                    env.driver.stored_control, mirrored, desired,
                    env.driver.completed, env.backdoor.reads))

            stage_desired(32'h3);
            mirrored = env.model.control.get_mirrored_value();
            desired = env.model.control.get();
            if ((env.driver.stored_control != 32'h6) ||
                (mirrored != 32'h6) || (desired != 32'h3) ||
                (env.driver.completed != 1) ||
                (env.backdoor.reads != 1))
                `uvm_fatal("UA09_STAGE", $sformatf(
                    "actual=0x%0h mirrored=0x%0h desired=0x%0h frontdoor=%0d backdoor_reads=%0d",
                    env.driver.stored_control, mirrored, desired,
                    env.driver.completed, env.backdoor.reads))

            commit_desired(status);
            mirrored = env.model.control.get_mirrored_value();
            desired = env.model.control.get();
            if ((status != UVM_IS_OK) ||
                (env.driver.stored_control != 32'h3) ||
                (mirrored != 32'h3) || (desired != 32'h3) ||
                (env.driver.completed != 2) ||
                (env.backdoor.reads != 1))
                `uvm_fatal("UA09_UPDATE", $sformatf(
                    "actual=0x%0h mirrored=0x%0h desired=0x%0h frontdoor=%0d backdoor_reads=%0d",
                    env.driver.stored_control, mirrored, desired,
                    env.driver.completed, env.backdoor.reads))

            $display("UA09_TRACE actual=0x%0h mirrored=0x%0h desired=0x%0h frontdoor=%0d backdoor_reads=%0d",
                env.driver.stored_control, mirrored, desired,
                env.driver.completed, env.backdoor.reads);
            $display("TEST_RESULT: PASS");
            phase.drop_objection(this);
        endtask
    endclass
endpackage
