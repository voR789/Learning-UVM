package ua_g1_pkg;
    import uvm_pkg::*;
    import ua_g1_support_pkg::*;
    `include "uvm_macros.svh"

    class ua_g1_apb_monitor extends uvm_monitor;
        `uvm_component_utils(ua_g1_apb_monitor)
        virtual apb_if vif;
        uvm_analysis_port #(ua_g1_apb_item) completed_ap;
        int unsigned observed;

        function new(string name, uvm_component parent);
            super.new(name, parent);
            completed_ap = new("completed_ap", this);
        endfunction

        function void build_phase(uvm_phase phase);
            super.build_phase(phase);
            if (!uvm_config_db #(virtual apb_if)::get(this, "", "vif", vif))
                `uvm_fatal("UAG1_VIF", "monitor did not receive apb_if")
        endfunction

        virtual task run_phase(uvm_phase phase);
            // TODO: Publish exactly one fresh observation for every completed
            // APB access. The transaction must contain request and returned
            // fields sampled from pins; setup cycles are not transactions.
            `uvm_fatal("UAG1_TODO", "complete passive APB observation")
        endtask
    endclass

    class ua_g1_scoreboard extends uvm_subscriber #(ua_g1_apb_item);
        `uvm_component_utils(ua_g1_scoreboard)
        bit enable_model;
        bit [7:0] gain_model;
        bit [7:0] expected_result;
        bit expected_overflow;
        bit expected_valid;
        int unsigned transactions;
        int unsigned results_checked;
        int unsigned mismatches;
        event checked_event;

        function new(string name, uvm_component parent);
            super.new(name, parent);
            gain_model = 8'h01;
        endfunction

        virtual function void write(ua_g1_apb_item t);
            // TODO: From the monitored transfer and pre-transfer model state,
            // predict the response class, update state only for accepted writes,
            // and independently check successful STATUS/RESULT observations.
            `uvm_fatal("UAG1_TODO", "complete passive prediction and checking")
        endfunction

        task wait_for_results(int unsigned target);
            while (results_checked < target)
                @checked_event;
        endtask
    endclass

    class ua_g1_coverage extends uvm_subscriber #(ua_g1_apb_item);
        `uvm_component_utils(ua_g1_coverage)
        int unsigned sampled_addr;
        bit sampled_write;
        bit sampled_error;
        int unsigned sampled_result_class;
        bit [4:0] address_mask;
        bit saw_read;
        bit saw_write;
        bit saw_error;
        bit saw_success;
        bit saw_normal_result;
        bit saw_saturated_result;
        int unsigned samples;

        covergroup apb_cg;
            option.per_instance = 1;
            address_cp: coverpoint sampled_addr {
                bins mapped[] = {0, 4, 8, 12, 16};
            }
            direction_cp: coverpoint sampled_write {
                bins read = {0};
                bins write = {1};
            }
            response_cp: coverpoint sampled_error {
                bins success = {0};
                bins error = {1};
            }
            result_cp: coverpoint sampled_result_class {
                bins normal = {1};
                bins saturated = {2};
                ignore_bins not_result = {0};
            }
        endgroup

        function new(string name, uvm_component parent);
            super.new(name, parent);
            apb_cg = new();
        endfunction

        virtual function void write(ua_g1_apb_item t);
            // TODO: Sample completed monitored traffic into the covergroup and
            // update the explicit requirement flags used by the final checker.
            `uvm_fatal("UAG1_TODO", "complete monitor-driven coverage sampling")
        endfunction
    endclass

    class ua_g1_apb_agent extends uvm_agent;
        `uvm_component_utils(ua_g1_apb_agent)
        ua_g1_apb_sequencer sequencer;
        ua_g1_apb_driver driver;
        ua_g1_apb_monitor monitor;

        function new(string name, uvm_component parent);
            super.new(name, parent);
        endfunction

        function void build_phase(uvm_phase phase);
            super.build_phase(phase);
            sequencer = ua_g1_apb_sequencer::type_id::create("sequencer", this);
            driver = ua_g1_apb_driver::type_id::create("driver", this);
            monitor = ua_g1_apb_monitor::type_id::create("monitor", this);
        endfunction

        function void connect_phase(uvm_phase phase);
            super.connect_phase(phase);
            driver.seq_item_port.connect(sequencer.seq_item_export);
        endfunction
    endclass

    class ua_g1_scenario_seq extends uvm_reg_sequence;
        `uvm_object_utils(ua_g1_scenario_seq)
        ua_g1_reg_block model;
        int unsigned verified;
        int unsigned rejected;
        int unsigned polls;

        function new(string name = "ua_g1_scenario_seq");
            super.new(name);
        endfunction

        virtual task body();
            // TODO: Execute the specified disabled-command, normal-result, and
            // saturating-result scenarios through RAL. Check every status and
            // returned value; use bounded STATUS polling rather than a delay.
            `uvm_fatal("UAG1_TODO", "complete response-driven RAL scenario")
        endtask
    endclass

    class ua_g1_env extends uvm_env;
        `uvm_component_utils(ua_g1_env)
        ua_g1_apb_agent agent;
        ua_g1_scoreboard scoreboard;
        ua_g1_coverage coverage;
        ua_g1_reg_adapter adapter;
        ua_g1_reg_block model;
        uvm_reg_predictor #(ua_g1_apb_item) predictor;

        function new(string name, uvm_component parent);
            super.new(name, parent);
        endfunction

        function void build_phase(uvm_phase phase);
            super.build_phase(phase);
            agent = ua_g1_apb_agent::type_id::create("agent", this);
            scoreboard = ua_g1_scoreboard::type_id::create("scoreboard", this);
            coverage = ua_g1_coverage::type_id::create("coverage", this);
            adapter = ua_g1_reg_adapter::type_id::create("adapter");
            predictor = uvm_reg_predictor #(ua_g1_apb_item)::type_id::create(
                "predictor", this);
            model = new("model");
            model.build();
            model.reset();
            model.default_map.set_auto_predict(0);
        endfunction

        function void connect_phase(uvm_phase phase);
            super.connect_phase(phase);
            model.default_map.set_sequencer(agent.sequencer, adapter);
            predictor.map = model.default_map;
            predictor.adapter = adapter;
            agent.monitor.completed_ap.connect(predictor.bus_in);
            agent.monitor.completed_ap.connect(scoreboard.analysis_export);
            agent.monitor.completed_ap.connect(coverage.analysis_export);
        endfunction
    endclass

    class ua_g1_test extends uvm_test;
        `uvm_component_utils(ua_g1_test)
        ua_g1_env env;
        ua_g1_scenario_seq scenario;

        function new(string name, uvm_component parent);
            super.new(name, parent);
        endfunction

        function void build_phase(uvm_phase phase);
            super.build_phase(phase);
            env = ua_g1_env::type_id::create("env", this);
        endfunction

        virtual function ua_g1_scenario_seq create_scenario();
            return ua_g1_scenario_seq::type_id::create("scenario");
        endfunction

        task run_phase(uvm_phase phase);
            bit drained;
            phase.raise_objection(this);

            if (env == null)
                `uvm_fatal("UAG1_ENV", "environment was not built")
            if (env.model == null)
                `uvm_fatal("UAG1_MODEL", "RAL model was not built")

            scenario = create_scenario();
            if (scenario == null)
                `uvm_fatal("UAG1_SEQ", "scenario was not created")
            scenario.model = env.model;
            scenario.start(null);

            drained = 0;
            fork
                begin
                    env.scoreboard.wait_for_results(2);
                    drained = 1;
                end
                begin
                    repeat (30) @(posedge env.agent.monitor.vif.pclk);
                end
            join_any
            disable fork;

            if (!drained)
                `uvm_fatal("UAG1_DRAIN", "scoreboard did not check two results")
            if ((scenario.verified != 2) || (scenario.rejected != 1))
                `uvm_fatal("UAG1_SCENARIO", $sformatf(
                    "verified=%0d rejected=%0d polls=%0d",
                    scenario.verified, scenario.rejected, scenario.polls))
            if ((env.scoreboard.results_checked != 2) ||
                (env.scoreboard.mismatches != 0))
                `uvm_fatal("UAG1_RESULT", $sformatf(
                    "checked=%0d mismatches=%0d",
                    env.scoreboard.results_checked, env.scoreboard.mismatches))
            if (env.agent.monitor.observed != env.agent.driver.driven)
                `uvm_fatal("UAG1_OBSERVE", $sformatf(
                    "observed=%0d driven=%0d", env.agent.monitor.observed,
                    env.agent.driver.driven))
            if ((env.coverage.address_mask != 5'b11111) ||
                !env.coverage.saw_read || !env.coverage.saw_write ||
                !env.coverage.saw_error || !env.coverage.saw_success ||
                !env.coverage.saw_normal_result ||
                !env.coverage.saw_saturated_result)
                `uvm_fatal("UAG1_COVERAGE", $sformatf(
                    "addr_mask=0x%0h read=%0b write=%0b error=%0b success=%0b normal=%0b saturated=%0b",
                    env.coverage.address_mask, env.coverage.saw_read,
                    env.coverage.saw_write, env.coverage.saw_error,
                    env.coverage.saw_success,
                    env.coverage.saw_normal_result,
                    env.coverage.saw_saturated_result))

            $display("UAG1_TRACE checked=%0d mismatches=%0d observed=%0d driven=%0d polls=%0d coverage_samples=%0d",
                env.scoreboard.results_checked, env.scoreboard.mismatches,
                env.agent.monitor.observed, env.agent.driver.driven,
                scenario.polls, env.coverage.samples);
            $display("TEST_RESULT: PASS");
            phase.drop_objection(this);
        endtask
    endclass
endpackage
