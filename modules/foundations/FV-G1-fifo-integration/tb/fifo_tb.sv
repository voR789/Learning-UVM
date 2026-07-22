module fifo_tb ();
    localparam int WIDTH = 8                ;
    localparam int DEPTH = 4                ;
    localparam int CNT_W = $clog2(DEPTH + 1);

    logic             clk   = 1'b0;
    logic             rst         ;
    logic             wr_en       ;
    logic             rd_en       ;
    logic [WIDTH-1:0] wdata       ;
    logic [WIDTH-1:0] rdata       ;
    logic             full        ;
    logic             empty       ;
    logic [CNT_W-1:0] count       ;

    int unsigned stimulus_count = 0;
    int unsigned monitor_count = 0; // Use explicit counts for driver and monitor because monitor has bridge across DUT
    int unsigned check_count = 0;
    int unsigned error_count = 0;
    bit driver_done;
    event check_done;

    always #5ns clk = ~clk;

    sync_fifo #(
        .WIDTH(WIDTH),
        .DEPTH(DEPTH)
    ) dut (
        .clk,
        .rst,
        .wr_en,
        .rd_en,
        .wdata,
        .rdata,
        .full,
        .empty,
        .count
    );

    // Request transactions, package what we request to be driven into the DUT

    typedef struct{
        logic is_end;
        logic rst  ;
        logic wr_en;
        logic rd_en;
        logic[WIDTH-1:0] wdata;
    } req_trans;
    // Observation transactions, package what actually goes in and out of DUT
    typedef struct {
        logic is_end;
        // Input observations
        logic             rst  ;
        logic             wr_en;
        logic             rd_en;
        logic [WIDTH-1:0] wdata;
        // Output observations (sampled after sequential settling)
        logic [WIDTH-1:0] rdata;
        logic             full ;
        logic             empty;
        logic [CNT_W-1:0] count;
    } observ_trans;

    
    covergroup fifo_cg with function sample(
            logic sampled_rst,
            logic sampled_wr_en,
            logic sampled_rd_en,
            logic sampled_wr_accept,
            logic sampled_rd_accept,
            int occupancy_pre
        );
        option.per_instance = 1;

        rst_cp : coverpoint sampled_rst;
        wr_en_cp : coverpoint sampled_wr_en iff(!sampled_rst);
        rd_en_cp : coverpoint sampled_rd_en iff(!sampled_rst);
        wr_cp : coverpoint sampled_wr_accept iff(!sampled_rst);
        rd_cp : coverpoint sampled_rd_accept iff(!sampled_rst);
        occ_cp : coverpoint occupancy_pre iff(!sampled_rst){
            bins valid_occ[] = {[0:DEPTH]};
            illegal_bins invalid_occ = default;
        }

        // Cover read/write attempts accross all sizes
        wr_en_occupancy: cross wr_en_cp, occ_cp;
        rd_en_occupancy: cross rd_en_cp, occ_cp;

        wr_rd: cross wr_en_cp, rd_en_cp {
            illegal_bins no_op = binsof(wr_en_cp) intersect {0} &&
            binsof(rd_en_cp) intersect {0};
        }

        sim_op: cross wr_en_cp, rd_en_cp, occ_cp {
            illegal_bins no_op = binsof(wr_en_cp) intersect {0} && binsof(rd_en_cp) intersect {0};
        }

    endgroup

    mailbox #(req_trans) gen_to_drv = new();
    mailbox #(observ_trans) mon_to_scb = new();
    mailbox #(observ_trans) mon_to_pre = new();
    mailbox #(observ_trans) pre_to_scb = new();
    static fifo_cg cg; // Make static so it persists
    real coverage_percent;

    // Helper functions
    task done();
        req_trans req;
        req.is_end = 1'b1;
        req.rst = 1'b0;
        req.wr_en = 1'b0;
        req.rd_en = 1'b0;
        req.wdata = '0;
        gen_to_drv.put(req);
    endtask

    task write(logic [WIDTH-1:0] wdata);
        req_trans req;
        req.is_end = 1'b0;
        req.rst = 1'b0;
        req.wr_en = 1'b1;
        req.rd_en = 1'b0;
        req.wdata = wdata;
        gen_to_drv.put(req);
    endtask

    task read(logic [WIDTH-1:0] wdata);
        req_trans req;
        req.is_end = 1'b0;
        req.rst = 1'b0;
        req.wr_en = 1'b0;
        req.rd_en = 1'b1;
        req.wdata = wdata;
        gen_to_drv.put(req);
    endtask

    task read_write(logic [WIDTH-1:0] wdata);
        req_trans req;
        req.is_end = 1'b0;
        req.rst = 1'b0;
        req.wr_en = 1'b1;
        req.rd_en = 1'b1;
        req.wdata = wdata;
        gen_to_drv.put(req);
    endtask

    task reset();
        req_trans req;
        req.is_end = 1'b0;
        req.rst = 1'b1;
        req.wr_en = 1'b0;
        req.rd_en = 1'b0;
        req.wdata = '0;
        gen_to_drv.put(req);
    endtask

    task custom_operation(logic rst, logic wr_en, logic rd_en, logic [WIDTH-1:0] wdata);
        req_trans req;
        req.is_end = 1'b0;
        req.rst = rst;
        req.wr_en = wr_en;
        req.rd_en = rd_en;
        req.wdata = wdata;
        gen_to_drv.put(req);
    endtask

    task run_reset_basic(); // FIFO-RST-01
        $display("===================");
        $display("Running FIFO-RST-01");
        // Prior reset
        reset();

        reset();
        reset();
    endtask

    task run_reset_write_read(); // FIFO-RST-02
        $display("===================");
        $display("Running FIFO-RST-02");
        // Setup
        reset();
        write(8'hAA);

        // Send reset with read/write
        custom_operation(1, 1, 1, 8'hFF);
        read(8'hEE);
    endtask

    task run_empty_full(); // FIFO-EMPTY-FULL-01
        $display("==========================");
        $display("Running FIFO-EMPTY-FULL-01");
        reset();

        for(int i = 0; i < DEPTH; i++) begin
            write(8'(i));
        end
        write(8'hFF);
        repeat(DEPTH+1) begin
            read(8'h0);
        end
    endtask

    task run_empty_rd(); // FIFO-EMPTY-RD-01
        $display("========================");
        $display("Running FIFO-EMPTY-RD-01");
        reset();

        write(8'hFF);
        read(8'h0);
        read(8'h0);
        write(8'hAA);
        read(8'h0);
    endtask


    task run_sim_rd_wr(); // FIFO-SIM-01
        $display("===================");
        $display("Running FIFO-SIM-01");
        reset();

        read_write(8'hFF);
        read_write(8'hEE);
        repeat(DEPTH-1) begin
            write(8'hDD);
        end
        read_write(8'hCC);
        repeat(DEPTH-1) begin
            read(8'h0);
        end
    endtask

    task run_full_recovery(); // FIFO-FULL-RECOVERY-01
        $display("=============================");
        $display("Running FIFO-FULL-RECOVERY-01");
        reset();

        for(int i = 0; i < DEPTH; i++) begin
            write(8'(i));
        end
        write(8'hF0);
        read(8'h0);
        write(8'hA5);
        repeat(DEPTH) begin
            read(8'h0);
        end
    endtask

    task run_fifo_wrap(); // FIFO-WRAP-01
        $display("====================");
        $display("Running FIFO-WRAP-01");
        reset();

        // A/B series
        for(int i = 0; i < DEPTH; i++) begin
            write(i);
        end
        repeat(DEPTH/2) begin
            read(8'h0);
        end
        for(int i = 0; i < DEPTH/2; i++) begin
            write(i*10);
        end
        repeat(DEPTH) begin
            read(8'h0);
        end

        // C/D series
        for(int i = 0; i < DEPTH; i++) begin
            write(i*3);
        end
        repeat(DEPTH/2) begin
            read(8'h0);
        end
        for(int i = 0; i < DEPTH/2; i++) begin
            write(i*7);
        end
        repeat(DEPTH) begin
            read(8'h0);
        end
    endtask

    task run_sim_all(); // Custom task for coverage
        reset();
        for(int i = 0; i < DEPTH; i++) begin
            write(8'hAA);
            read_write(8'hDD);
        end
        for(int i = 0; i < DEPTH; i++) begin
            read(8'h0);
            read_write(8'hCC);
        end
    endtask

    class randomized_request ;
        rand logic rst;
        rand logic wr_en;
        rand logic rd_en;
        rand logic [WIDTH-1:0] wdata;

        constraint legal_request{
            if(!rst)
            wr_en || rd_en; // Cannot both be zero
        }
        constraint rst_distribution{
            rst dist {
                1'b1 := 5,
                1'b0 := 95
            };
        }
    endclass

    task run_randomized();
        automatic randomized_request req_rand = new();
        if(!req_rand.randomize()) begin
            $fatal(1, "Failed to randomize randomized request transaction!");
        end else begin
            req_trans req;
            req.is_end = 1'b0;
            req.rst = req_rand.rst;
            req.wr_en = req_rand.wr_en;
            req.rd_en = req_rand.rd_en;
            req.wdata = req_rand.wdata;
            gen_to_drv.put(req);
        end
    endtask

    task driver(); // Drive inputs
        // Notes, use forever polling with conditional end .kind in mailbox to kill with break statement
        forever begin
            req_trans req;
            gen_to_drv.get(req);
            if (req.is_end) begin // Send "end" transaction to finish processes/drain
                driver_done = 1'b1;
                @(negedge clk);
                rst   = 1'b0;
                wr_en = 1'b0;
                rd_en = 1'b0;
                wdata = '0;
                break;
            end else begin
                @(negedge clk);
                rst   = req.rst;
                wr_en = req.wr_en;
                rd_en = req.rd_en;
                wdata = req.wdata;
                stimulus_count++;
            end
        end
    endtask

    task monitor(); // Observe
        observ_trans observ;
        forever begin
            @(posedge clk);    
            if( rst || wr_en || rd_en ) begin
                observ.is_end = 1'b0;
                observ.rst = rst;
                observ.wr_en = wr_en;
                observ.rd_en = rd_en;
                observ.wdata = wdata;

                #1ns; // Allow sequential updates to settle

                observ.rdata = rdata;
                observ.full = full;
                observ.empty = empty;
                observ.count = count;
                monitor_count++;    

                mon_to_pre.put(observ); // Predicted
                mon_to_scb.put(observ); // Actual
            end else begin
                #1ns;
            end
            assert(!$isunknown({full,count}) && (full === (count == DEPTH)))
                else begin
                    error_count++;
                    $display("Full/count invariant failed!");
                end
                
            assert(!$isunknown({empty,count}) && (empty === (count == 0)))
                else begin
                    error_count++;
                    $display("Empty/count invariant failed!");
                end
            if(driver_done && (monitor_count == stimulus_count)) begin
                    observ.is_end = 1'b1;
                    // Send end tokens
                    mon_to_pre.put(observ); // Predicted
                    mon_to_scb.put(observ); // Actual
                    break;
                end 
        end
    endtask

    task predictor(); // Independent model
        logic [WIDTH-1:0] model [$];
        logic wr_accept;
        logic rd_accept;
        logic [WIDTH-1:0] expected_rdata;
        observ_trans observed;
        observ_trans predicted;
        forever begin
            mon_to_pre.get(observed);
            if(observed.is_end) begin
                predicted.is_end = 1'b1;
                pre_to_scb.put(predicted);
                break;
            end else begin
                wr_accept = observed.wr_en && model.size() < DEPTH;
                rd_accept = observed.rd_en && model.size() > 0;
  
                cg.sample(
                    observed.rst,
                    observed.wr_en,
                    observed.rd_en,
                    wr_accept,
                    rd_accept,
                    model.size()
                );

                if(observed.rst) begin
                    model.delete();
                    expected_rdata = 0;
                end else begin
                    if(rd_accept) begin
                        expected_rdata = model.pop_front();
                    end

                    if(wr_accept) begin
                        model.push_back(observed.wdata);
                    end
                end

                predicted.is_end = 1'b0;
                predicted.rdata = expected_rdata;
                predicted.full = (model.size() === DEPTH);
                predicted.empty = (model.size() === 0);
                predicted.count = model.size();

                pre_to_scb.put(predicted);
            end
        end
    endtask


    task scoreboard(); // DUT state vs Independent model state
        forever begin
            observ_trans observ;
            observ_trans expected;

            mon_to_scb.get(observ);
            pre_to_scb.get(expected);

            if(observ.is_end !== expected.is_end) begin            
                $display("==========================");
                $display("End flag propogation is broken!");
                $display("Monitor end:, %b, Predictor end: %b", observ.is_end, expected.is_end);
                $finish;
            end

            if(observ.is_end && expected.is_end) begin
                $display("==========================");
                $display("Scoreboard has drained!");
                -> check_done;
                break;
            end

            $display("Checking packet: %d", check_count);
            if(observ.rdata !== expected.rdata) begin
                error_count++;
                $display("Error, observed read data is not equal to expected!, @ %t", $time);
                $display("Expected: %h, Observed: %h", expected.rdata, observ.rdata);
            end
            if(observ.full !== expected.full) begin
                error_count++;
                $display("Error, observed full flag is not equal to expected!, @ %t", $time);
                $display("Expected: %b, Observed: %b", expected.count, observ.count);
                $display("Expected: %b, Observed: %b", expected.full, observ.full);

            end
            if(observ.empty !== expected.empty) begin
                error_count++;
                $display("Error, observed empty flag is not equal to expected!, @ %t", $time);
                $display("Expected: %b, Observed: %b", expected.empty, observ.empty);

            end
            if(observ.count !== expected.count) begin
                error_count++;
                $display("Error, observed count is not equal to expected!, @ %t", $time);
                $display("Expected: %b, Observed: %b", expected.count, observ.count);
            end
            $display("==========================");
            check_count++;
        end
    endtask



    initial begin
        rst   = 1'b0;
        wr_en = 1'b0;
        rd_en = 1'b0;
        wdata = '0;

        // Untouched starter: force a clean reset, then leave implementation
        // ownership with the learner.
        @(negedge clk);
        rst = 1'b1;
        repeat (2) @(negedge clk);
        rst = 1'b0;
        cg = new();
        fork   
            driver();
            monitor();
            predictor();
            scoreboard();
        join_none

        run_reset_basic();
        run_reset_write_read();
        run_empty_full();
        run_empty_rd();
        run_sim_rd_wr();
        run_full_recovery();
        run_fifo_wrap();
        run_randomized();
        run_randomized();
        run_sim_all();

        // Drain all for checking
        repeat(DEPTH) begin
            read(8'h0);
        end
        done();

        @(check_done) begin
            if(error_count === 0) begin
                coverage_percent = cg.get_inst_coverage();
                $display("COVERAGE_RESULT: percent=%0.2f", coverage_percent);
                $display("TEST_RESULT: PASS");
                $finish;
            end
        end
    end

    initial begin
        #10us;
        $display("TEST_RESULT: FAIL checks=%0d errors=%0d", check_count, error_count);
        $fatal(1, "FV-G1 timeout or learner testbench not yet implemented");
    end
endmodule
