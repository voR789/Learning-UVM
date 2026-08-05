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
        ua_g1_apb_item obsrv;
        forever begin
            @(posedge vif.pclk);
            if(vif.psel && vif.penable && vif.pready) begin
                obsrv = ua_g1_apb_item::type_id::create();
                // transaction fields
                obsrv.write = vif.pwrite;
                obsrv.addr = vif.paddr;
                obsrv.wdata = vif.pwdata;
                obsrv.rdata = vif.prdata;
                obsrv.error = vif.pslverr;

                completed_ap.write(obsrv);
                observed++;
            end
        end
    endtask
    endclass

        class ua_g1_scoreboard extends uvm_subscriber #(ua_g1_apb_item);
            `uvm_component_utils(ua_g1_scoreboard)
            bit                enable_model     ;
            bit          [7:0] gain_model       ;
            bit          [7:0] expected_result  ;
            bit                expected_overflow;
            bit                expected_valid   ;
            int unsigned       transactions     ;
            int unsigned       results_checked  ;
            int unsigned       mismatches       ;
            event        checked_event    ;

            function new(string name, uvm_component parent);
                super.new(name, parent);
                gain_model = 8'h01;
            endfunction

            virtual function void write(ua_g1_apb_item t);
                // TODO: From the monitored transfer and pre-transfer model state,
                // predict the response class, update state only for accepted writes,
                // and independently check successful STATUS/RESULT observations.
                bit busy;
                bit done;
                bit overflow;
                int inter_prod;
                transactions++;
                // predictions
                if(t.write) begin
                    case(t.addr)
                        8'h00 : if(!t.error) enable_model = t.wdata[0]; // Write ENABLE
                        8'h04 : if(!t.error) gain_model = t.wdata[7:0]; // Write GAIN
                        8'h08 : begin // Write DATA
                            if(enable_model == 1'b0) begin
                                // Raise error flag
                                if(t.error != 1'b1) begin
                                    `uvm_error("UAG1_MISMATCH", "Error flag is not correct!")
                                    mismatches++;
                                end
                            end else if(!t.error)begin
                                inter_prod = gain_model * t.wdata[7:0];
                                if(inter_prod > 255) begin
                                    expected_result = 255;
                                    expected_overflow = 1'b1;
                                end else begin
                                    expected_result = (inter_prod[7:0]);
                                    expected_overflow = 1'b0;
                                end
                                expected_valid = 1'b1;

                            end else begin
                                `uvm_error("UAG1_MISMATCH", "Error flag is not correct!")
                                mismatches++;
                            end
                        end
                        8'h0C : if(t.error != 1'b1) `uvm_error("UAG1_MISMATCH", "Error flag is not correct!") // Read only
                        8'h10 : if(t.error != 1'b1) `uvm_error("UAG1_MISMATCH", "Error flag is not correct!") // Read only
                    endcase
                end

                // checking (read)
                if(!t.write) begin
                    case(t.addr)
                        8'h00 : if(t.rdata != {31'h0, enable_model}) `uvm_error("UAG1_MISMATCH", "Enable does not match")
                        8'h04 : if(t.rdata != {24'h0, gain_model}) `uvm_error("UAG1_MISMATCH", "Gain does not match")
                        8'h08 : if(t.error != 1'b1) `uvm_error("UAG1_MISMATCH", "Error flag is not correct!") // Write only
                        8'h0C : begin // READ Internal STATUS
                            if(!t.error) begin
                                {overflow, done, busy} = t.rdata[2:0];
                                if(expected_valid && done && (overflow != expected_overflow)) begin
                                    `uvm_error("UAG1_MISMATCH", "overflow values do not match")
                                    mismatches++;
                                end
                            end
                        end
                        8'h10 : begin // READ Result
                            if(!t.error)
                                if(expected_valid) begin
                                    if(t.rdata != expected_result) begin
                                        `uvm_error("UAG1_MISMATCH", "Result does not match")
                                        mismatches++;
                                    end
                                    results_checked++;
                                    expected_valid = 1'b0; // Use expected valid as a safeguard against faulty checks
                                    -> checked_event;
                                end
                        end
                    endcase
                end
            endfunction

            task wait_for_results(int unsigned target); // Draining mechanism, continuously waits until results_checked is enough
                while (results_checked < target)
                    @checked_event;
            endtask
        endclass

        class ua_g1_coverage extends uvm_subscriber #(ua_g1_apb_item);
            `uvm_component_utils(ua_g1_coverage)
            int unsigned sampled_addr        ;
            bit          sampled_write       ;
            bit          sampled_error       ;
            int unsigned sampled_result_class;

            bit          saw_saturated_result;
            int unsigned samples             ;

            covergroup apb_cg;
                option.per_instance = 1;
                address_cp: coverpoint sampled_addr {
                    bins mapped[] = {0, 4, 8, 12, 16};
                }
                direction_cp: coverpoint sampled_write {
                    bins read  = {0};
                    bins write = {1};
                }
                response_cp: coverpoint sampled_error {
                    bins success = {0};
                    bins error   = {1};
                }
                result_cp: coverpoint sampled_result_class {
                    bins        normal     = {1};
                    bins        saturated  = {2};
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

                // Set internal flags
                if(t.addr == 8'h0C && !t.error && !t.write && t.rdata[1]) begin
                    saw_saturated_result = t.rdata[2];
                end

                sampled_addr = t.addr;
                sampled_write = t.write;
                sampled_error = t.error      ;
                if(t.addr == 8'h10 && !t.error && !t.write) begin
                    sampled_result_class = saw_saturated_result ? 2 : 1;
                end else begin
                    sampled_result_class = 0;
                end

                apb_cg.sample();
                samples++;
            endfunction
        endclass

        class ua_g1_apb_agent extends uvm_agent;
            `uvm_component_utils(ua_g1_apb_agent)
            ua_g1_apb_sequencer sequencer;
            ua_g1_apb_driver    driver   ;
            ua_g1_apb_monitor   monitor  ;

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
            ua_g1_reg_block model   ;
            int unsigned    verified;
            int unsigned    rejected;
            int unsigned    polls   ;

            function new(string name = "ua_g1_scenario_seq");
                super.new(name);
            endfunction

            virtual task body();
                // TODO: Execute the specified disabled-command, normal-result, and
                // saturating-result scenarios through RAL. Check every status and
                // returned value; use bounded STATUS polling rather than a delay.
                uvm_status_e s;
                logic[31:0] read_data;
                // disbaled-command
                model.data.write(s, {24'h0,  8'h5}, UVM_FRONTDOOR, model.default_map, this);
                if(s != UVM_NOT_OK) begin
                    `uvm_error("UAG1_MISMATCH", "write passed through disable")
                end else
                rejected++;


                //normal-result
                model.control.write(s, {31'h0, 1'b1}, UVM_FRONTDOOR, model.default_map, this); // enable
                if(s != UVM_IS_OK) begin
                    `uvm_error("UAG1_STATUS", "failed write")
                end
                model.gain.write(s, {24'h0, 8'h3}, UVM_FRONTDOOR, model.default_map, this); // gain = 3
                if(s != UVM_IS_OK) begin
                    `uvm_error("UAG1_STATUS", "failed write")
                end
                model.data.write(s, {24'h0, 8'h20}, UVM_FRONTDOOR, model.default_map, this); // data = 20
                if(s != UVM_IS_OK) begin
                    `uvm_error("UAG1_STATUS", "failed write")
                end
                polls = 0;
                do begin // Poll until done
                    model.status.read(s, read_data, UVM_FRONTDOOR, model.default_map, this);
                    if(s != UVM_IS_OK) begin
                        `uvm_error("UAG1_STATUS", "failed read")
                    end
                    polls++;
                end while(!read_data[1] && polls < 5);
                if(polls >= 5 && !read_data[1]) begin
                    `uvm_error("UAG1_POLL", "polling passed limit")
                end else begin
                    model.result.read(s, read_data, UVM_FRONTDOOR, model.default_map, this);
                    if(s != UVM_IS_OK)
                        `uvm_error("UAG1_STATUS", "failed read")
                    else
                        verified++;
                end
                // saturated-result
                model.gain.write(s, {24'h0, 8'h4}, UVM_FRONTDOOR, model.default_map, this); // gain = 3
                if(s != UVM_IS_OK) begin
                    `uvm_error("UAG1_STATUS", "failed write")
                end

                model.data.write(s, {24'h0, 8'h80}, UVM_FRONTDOOR, model.default_map, this); // data = 20
                if(s != UVM_IS_OK) begin
                    `uvm_error("UAG1_STATUS", "failed write")
                end

                polls = 0;
                do begin // Poll until done
                    model.status.read(s, read_data, UVM_FRONTDOOR, model.default_map, this);
                    if(s != UVM_IS_OK) begin
                        `uvm_error("UAG1_STATUS", "failed read")
                    end
                    polls++;
                end while(!read_data[1] && polls < 5);
                if(polls >= 5 && !read_data[1]) begin
                    `uvm_error("UAG1_POLL", "polling passed limit")
                end else begin

                    model.result.read(s, read_data, UVM_FRONTDOOR, model.default_map, this);
                    if(s != UVM_IS_OK)
                        `uvm_error("UAG1_STATUS", "failed read")
                    else
                        verified++;
                end


            endtask
        endclass

        class ua_g1_env extends uvm_env;
            `uvm_component_utils(ua_g1_env)
            ua_g1_apb_agent   agent     ;
            ua_g1_scoreboard  scoreboard;
            ua_g1_coverage    coverage  ;
            ua_g1_reg_adapter adapter   ;
            ua_g1_reg_block   model     ;
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
            ua_g1_env          env     ;
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
                    if (env.coverage.apb_cg.get_inst_coverage() < 100.0)
                        `uvm_fatal("UAG1_COVERAGE", $sformatf(
                            "APB functional coverage is %0.2f%%, expected 100%%",
                            env.coverage.apb_cg.get_inst_coverage()))

                    $display("UAG1_TRACE checked=%0d mismatches=%0d observed=%0d driven=%0d polls=%0d coverage_samples=%0d",
                        env.scoreboard.results_checked, env.scoreboard.mismatches,
                        env.agent.monitor.observed, env.agent.driver.driven,
                        scenario.polls, env.coverage.samples);
                    $display("TEST_RESULT: PASS");
                    phase.drop_objection(this);
                    endtask
                        endclass
                            endpackage
