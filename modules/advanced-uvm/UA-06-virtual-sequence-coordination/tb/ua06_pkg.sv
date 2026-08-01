package ua06_pkg;
    import uvm_pkg::*;
    `include "uvm_macros.svh"

    // Different types of sequence items/interface requires distinct sequencers, unlike if we are using one sequencer, from which we can run normal parallel sequences
    class ua06_control_item extends uvm_sequence_item;
        `uvm_object_utils(ua06_control_item)
        bit enable;
        bit acknowledged;
        function new(string name = "ua06_control_item");
            super.new(name);
        endfunction
    endclass

    class ua06_data_item extends uvm_sequence_item;
        `uvm_object_utils(ua06_data_item)
        int unsigned token;
        int unsigned result;
        function new(string name = "ua06_data_item");
            super.new(name);
        endfunction
    endclass

    class ua06_control_sequencer extends uvm_sequencer #(ua06_control_item);
        `uvm_component_utils(ua06_control_sequencer)
        function new(string name, uvm_component parent);
            super.new(name, parent);
        endfunction
    endclass

    class ua06_data_sequencer extends uvm_sequencer #(ua06_data_item);
        `uvm_component_utils(ua06_data_sequencer)
        function new(string name, uvm_component parent);
            super.new(name, parent);
        endfunction
    endclass

    class ua06_virtual_sequencer extends uvm_sequencer;
        `uvm_component_utils(ua06_virtual_sequencer)
        ua06_control_sequencer control_sequencer;
        ua06_data_sequencer data_sequencer;
        function new(string name, uvm_component parent);
            super.new(name, parent);
        endfunction
    endclass

    class ua06_control_driver extends uvm_driver #(ua06_control_item);
        `uvm_component_utils(ua06_control_driver)
        int unsigned driven;
        function new(string name, uvm_component parent);
            super.new(name, parent);
        endfunction
        task run_phase(uvm_phase phase);
            ua06_control_item req;
            ua06_control_item rsp;
            forever begin
                seq_item_port.get_next_item(req);
                #1ns;
                rsp = ua06_control_item::type_id::create("rsp");
                rsp.set_id_info(req);
                rsp.enable = req.enable;
                rsp.acknowledged = req.enable;
                driven++;
                seq_item_port.item_done(rsp);
            end
        endtask
    endclass

    class ua06_data_driver extends uvm_driver #(ua06_data_item);
        `uvm_component_utils(ua06_data_driver)
        int unsigned driven;
        function new(string name, uvm_component parent);
            super.new(name, parent);
        endfunction
        task run_phase(uvm_phase phase);
            ua06_data_item req;
            ua06_data_item rsp;
            forever begin
                seq_item_port.get_next_item(req);
                #1ns;
                rsp = ua06_data_item::type_id::create("rsp");
                rsp.set_id_info(req);
                rsp.token = req.token;
                rsp.result = req.token + 1;
                driven++;
                seq_item_port.item_done(rsp);
            end
        endtask
    endclass

    class ua06_control_sequence extends uvm_sequence #(ua06_control_item);
        `uvm_object_utils(ua06_control_sequence)
        uvm_event enabled_event;
        int unsigned verified;
        function new(string name = "ua06_control_sequence");
            super.new(name);
        endfunction
        task body();
            ua06_control_item req;
            ua06_control_item rsp;
            if (enabled_event == null)
                `uvm_fatal("UA06_EVENT", "control leaf did not receive enable event")
            req = ua06_control_item::type_id::create("req");
            start_item(req);
            req.enable = 1'b1;
            finish_item(req);
            get_response(rsp);
            if (!rsp.acknowledged)
                `uvm_fatal("UA06_CONTROL", "enable request was not acknowledged")
            verified++;
            enabled_event.trigger();
        endtask
    endclass

    class ua06_data_sequence extends uvm_sequence #(ua06_data_item);
        `uvm_object_utils(ua06_data_sequence)
        uvm_event enabled_event;
        int unsigned verified;
        function new(string name = "ua06_data_sequence");
            super.new(name);
        endfunction
        task body();
            ua06_data_item req;
            ua06_data_item rsp;
            if (enabled_event == null)
                `uvm_fatal("UA06_EVENT", "data leaf did not receive enable event")
            enabled_event.wait_on();
            for (int unsigned i = 0; i < 3; i++) begin
                req = ua06_data_item::type_id::create($sformatf("req_%0d", i));
                start_item(req);
                req.token = 8'h30 + i;
                finish_item(req);
                get_response(rsp);
                if ((rsp.token != 8'h30 + i) || (rsp.result != 8'h31 + i))
                    `uvm_fatal("UA06_DATA", "data response was incorrect")
                verified++;
            end
        endtask
    endclass

    class ua06_virtual_sequence extends uvm_sequence;
        `uvm_object_utils(ua06_virtual_sequence)
        `uvm_declare_p_sequencer(ua06_virtual_sequencer)
        ua06_control_sequence control_sequence;
        ua06_data_sequence data_sequence;
        uvm_event enabled_event;

        function new(string name = "ua06_virtual_sequence");
            super.new(name);
        endfunction

        function void prepare_children();
            enabled_event = new("enabled_event");
            control_sequence = ua06_control_sequence::type_id::create("control_sequence");
            data_sequence = ua06_data_sequence::type_id::create("data_sequence");
            control_sequence.enabled_event = enabled_event;
            data_sequence.enabled_event = enabled_event;
        endfunction

        task body();
            prepare_children();
            if (p_sequencer == null)
                `uvm_fatal("UA06_VSEQR", "virtual sequence did not receive a virtual sequencer")
            if ((p_sequencer.control_sequencer == null) ||
                (p_sequencer.data_sequencer == null))
                `uvm_fatal("UA06_VSEQR", "virtual sequencer is missing a physical sequencer handle")

            // TODO: Start both leaves concurrently on their matching physical
            // p_sequencer handles, preserve this parent context, and wait for both.
            fork
                control_sequence.start(p_sequencer.control_sequencer, this);
                data_sequence.start(p_sequencer.data_sequencer, this);
            join
        endtask
    endclass

    class ua06_env extends uvm_env;
        `uvm_component_utils(ua06_env)
        ua06_control_sequencer control_sequencer;
        ua06_data_sequencer data_sequencer;
        ua06_virtual_sequencer virtual_sequencer;
        ua06_control_driver control_driver;
        ua06_data_driver data_driver;

        function new(string name, uvm_component parent);
            super.new(name, parent);
        endfunction

        function void build_phase(uvm_phase phase);
            super.build_phase(phase);
            control_sequencer = ua06_control_sequencer::type_id::create("control_sequencer", this);
            data_sequencer = ua06_data_sequencer::type_id::create("data_sequencer", this);
            virtual_sequencer = ua06_virtual_sequencer::type_id::create("virtual_sequencer", this);
            control_driver = ua06_control_driver::type_id::create("control_driver", this);
            data_driver = ua06_data_driver::type_id::create("data_driver", this);
        endfunction

        function void connect_phase(uvm_phase phase);
            super.connect_phase(phase);
            control_driver.seq_item_port.connect(control_sequencer.seq_item_export);
            data_driver.seq_item_port.connect(data_sequencer.seq_item_export);
            // TODO: Wire both physical sequencer handles into virtual_sequencer.
            virtual_sequencer.control_sequencer = control_sequencer;
            virtual_sequencer.data_sequencer = data_sequencer;
        endfunction
    endclass

    class ua06_test extends uvm_test;
        `uvm_component_utils(ua06_test)
        ua06_env env;
        function new(string name, uvm_component parent);
            super.new(name, parent);
        endfunction
        virtual function void configure();
        endfunction
        function void build_phase(uvm_phase phase);
            super.build_phase(phase);
            configure();
            env = ua06_env::type_id::create("env", this);
        endfunction
        task run_phase(uvm_phase phase);
            ua06_virtual_sequence scenario;
            phase.raise_objection(this);
            scenario = ua06_virtual_sequence::type_id::create("scenario");
            scenario.start(env.virtual_sequencer);
            if ((scenario.control_sequence == null) || (scenario.data_sequence == null))
                `uvm_fatal("UA06_COUNT", "virtual sequence did not prepare both children")
            if ((scenario.control_sequence.verified != 1) ||
                (scenario.data_sequence.verified != 3) ||
                (env.control_driver.driven != 1) || (env.data_driver.driven != 3))
                `uvm_fatal("UA06_COUNT", $sformatf("control_verified=%0d data_verified=%0d control_driven=%0d data_driven=%0d",
                    scenario.control_sequence.verified, scenario.data_sequence.verified,
                    env.control_driver.driven, env.data_driver.driven))
            $display("UA06_TRACE control_verified=%0d data_verified=%0d control_driven=%0d data_driven=%0d",
                scenario.control_sequence.verified, scenario.data_sequence.verified,
                env.control_driver.driven, env.data_driver.driven);
            $display("TEST_RESULT: PASS");
            phase.drop_objection(this);
        endtask
    endclass
endpackage
