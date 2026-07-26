package ui10_pkg;
    import uvm_pkg::*;
    `include "uvm_macros.svh"

    class ui10_observation extends uvm_object;
        `uvm_object_utils(ui10_observation)
        bit [1:0] operation;
        bit       result_zero;
        function new(string name = "ui10_observation");
            super.new(name);
        endfunction
    endclass

    class ui10_publisher extends uvm_component;
        `uvm_component_utils(ui10_publisher)
        // TODO 1: Declare a typed analysis port named observed_ap.
        uvm_analysis_port #(ui10_observation) observed_ap;
        int published;

        function new(string name, uvm_component parent);
            super.new(name, parent);
            // TODO 2: Construct observed_ap.
            observed_ap = new("observed_ap", this);
        endfunction

        task run_phase(uvm_phase phase);
            ui10_observation item;
            // TODO 3: Publish exactly eight items: operation 0 through 3,
            // each once with result_zero=0 and once with result_zero=1.
            // Create each item through the factory, set both fields, call one
            // analysis write, and increment published.
            for(int op = 0; op < 4; op++) begin
                for(int z = 0; z < 2; z++) begin
                    item = ui10_observation::type_id::create("item", this);
                    item.operation = 2'(op);
                    item.result_zero = z;
                    observed_ap.write(item);
                    published++;
                end
            end
        endtask
    endclass

    class ui10_coverage_subscriber extends uvm_subscriber #(ui10_observation);
        `uvm_component_utils(ui10_coverage_subscriber)
        bit [1:0] sampled_operation;
        bit       sampled_result_zero;
        int       sample_count;

        covergroup observation_cg;
            option.per_instance = 1;

            // TODO 4: Define cp_operation with four explicit named bins:
            // read=0, write=1, flush=2, status=3.
            cp_operation: coverpoint sampled_operation {
                bins read = {0};
                bins write = {1};
                bins flush = {2};
                bins status = {3};
            }
            // TODO 5: Define cp_result_zero with explicit bins:
            // nonzero=0 and zero=1.
            cp_result_zero : coverpoint sampled_result_zero {
                bins nonzero = {0};
                bins zero = {1};
            }
            // TODO 6: Define cx_operation_zero as the full cross.
            cx_operation_zero : cross cp_operation, cp_result_zero;
        endgroup

        function new(string name, uvm_component parent);
            super.new(name, parent);
            // TODO 7: Construct the embedded observation_cg instance.
            observation_cg = new();
        endfunction

        function void write(ui10_observation item);
            // TODO 8: Copy both item fields, sample coverage exactly once,
            // and increment sample_count. Do not mutate item.
            sampled_operation = item.operation;
            sampled_result_zero = item.result_zero;
            observation_cg.sample();
            sample_count++;
        endfunction
    endclass

    class ui10_env extends uvm_env;
        `uvm_component_utils(ui10_env)
        ui10_publisher publisher;
        ui10_coverage_subscriber coverage_subscriber;

        function new(string name, uvm_component parent);
            super.new(name, parent);
        endfunction

        function void build_phase(uvm_phase phase);
            super.build_phase(phase);
            // TODO 9: Factory-create publisher and coverage_subscriber using
            // those exact instance names.
            publisher = ui10_publisher::type_id::create("publisher", this);
            coverage_subscriber = ui10_coverage_subscriber::type_id::create("coverage_subscriber", this);
        endfunction

        function void connect_phase(uvm_phase phase);
            super.connect_phase(phase);
            // TODO 10: Connect the publisher analysis port to the subscriber's
            // inherited analysis_export.
            publisher.observed_ap.connect(coverage_subscriber.analysis_export);
        endfunction
    endclass

    class ui10_test extends uvm_test;
        `uvm_component_utils(ui10_test)
        ui10_env env;

        function new(string name, uvm_component parent);
            super.new(name, parent);
        endfunction

        function void build_phase(uvm_phase phase);
            super.build_phase(phase);
            env = ui10_env::type_id::create("env", this);
        endfunction

        task run_phase(uvm_phase phase);
            uvm_report_server server;
            real coverage_pct;
            int error_count;
            int fatal_count;

            phase.raise_objection(this);
            if (env.publisher == null)
                `uvm_fatal("UI10_STRUCTURE", "publisher was not built")
            if (env.coverage_subscriber == null)
                `uvm_fatal("UI10_STRUCTURE", "coverage_subscriber was not built")
            #1ns;
            coverage_pct = env.coverage_subscriber.observation_cg.get_inst_coverage();
            server = uvm_report_server::get_server();
            error_count = server.get_severity_count(UVM_ERROR);
            fatal_count = server.get_severity_count(UVM_FATAL);

            if ((env.publisher.published != 8) ||
                (env.coverage_subscriber.sample_count != 8) ||
                (coverage_pct < 100.0) ||
                (error_count != 0) ||
                (fatal_count != 0))
                `uvm_fatal("UI10_VERDICT",
                    $sformatf("published=%0d samples=%0d coverage=%0.2f errors=%0d fatals=%0d",
                              env.publisher.published,
                              env.coverage_subscriber.sample_count,
                              coverage_pct, error_count, fatal_count))

            $display("COVERAGE_TRACE: published=%0d samples=%0d coverage=%0.2f errors=%0d fatals=%0d",
                     env.publisher.published,
                     env.coverage_subscriber.sample_count,
                     coverage_pct, error_count, fatal_count);
            $display("TEST_RESULT: PASS");
            phase.drop_objection(this);
        endtask
    endclass
endpackage
