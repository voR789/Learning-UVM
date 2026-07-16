class add_transaction;
    int unsigned id;
    rand logic [7:0] a;
    rand logic [7:0] b;
    logic [8:0] expected_sum;
    logic [8:0] actual_sum  ;

    function add_transaction copy();
        add_transaction cloned = new();
        cloned.id           = id;
        cloned.a            = a;
        cloned.b            = b;
        cloned.expected_sum = expected_sum;
        cloned.actual_sum   = actual_sum;
        return cloned;
    endfunction
endclass

module concurrency_lab ();
    localparam int unsigned NUM_ITEMS  = 10  ;
    localparam time         CLK_PERIOD = 10ns;

    logic clk = 1'b0;
    always #(CLK_PERIOD / 2) clk = ~clk;

    sync_if bus (clk);

    registered_adder dut (
        .clk      (bus.clk      ),
        .rst_n    (bus.rst_n    ),
        .in_valid (bus.in_valid ),
        .a        (bus.a        ),
        .b        (bus.b        ),
        .out_valid(bus.out_valid),
        .sum      (bus.sum      )
    );

    mailbox gen_to_drv = new();
    mailbox exp_to_sb  = new();
    mailbox mon_to_sb  = new();

    event reset_done   ;
    event checking_done;

    int unsigned generated_count = 0;
    int unsigned driven_count    = 0;
    int unsigned observed_count  = 0;
    int unsigned checked_count   = 0;
    int unsigned error_count     = 0;

    task automatic apply_reset();
        bus.rst_n    = 1'b0;
        bus.in_valid = 1'b0;
        bus.a        = '0;
        bus.b        = '0;
        repeat (2) @(negedge clk);
        bus.rst_n = 1'b1;
        -> reset_done;
    endtask

    task automatic generator();
        // Create, randomize, identify, and enqueue NUM_ITEMS independent
        // transactions. Compute expected_sum from the specification.
        for(int i = 0; i < NUM_ITEMS; i++) begin
            add_transaction item = new();
            item.id = i;
            if(item.randomize()) begin
                $display("Transaction %d", i, " randomized.");
                item.expected_sum = 9'(item.a) + 9'(item.b);

                // Send to mailbox and increment count
                gen_to_drv.put(item);
                generated_count++;
            end else begin
                $fatal(1,"Randomization for add_transaction failed!");
            end
        end
    endtask

    task automatic driver();
        // Wait for reset_done. For each item, get from gen_to_drv,
        // drive at a negedge, assert in_valid for one cycle, and place an
        // independent copy into exp_to_sb. Deassert in_valid when finished.
        wait (reset_done.triggered) begin
            repeat(NUM_ITEMS) begin
                add_transaction item;
                gen_to_drv.get(item); // Blocks if mailbox is empty

                @(negedge clk);
                bus.a = item.a;
                bus.b = item.b;
                bus.in_valid = 1'b1;
                driven_count++;
                exp_to_sb.put(item.copy());

                @(negedge clk);
                bus.in_valid = 1'b0;
            end
        end
    endtask

    task automatic monitor();
        // Passively sample after rising-edge DUT updates. For every
        // out_valid result, create a fresh observation containing actual_sum
        // and place it into mon_to_sb. Do not read gen_to_drv or exp_to_sb.
        forever begin
            @(negedge clk); // Wait for DUT to settle
            if(bus.out_valid) begin
                add_transaction item = new();
                item.actual_sum = bus.sum;
                mon_to_sb.put(item);
                observed_count++;
            end
        end
    endtask

    task automatic scoreboard();
        // Receive one expected and one observed transaction per check.
        // Compare sums, count/report mismatches, and trigger checking_done only
        // after NUM_ITEMS comparisons.
        repeat(NUM_ITEMS) begin
            add_transaction expected;
            add_transaction actual;
            exp_to_sb.get(expected);
            mon_to_sb.get(actual);
            if(expected.expected_sum !== actual.actual_sum) begin
                $display("==============================================");
                $display("Error, actual sum does not match expected sum! ID: ", expected.id);
                $display("Expected sum: %d, Actual sum: %d", expected.expected_sum, actual.actual_sum);
                error_count++;
            end
            checked_count++;
        end
        -> checking_done;
    endtask

    initial begin
        fork
            apply_reset();
            generator();
            driver();
            monitor();
            scoreboard();
        join_none

        // Wait for checking_done, then verify all four counters equal
        // NUM_ITEMS before reporting the final result.
        fork
            // Fork 1: normal process
            begin
                @(checking_done) begin
                    if(generated_count != NUM_ITEMS) begin
                        error_count++;
                        $display("Testbench generated %d items, not %d items!", generated_count, NUM_ITEMS);
                    end
                    if(driven_count != NUM_ITEMS) begin
                        error_count++;
                        $display("Testbench drove %d items, not %d items!", driven_count, NUM_ITEMS);
                    end
                    if(observed_count != NUM_ITEMS) begin
                        error_count++;
                        $display("Testbench observed %d items, not %d items!", observed_count, NUM_ITEMS);
                    end
                    if(checked_count != NUM_ITEMS) begin
                        error_count++;
                        $display("Testbench checked %d items, not %d items!", checked_count, NUM_ITEMS);
                    end
                end
                if(error_count == 0)
                    $display("TEST_RESULT: PASS");
                else
                    $display("TEST_RESULT: FAIL");
            end
            // Fork 2: deadlock check
            begin
                #1us;
                $error("Timeout: concurrent checking did not complete");
                $display("TEST_RESULT: FAIL generated=%0d driven=%0d observed=%0d checked=%0d errors=%0d",
                    generated_count, driven_count, observed_count, checked_count, error_count);
                $fatal(1, "FV-06 concurrency lab incomplete or deadlocked");
            end
        join_any
        $finish();
    end
endmodule
