package ub_g1_pkg;
    import uvm_pkg::*;
    `include "uvm_macros.svh"

    class fifo_item extends uvm_sequence_item;
    rand bit rst;
    rand bit wr_en;
    rand bit rd_en;
    rand bit [7:0] wdata;
    bit         is_stop;
    logic [7:0] rdata  ;
    logic       full   ;
    logic       empty  ;
    logic [2:0] count  ;

    `uvm_object_utils_begin(fifo_item)
    `uvm_field_int(rst, UVM_DEFAULT)
    `uvm_field_int(wr_en, UVM_DEFAULT)
    `uvm_field_int(rd_en, UVM_DEFAULT)
    `uvm_field_int(wdata, UVM_DEFAULT)
    `uvm_field_int(is_stop, UVM_DEFAULT)
    `uvm_field_int(rdata, UVM_DEFAULT)
    `uvm_field_int(full, UVM_DEFAULT)
    `uvm_field_int(empty, UVM_DEFAULT)
    `uvm_field_int(count, UVM_DEFAULT)
    `uvm_object_utils_end

    function new(string name = "fifo_item");
        super.new(name);
    endfunction

    function string convert2string();
        return $sformatf("rst=%0b wr=%0b rd=%0b wdata=0x%02h rdata=0x%02h full=%0b empty=%0b count=%0d",
            rst, wr_en, rd_en, wdata, rdata, full, empty, count);
    endfunction
    endclass

    class fifo_sequencer extends uvm_sequencer #(fifo_item);
        `uvm_component_utils(fifo_sequencer)
        function new(string name, uvm_component parent);
            super.new(name, parent);
        endfunction
    endclass

    class fifo_sequence extends uvm_sequence #(fifo_item);
        `uvm_object_utils(fifo_sequence)
        int unsigned responses;

        function new(string name = "fifo_sequence");
            super.new(name);
        endfunction

        task issue(bit rst, bit wr_en, bit rd_en, bit [7:0] wdata,
                bit is_stop, output fifo_item rsp);
            fifo_item req;
            req = fifo_item::type_id::create("req");
            start_item(req);
            req.rst = rst;
            req.wr_en = wr_en;
            req.rd_en = rd_en;
            req.wdata = wdata;
            req.is_stop = is_stop;
            finish_item(req);
            get_response(rsp);
            responses++;
        endtask

        task body();
            // TODO: Implement the supplied plan as a bounded response-driven
            // scenario. Responses choose the next request; they do not prove DUT
            // correctness. Finish with one stop request.
            fifo_item rsp;
            int count;
            
            rsp = fifo_item::type_id::create();
            count = 0;
            issue(1'b1, 1'b1, 1'b1, 8'hFF, 1'b0, rsp); // Reset

            while(!rsp.full && count < 4) begin
                issue(1'b0, 1'b1, 1'b0, 8'hFF, 1'b0, rsp); // Write until full
                count++;
            end
            if(!rsp.full) begin
                `uvm_fatal("UBG1_FULL", "DUT fails to respond with full flag")
            end

            issue(1'b0, 1'b1, 1'b0, 8'hFF, 1'b0, rsp); // Try to write during full
            issue(1'b0, 1'b0, 1'b1, 8'h0, 1'b0, rsp); // Read
            issue(1'b0, 1'b1, 1'b0, 8'hAA, 1'b0, rsp); // Recovery Write

            issue(1'b0, 1'b0, 1'b1, 8'h0, 1'b0, rsp); // Read, move to intermediate occupancy
            issue(1'b0, 1'b1, 1'b1, 8'h10, 1'b0, rsp); // Sim read/write
            
            count = 0;
            while(!rsp.empty && count < 4) begin
                issue(1'b0, 1'b0, 1'b1, 8'h0, 1'b0, rsp); // Read until empty
                count++;
            end
            if(!rsp.empty) begin
                `uvm_fatal("UBG1_FULL", "DUT fails to respond with empty flag")
            end

            issue(1'b0, 1'b0, 1'b1, 8'h0, 1'b0, rsp); // Attempt read duing empty

            count = 0;
            while(!rsp.full && count < 4) begin
                issue(1'b0, 1'b1, 1'b0, 8'hFF, 1'b0, rsp); // Write until full
                count++;
            end
            if(!rsp.full) begin
                `uvm_fatal("UBG1_FULL", "DUT fails to respond with full flag")
            end

            count = 0;
            while(!rsp.empty && count < 4) begin
                issue(1'b0, 1'b0, 1'b1, 8'h0, 1'b0, rsp); // Read until empty
                count++;
            end
            if(!rsp.empty) begin
                `uvm_fatal("UBG1_FULL", "DUT fails to respond with empty flag")
            end

            issue(1'b0, 1'b0, 1'b0, 8'h0, 1'b1, rsp); // Stop;
        endtask
    endclass

    class fifo_driver extends uvm_driver #(fifo_item);
        `uvm_component_utils(fifo_driver)
        virtual fifo_if vif;
        int unsigned driven;
        bit          done  ;

        function new(string name, uvm_component parent);
            super.new(name, parent);
        endfunction

        function void build_phase(uvm_phase phase);
            super.build_phase(phase);
            if (!uvm_config_db #(virtual fifo_if)::get(this, "", "vif", vif))
                `uvm_fatal("UBG1_VIF", "driver did not receive fifo_if")
        endfunction

        task run_phase(uvm_phase phase);
            // TODO: Complete each request exactly once. Drive before the active edge,
            // sample the settled DUT status into a separate routed response, and
            // handle the stop item without creating a monitor observation.
            fifo_item trans;
            fifo_item rsp;

            @(negedge vif.clk);
            vif.rst = 1'b0;
            vif.wr_en = 1'b0;
            vif.rd_en = 1'b0;
            vif.wdata = '0;
            vif.sample_valid = 1'b0;

            forever begin
                trans = fifo_item::type_id::create();
                seq_item_port.get_next_item(trans);
                if(trans.is_stop) begin
                    done  = 1'b1;
                    rsp = fifo_item::type_id::create();
                    rsp.set_id_info(trans);
                    seq_item_port.item_done(rsp);
                end
                else begin
                    @(negedge vif.clk);
                    vif.rst = trans.rst;
                    vif.wr_en = trans.wr_en;
                    vif.rd_en = trans.rd_en;
                    vif.wdata = trans.wdata;

                    vif.sample_valid = 1'b1; // Let monitor know transaction is valid
                    
                    @(posedge vif.clk); // Wait for response
                    #1ns;

                    rsp = fifo_item::type_id::create();
                    rsp.set_id_info(trans);
                    rsp.empty = vif.empty;
                    rsp.full = vif.full;
                    rsp.count = vif.count;
                    rsp.rdata = vif.rdata;
                    seq_item_port.item_done(rsp);
                    driven++;
                    // Drive idle cycles to "clean"
                    @(negedge vif.clk);
                    vif.rst = 1'b0;
                    vif.wr_en = 1'b0;
                    vif.rd_en = 1'b0;
                    vif.wdata = '0;            
                    vif.sample_valid = 1'b0;
                end
            end
        endtask
    endclass

    class fifo_monitor extends uvm_monitor;
        `uvm_component_utils(fifo_monitor)
        virtual fifo_if vif;
        uvm_analysis_port #(fifo_item) observed_ap;
        int unsigned observed;

        function new(string name, uvm_component parent);
            super.new(name, parent);
            observed_ap = new("observed_ap", this);
        endfunction

        function void build_phase(uvm_phase phase);
            super.build_phase(phase);
            if (!uvm_config_db #(virtual fifo_if)::get(this, "", "vif", vif))
                `uvm_fatal("UBG1_VIF", "monitor did not receive fifo_if")
        endfunction

        task run_phase(uvm_phase phase);
            fifo_item trans;
            forever begin
                @(posedge vif.clk);
                if(vif.sample_valid) begin
                    trans = fifo_item::type_id::create();
                    trans.rst = vif.rst;
                    trans.wr_en = vif.wr_en;
                    trans.rd_en = vif.rd_en;
                    trans.wdata = vif.wdata;

                    #1ns;
                    trans.empty = vif.empty;
                    trans.full = vif.full;
                    trans.count = vif.count;
                    trans.rdata = vif.rdata;

                    observed_ap.write(trans);
                    observed++;
                end
            end
        endtask
    endclass

    class fifo_scoreboard extends uvm_subscriber #(fifo_item);
        `uvm_component_utils(fifo_scoreboard)
        bit          [7:0] model         [$];
        bit          [7:0] expected_rdata   ;
        int unsigned       checked          ;
        int unsigned       mismatches       ;

        function new(string name, uvm_component parent);
            super.new(name, parent);
        endfunction

        function void write(fifo_item t);
            bit expected_empty;
            bit expected_full;
            int expected_count;

            // Update independent model
            if(t.rst == 1'b1) begin
                model.delete();
                expected_rdata = '0;
            end else begin
                bit write_accept = t.wr_en && model.size() < 4;
                bit read_accept = t.rd_en && model.size() > 0;
                
                if(read_accept) begin
                    expected_rdata = model.pop_front();
                end 
                if(write_accept) begin
                    model.push_back(t.wdata);
                end 
            end

            expected_empty = model.size() == 0;
            expected_full = model.size() ==  4;
            expected_count = model.size();

            // Check against expected
            if(t.empty != expected_empty || t.full != expected_full || t.count != expected_count || t.rdata != expected_rdata) begin
                mismatches++;
                `uvm_error("UBG1_MISMATCH", $sformatf("Observed transaction: %s, Expected transaction: empty= %0d, full= %0d, count= %0d, rdata= %h", t.convert2string(), expected_empty, expected_full, expected_count, expected_rdata))
            end 
                
            checked++;
        endfunction
    endclass

    class fifo_coverage extends uvm_subscriber #(fifo_item);
        `uvm_component_utils(fifo_coverage)
        bit                sampled_reset   ;
        bit          [1:0] sampled_request ;
        bit          [2:0] sampled_count   ;
        bit          [1:0] sampled_boundary;
        int unsigned       samples         ;

        covergroup fifo_cg;
            option.per_instance = 1;
            cp_reset: coverpoint sampled_reset {
                bins deasserted = {0}; bins asserted = {1};
            }
            cp_request: coverpoint sampled_request iff (!sampled_reset) {
                bins        write = {2'b10}; bins read = {2'b01}; bins both = {2'b11};
                ignore_bins idle  = {2'b00};
            }
            cp_count: coverpoint sampled_count {
                bins zero  = {0}; bins one = {1}; bins two = {2};
                bins three = {3}; bins full = {4};
            }
            cp_boundary: coverpoint sampled_boundary {
                bins         middle        = {2'b00}; bins empty = {2'b01}; bins full = {2'b10};
                illegal_bins contradictory = {2'b11};
            }
        endgroup

        function new(string name, uvm_component parent);
            super.new(name, parent);
            fifo_cg = new;
        endfunction

        function void write(fifo_item t);
            sampled_reset = t.rst;
            sampled_request = {t.wr_en, t.rd_en};
            sampled_count = t.count;
            sampled_boundary = {t.full, t.empty};
            fifo_cg.sample();
            samples++;
        endfunction
    endclass

    class fifo_agent extends uvm_agent;
        `uvm_component_utils(fifo_agent)
        fifo_sequencer sequencer;
        fifo_driver    driver   ;
        fifo_monitor   monitor  ;

        function new(string name, uvm_component parent);
            super.new(name, parent);
        endfunction

        function void build_phase(uvm_phase phase);
            super.build_phase(phase);
            monitor = fifo_monitor::type_id::create("monitor", this);
            if (get_is_active() == UVM_ACTIVE) begin
                sequencer = fifo_sequencer::type_id::create("sequencer", this);
                driver = fifo_driver::type_id::create("driver", this);
            end
        endfunction

        function void connect_phase(uvm_phase phase);
            super.connect_phase(phase);
            if (get_is_active() == UVM_ACTIVE)
                driver.seq_item_port.connect(sequencer.seq_item_export);
        endfunction
    endclass

    class fifo_env extends uvm_env;
        `uvm_component_utils(fifo_env)
        fifo_agent      agent     ;
        fifo_scoreboard scoreboard;
        fifo_coverage   coverage  ;

        function new(string name, uvm_component parent);
            super.new(name, parent);
        endfunction

        function void build_phase(uvm_phase phase);
            super.build_phase(phase);
            uvm_config_db #(uvm_active_passive_enum)::set(this, "agent", "is_active", UVM_ACTIVE);
            agent = fifo_agent::type_id::create("agent", this);
            scoreboard = fifo_scoreboard::type_id::create("scoreboard", this);
            coverage = fifo_coverage::type_id::create("coverage", this);
        endfunction

        function void connect_phase(uvm_phase phase);
            super.connect_phase(phase);
            agent.monitor.observed_ap.connect(scoreboard.analysis_export);
            agent.monitor.observed_ap.connect(coverage.analysis_export);
        endfunction
    endclass

    class fifo_test extends uvm_test;
        `uvm_component_utils(fifo_test)
        fifo_env env;

        function new(string name, uvm_component parent);
            super.new(name, parent);
        endfunction

        function void build_phase(uvm_phase phase);
            super.build_phase(phase);
            env = fifo_env::type_id::create("env", this);
        endfunction

        task run_phase(uvm_phase phase);
            fifo_sequence scenario;
            real coverage_value;
            phase.raise_objection(this);
            scenario = fifo_sequence::type_id::create("scenario");
            scenario.start(env.agent.sequencer);
            #1ns;
            coverage_value = env.coverage.fifo_cg.get_inst_coverage();
            if (!env.agent.driver.done)
                `uvm_fatal("UBG1_DONE", "driver did not consume the stop request")
            if (env.agent.driver.driven != env.agent.monitor.observed)
                `uvm_fatal("UBG1_COUNT", "driver and monitor operation counts differ")
            if (env.agent.monitor.observed != env.scoreboard.checked)
                `uvm_fatal("UBG1_COUNT", "monitor and scoreboard operation counts differ")
            if (env.scoreboard.model.size() != 0)
                `uvm_fatal("UBG1_DRAIN", "scoreboard model queue did not drain")
            if (coverage_value < 100.0)
                `uvm_fatal("UBG1_COVERAGE", $sformatf("required coverage incomplete: %.2f", coverage_value))
            $display("UBG1_TRACE responses=%0d driven=%0d observed=%0d checked=%0d coverage=%.2f",
                scenario.responses, env.agent.driver.driven, env.agent.monitor.observed,
                env.scoreboard.checked, coverage_value);
            $display("TEST_RESULT: PASS");
            phase.drop_objection(this);
        endtask
    endclass
endpackage
