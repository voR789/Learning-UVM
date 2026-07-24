package ui08_pkg;
    import uvm_pkg::*;
    `include "uvm_macros.svh"

    class ui08_observation extends uvm_object;
        `uvm_object_utils(ui08_observation)
        int id;
        int payload;
        function new(string name = "ui08_observation");
            super.new(name);
        endfunction
    endclass

    class ui08_monitor extends uvm_component;
        `uvm_component_utils(ui08_monitor)
        // Declare an analysis port carrying ui08_observation.
        uvm_analysis_port #(ui08_observation) obs_port;
        int published;
        function new(string name, uvm_component parent);
            super.new(name, parent);
            // Construct the analysis port.
            obs_port = new("obs_port", this);
        endfunction
        task run_phase(uvm_phase phase);
            ui08_observation item;
            for (int i = 0; i < 3; i++) begin
                item = ui08_observation::type_id::create($sformatf("item_%0d", i));
                item.id = 20 + i;
                item.payload = (i + 1) * 3;
                // Broadcast item through the analysis port.
                obs_port.write(item);
                published++;
            end
        endtask
    endclass

    class ui08_subscriber extends uvm_subscriber #(ui08_observation);
        `uvm_component_utils(ui08_subscriber)
        int checks;
        function new(string name, uvm_component parent);
            super.new(name, parent);
        endfunction
        function void write(ui08_observation item);
            int expected_index;
            expected_index = checks;
            if ((item.id != (20 + expected_index)) ||
                (item.payload != ((expected_index + 1) * 3)))
                `uvm_fatal("UI08_SUB", "subscriber received incorrect or out-of-order item")
            checks++;
        endfunction
    endclass

    class ui08_audit extends uvm_component;
        `uvm_component_utils(ui08_audit)
        uvm_analysis_imp #(ui08_observation, ui08_audit) in_imp;
        int checks;
        function new(string name, uvm_component parent);
            super.new(name, parent);
            in_imp = new("in_imp", this);
        endfunction
        function void write(ui08_observation item);
            int expected_index;
            expected_index = checks;
            if ((item.id != (20 + expected_index)) ||
                (item.payload != ((expected_index + 1) * 3)))
                `uvm_fatal("UI08_AUDIT", "audit received incorrect or out-of-order item")
            checks++;
        endfunction
    endclass

    class ui08_env extends uvm_env;
        `uvm_component_utils(ui08_env)
        ui08_monitor monitor;
        ui08_subscriber subscriber;
        ui08_audit audit;
        function new(string name, uvm_component parent);
            super.new(name, parent);
        endfunction
        function void build_phase(uvm_phase phase);
            super.build_phase(phase);
            monitor = ui08_monitor::type_id::create("monitor", this);
            subscriber = ui08_subscriber::type_id::create("subscriber", this);
            audit = ui08_audit::type_id::create("audit", this);
        endfunction
        function void connect_phase(uvm_phase phase);
            super.connect_phase(phase);
            // TODO 4: Connect the monitor port to subscriber.analysis_export.
            monitor.obs_port.connect(subscriber.analysis_export);
            // TODO 5: Connect the same port to audit.in_imp.
            monitor.obs_port.connect(audit.in_imp);
        endfunction
    endclass

    class ui08_test extends uvm_test;
        `uvm_component_utils(ui08_test)
        ui08_env env;
        function new(string name, uvm_component parent);
            super.new(name, parent);
        endfunction
        function void build_phase(uvm_phase phase);
            super.build_phase(phase);
            env = ui08_env::type_id::create("env", this);
        endfunction
        task run_phase(uvm_phase phase);
            phase.raise_objection(this);
            #1ns;
            if ((env.monitor.published != 3) ||
                (env.subscriber.checks != 3) ||
                (env.audit.checks != 3))
                `uvm_fatal("UI08_COUNT",
                    $sformatf("expected 3/3/3, got published=%0d subscriber=%0d audit=%0d",
                              env.monitor.published, env.subscriber.checks, env.audit.checks))
            $display("ANALYSIS_TRACE: published=%0d subscriber_checks=%0d audit_checks=%0d",
                     env.monitor.published, env.subscriber.checks, env.audit.checks);
            $display("TEST_RESULT: PASS");
            phase.drop_objection(this);
        endtask
    endclass
endpackage
