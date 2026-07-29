package ui_g1_pkg;
    import uvm_pkg::*;
    `include "uvm_macros.svh"

    class counter_txn extends uvm_sequence_item;
    `uvm_object_utils(counter_txn)
    bit       is_reset;
    bit       cmd_valid;
    bit [1:0] cmd;
    bit [7:0] load_value;
    bit [7:0] observed_count;
    function new(string name = "counter_txn"); super.new(name); endfunction
    endclass

        class rst_subsequence extends uvm_sequence #(counter_txn);
            `uvm_object_utils(rst_subsequence)
            function new(string name = "rst_subsequence"); super.new(name); endfunction
            task body();
                counter_txn req;
                req = counter_txn::type_id::create("req");
                start_item(req);
                req.is_reset = 1'b1;
                req.cmd_valid = 1'b0;
                req.cmd = 2'b00;
                req.load_value = 8'hA5; // Global load invariant marker
                finish_item(req);
            endtask
        endclass

        class load_subsequence extends uvm_sequence #(counter_txn);
            bit[7:0] load_value;
            `uvm_object_utils(load_subsequence)
            function new(string name = "load_subsequence"); super.new(name); endfunction
            task body();
                counter_txn req;
                req = counter_txn::type_id::create("req");
                start_item(req);
                req.is_reset = 1'b0;
                req.cmd_valid = 1'b1;
                req.cmd = 2'b00;
                req.load_value = load_value;
                finish_item(req);
            endtask
        endclass

        class inc_subsequence extends uvm_sequence #(counter_txn);
            `uvm_object_utils(inc_subsequence)
            function new(string name = "inc_subsequence"); super.new(name); endfunction
            task body();
                counter_txn req;
                req = counter_txn::type_id::create("req");
                start_item(req);
                req.is_reset = 1'b0;
                req.cmd_valid = 1'b1;
                req.cmd = 2'b01;
                req.load_value = 8'hA5;
                finish_item(req);
            endtask
        endclass

        class dec_subsequence extends uvm_sequence #(counter_txn);
            `uvm_object_utils(dec_subsequence)
            function new(string name = "dec_subsequence"); super.new(name); endfunction
            task body();
                counter_txn req;
                req = counter_txn::type_id::create("req");
                start_item(req);
                req.is_reset = 1'b0;
                req.cmd_valid = 1'b1;
                req.cmd = 2'b10;
                req.load_value = 8'hA5;
                finish_item(req);
            endtask
        endclass

        class clr_subsequence extends uvm_sequence #(counter_txn);
            `uvm_object_utils(clr_subsequence)
            function new(string name = "clr_subsequence"); super.new(name); endfunction
            task body();
                counter_txn req;
                req = counter_txn::type_id::create("req");
                start_item(req);
                req.is_reset = 1'b0;
                req.cmd_valid = 1'b1;
                req.cmd = 2'b11;
                req.load_value = 8'hA5;
                finish_item(req);
            endtask
        endclass

        class hold_subsequence extends uvm_sequence #(counter_txn);
            `uvm_object_utils(hold_subsequence)
            function new(string name = "hold_subsequence"); super.new(name); endfunction
            task body();
                counter_txn req;
                req = counter_txn::type_id::create("req");
                start_item(req);
                req.is_reset = 1'b0;
                req.cmd_valid = 1'b0; // Retain current value
                req.cmd = 2'b01; // Test leaks
                req.load_value = 8'hA5;
                finish_item(req);
            endtask
        endclass

        class counter_scenario extends uvm_sequence #(counter_txn);
            `uvm_object_utils(counter_scenario)
            function new(string name = "counter_scenario"); super.new(name); endfunction
            task body();
                // Generate the thirteen-operation continuous scenario in README order.
                rst_subsequence reset = rst_subsequence::type_id::create("reset");
                load_subsequence load = load_subsequence::type_id::create("load");
                inc_subsequence inc = inc_subsequence::type_id::create("inc");
                dec_subsequence dec = dec_subsequence::type_id::create("dec");
                clr_subsequence clr = clr_subsequence::type_id::create("clr");
                hold_subsequence hold = hold_subsequence::type_id::create("hold");

                // Establish a nonzero value, then prove reset clears it.
                load.load_value = 8'hFF;
                load.start(m_sequencer, this);
                reset.start(m_sequencer, this);

                // Prove normal increment and decrement from controlled setups.
                load.load_value = 8'h05;
                load.start(m_sequencer, this);
                inc.start(m_sequencer, this);
                load.load_value = 8'h05;
                load.start(m_sequencer, this);
                dec.start(m_sequencer, this);

                // Prove clear and retention at zero.
                load.load_value = 8'hFF;
                load.start(m_sequencer, this);
                clr.start(m_sequencer, this);
                hold.start(m_sequencer, this);

                // Prove both wrap directions without resetting between them.
                dec.start(m_sequencer, this);
                inc.start(m_sequencer, this);

                // Prove retention at a nonzero value.
                load.load_value = 8'hAA;
                load.start(m_sequencer, this);
                hold.start(m_sequencer, this);
            endtask
        endclass

        class counter_sequencer extends uvm_sequencer #(counter_txn);
            `uvm_component_utils(counter_sequencer)
            function new(string name, uvm_component parent); super.new(name,parent); endfunction
        endclass

        class counter_driver extends uvm_driver #(counter_txn);
            `uvm_component_utils(counter_driver)
            virtual counter_if vif;
            int completed;
            function new(string name, uvm_component parent); super.new(name,parent); endfunction
            function void build_phase(uvm_phase phase);
                super.build_phase(phase);
                // TODO 2: Get virtual interface "vif" from config_db or fatal.
                if(!uvm_config_db #(virtual counter_if)::get(this, "", "vif", vif)) begin
                    `uvm_fatal("UI_G1_CONFIG", "failed to get virtual interface")
                end
            endfunction
            task run_phase(uvm_phase phase);
                counter_txn req;
                // TODO 3: Initialize the interface inactive, then drive every
                // request before a rising edge. Drive rst_n from is_reset and
                // cmd_valid from the request. Assert sample_cycle only around the
                // requested edge so HOLD is observable. Return the interface
                // inactive afterward; complete and acknowledge thirteen items.
                vif.rst_n = 1'b1;
                vif.cmd_valid = 1'b0;
                vif.cmd = 2'b00;
                vif.load_value = 8'h0;
                vif.sample_cycle = 1'b0; // Part of interface to let TB know that cycle is part of a sequence item

                forever begin
                    // Drive item
                    seq_item_port.get_next_item(req);
                    @(negedge vif.clk);
                    vif.rst_n = !req.is_reset;
                    vif.cmd_valid = req.cmd_valid;
                    vif.cmd = req.cmd;
                    vif.load_value = req.load_value;
                    vif.sample_cycle = 1'b1;
                    @(posedge vif.clk); // Wait for items to be driven
                    seq_item_port.item_done();
                    completed++;

                    @(negedge vif.clk);
                    // Send items back to inactive state
                    vif.rst_n = 1'b1;
                    vif.cmd_valid = 1'b0;
                    vif.cmd = 2'b00;
                    vif.load_value = 8'h0;
                    vif.sample_cycle = 1'b0;
                end
            endtask
        endclass

        class counter_monitor extends uvm_component;
            `uvm_component_utils(counter_monitor)
            virtual counter_if vif;
            uvm_analysis_port #(counter_txn) observed_ap;
            int published;
            function new(string name, uvm_component parent);
                super.new(name,parent);
                observed_ap = new("observed_ap",this);
            endfunction
            function void build_phase(uvm_phase phase);
                super.build_phase(phase);
                // TODO 4: Get virtual interface "vif" from config_db or fatal.
                uvm_config_db #(virtual counter_if)::get(this, "", "vif", vif);
            endfunction
            task run_phase(uvm_phase phase);
                counter_txn observed;
                // TODO 5: On each rising edge when sample_cycle is high, wait 1 ps
                // for the DUT NBA update, capture reset/valid/command/load/count,
                // publish once, and increment published.
                forever @(posedge vif.clk)begin
                    if(vif.sample_cycle) begin
                        observed = counter_txn::type_id::create("observed");
                        observed.is_reset = !vif.rst_n;
                        observed.cmd_valid = vif.cmd_valid;
                        observed.cmd = vif.cmd;
                        observed.load_value = vif.load_value;

                        #1ps; // Sequential update settling
                        observed.observed_count = vif.count;
                        observed_ap.write(observed);
                        published++;
                    end
                end
            endtask
        endclass

        class counter_scoreboard extends uvm_component;
            `uvm_component_utils(counter_scoreboard)
            uvm_analysis_imp #(counter_txn,counter_scoreboard) observed_imp;
            bit [7:0] expected_count;
            int checks;
            function new(string name, uvm_component parent);
                super.new(name,parent);
                observed_imp = new("observed_imp",this);
            endfunction
            function void write(counter_txn observed);
                // TODO 6: Give observed reset priority; retain expected_count when
                // cmd_valid is low; otherwise predict LOAD/INC/DEC/CLEAR. Compare,
                // fatal with useful fields on mismatch, and increment checks.

                // Independent model
                if(observed.is_reset) begin
                    expected_count = 8'h0;
                end else if (observed.cmd_valid) begin
                    unique case (observed.cmd)
                        2'b00 : begin // Predict load
                            expected_count = observed.load_value;
                        end
                        2'b01 : begin // Predict inc
                            expected_count++;
                        end
                        2'b10 : begin // Predict dec
                            expected_count--;
                        end
                        2'b11 : begin // Predict clear
                            expected_count = 8'h0;
                        end
                    endcase
                end // Otherwise retain expected count

                if(observed.observed_count != expected_count) begin
                    `uvm_fatal("U1_G1_MISMATCH", "count does not match")
                end
                checks++;
            endfunction
        endclass

        class counter_coverage extends uvm_subscriber #(counter_txn);
            `uvm_component_utils(counter_coverage)
            bit [1:0]  sampled_cmd  ;
            bit [7:0]  sampled_count;
            bit        sampled_reset;
            bit        sampled_valid;
            int        samples      ;
            covergroup counter_cg   ;
                option.per_instance = 1;
                // TODO 7: Define cp_reset, cp_valid, cp_cmd, and cp_count with
                // named bins. Gate cp_valid off reset and cp_cmd off reset/invalid
                // cycles so RESET/HOLD cannot falsely fill a command bin.
                cp_reset : coverpoint sampled_reset{
                    bins low  = {0};
                    bins high = {1};
                }
                cp_valid : coverpoint sampled_valid iff (!sampled_reset){
                    bins low  = {0};
                    bins high = {1};
                }
                cp_cmd : coverpoint sampled_cmd iff (!sampled_reset && sampled_valid){
                    bins load = {2'b00};
                    bins inc  = {2'b01};
                    bins dec  = {2'b10};
                    bins clear = {2'b11};
                }
                cp_count : coverpoint sampled_count{
                    bins zero    = {8'h0} ;
                    bins maximum = {8'hFF};
                    bins middle  = {[1:254]};
                }
                // TODO 8: Define cx_cmd_count with only the seven required
                // command/result bins from the plan, and cx_valid_count with only
                // hold_zero and hold_middle. Explicitly ignore every other cross
                // combination; XSim 2025.2 cannot elaborate cross_auto_bin_max=0.
                cx_cmd_count : cross cp_cmd, cp_count{
                    bins load_middle = binsof(cp_cmd.load)  && binsof(cp_count.middle) ;
                    bins load_max    = binsof(cp_cmd.load)  && binsof(cp_count.maximum);
                    bins inc_middle  = binsof(cp_cmd.inc)   && binsof(cp_count.middle) ;
                    bins inc_zero    = binsof(cp_cmd.inc)   && binsof(cp_count.zero)   ;
                    bins dec_middle  = binsof(cp_cmd.dec)   && binsof(cp_count.middle) ;
                    bins dec_max     = binsof(cp_cmd.dec)   && binsof(cp_count.maximum);
                    bins clear_zero  = binsof(cp_cmd.clear) && binsof(cp_count.zero)   ;

                    ignore_bins load_zero    = binsof(cp_cmd.load)  && binsof(cp_count.zero)   ;
                    ignore_bins inc_max      = binsof(cp_cmd.inc)   && binsof(cp_count.maximum);
                    ignore_bins dec_zero     = binsof(cp_cmd.dec)   && binsof(cp_count.zero)   ;
                    ignore_bins clear_middle = binsof(cp_cmd.clear) && binsof(cp_count.middle) ;
                    ignore_bins clear_max    = binsof(cp_cmd.clear) && binsof(cp_count.maximum);
                }
                cx_valid_count : cross cp_valid, cp_count{
                    bins hold_zero   = binsof(cp_valid.low) && binsof(cp_count.zero)  ;
                    bins hold_middle = binsof(cp_valid.low) && binsof(cp_count.middle);

                    ignore_bins hold_max      = binsof(cp_valid.low)  && binsof(cp_count.maximum);
                    ignore_bins active_zero   = binsof(cp_valid.high) && binsof(cp_count.zero)   ;
                    ignore_bins active_middle = binsof(cp_valid.high) && binsof(cp_count.middle) ;
                    ignore_bins active_max    = binsof(cp_valid.high) && binsof(cp_count.maximum);
                }
            endgroup
            function new(string name, uvm_component parent);
                super.new(name,parent);
                // TODO 9: Construct embedded counter_cg.
                counter_cg = new();
            endfunction
            function void write(counter_txn observed);
                // TODO 10: Copy observed reset/valid/command/count fields, sample
                // exactly once per published operation, and increment samples.
                sampled_cmd = observed.cmd;
                sampled_valid = observed.cmd_valid;
                sampled_reset = observed.is_reset;
                sampled_count = observed.observed_count;
                counter_cg.sample();
                samples++;
            endfunction
        endclass

        class counter_agent extends uvm_agent;
            `uvm_component_utils(counter_agent)
            counter_sequencer sequencer;
            counter_driver driver;
            counter_monitor monitor;
            function new(string name, uvm_component parent); super.new(name,parent); endfunction
            function void build_phase(uvm_phase phase);
                super.build_phase(phase);
                // TODO 11: Factory-create sequencer, driver, and monitor.
                sequencer = counter_sequencer::type_id::create("sequencer", this);
                driver = counter_driver::type_id::create("driver", this);
                monitor = counter_monitor::type_id::create("monitor", this);
            endfunction
            function void connect_phase(uvm_phase phase);
                super.connect_phase(phase);
                // TODO 12: Connect driver request port to sequencer export.
                driver.seq_item_port.connect(sequencer.seq_item_export);
            endfunction
        endclass

        class counter_env extends uvm_env;
            `uvm_component_utils(counter_env)
            counter_agent agent;
            counter_scoreboard scoreboard;
            counter_coverage coverage;
            function new(string name,uvm_component parent); super.new(name,parent); endfunction
            function void build_phase(uvm_phase phase);
                super.build_phase(phase);
                // TODO 13: Factory-create agent, scoreboard, and coverage.
                agent = counter_agent::type_id::create("agent", this);
                scoreboard = counter_scoreboard::type_id::create("scoreboard", this);
                coverage = counter_coverage::type_id::create("coverage", this);
            endfunction
            function void connect_phase(uvm_phase phase);
                super.connect_phase(phase);
                // TODO 14: Broadcast monitor observations to scoreboard and coverage.
                agent.monitor.observed_ap.connect(scoreboard.observed_imp);
                agent.monitor.observed_ap.connect(coverage.analysis_export);
            endfunction
        endclass

        class counter_test extends uvm_test;
            `uvm_component_utils(counter_test)
            counter_env env;
            function new(string name,uvm_component parent); super.new(name,parent); endfunction
            function void build_phase(uvm_phase phase);
                super.build_phase(phase);
                env = counter_env::type_id::create("env",this);
            endfunction
            task run_phase(uvm_phase phase);
                counter_scenario scenario;
                uvm_report_server server;
                real coverage_pct;
                int errors, fatals;
                // TODO 15: Raise objection, create/start scenario, allow final
                // monitor publication, query coverage and report counts, and fatal
                // unless driver/monitor/scoreboard/coverage counts are all 13,
                // coverage is 100%, and errors/fatals are zero.
                // Print exact:
                // INTEGRATION_TRACE: driven=13 observed=13 checked=13 sampled=13 coverage=100.00 errors=0 fatals=0
                // TEST_RESULT: PASS
                // Drop objection.
                phase.raise_objection(this);
                scenario = counter_scenario::type_id::create("scenario");
                scenario.start(env.agent.sequencer);
                @(negedge env.agent.driver.vif.clk); // Wait for driver to finish, monitor finish
                server = uvm_report_server::get_server();
                errors = server.get_severity_count(UVM_ERROR);
                fatals = server.get_severity_count(UVM_FATAL);

                coverage_pct = env.coverage.counter_cg.get_inst_coverage();
                $display("INTEGRATION_TRACE: driven=%0d observed=%0d checked=%0d sampled=%0d coverage=%.2f errors=%0d fatals=%0d", 
                    env.agent.driver.completed,
                    env.agent.monitor.published,
                    env.scoreboard.checks,
                    env.coverage.samples, 
                    coverage_pct,
                    errors,
                    fatals
                    );
                
                if( env.agent.driver.completed != 13 ||
                    env.agent.monitor.published != 13 ||
                    env.scoreboard.checks != 13 ||
                    env.coverage.samples != 13 || 
                    errors != 0 ||
                    fatals != 0 ||  
                    coverage_pct < 100.0)
                    `uvm_fatal("U1_G1_VERDICT", "One or more of the qualifying fields has failed")
                
                $display("TEST_RESULT: PASS");
                phase.drop_objection(this);
            endtask
        endclass
    endpackage
