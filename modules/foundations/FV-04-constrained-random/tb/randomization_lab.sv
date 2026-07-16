class alu_random_item;
    // Declare a, b, and op as random fields with their ALU widths.
    rand logic[7:0] a;
    rand logic[7:0] b;
    rand logic [2:0] op;
    // Add a reusable constraint that permits only defined operations.
    constraint valid_op {
        op < 3'b101;
    }
    function string sprint(); // String print
        // Return a formatted string containing a, b, and op.
        return $sformatf("A value: %d, B value: %d, OP: %b", a, b, op);
    endfunction
endclass

module randomization_lab ();
    localparam int unsigned NUM_ITEMS = 20;

    int unsigned    checks_run  = 0;
    int unsigned    error_count = 0;
    alu_random_item item           ;

    initial begin
        item = new();

        repeat (NUM_ITEMS) begin
            // Randomize item, check the return status, validate that op
            // is legal, print the item, and count the check.
            if(item.randomize()) begin
                if(item.op == 3'b101 || item.op == 3'b110 || item.op == 3'b111 ) begin
                    error_count++;
                    $display("===================================");
                    $display("Test 1 Error: OP has invalid value!");
                    $display("===================================");
                end else begin
                    $display("Valid transaction: %s", item.sprint());
                end
            end else begin
                $display("=======================================");
                $display("Test 1 Error: item failed to randomize!");
                $display("=======================================");
                error_count++;
            end
            checks_run++;
        end


        // Add one successful inline-constrained ADD-overflow experiment.
        if(item.randomize() with { ({1'b0, a} + {1'b0, b}) > 9'd255 && op == 3'b000; }) begin
            $display("Overflow ADD Experiment Successful!: %s", item.sprint());
        end else begin
            $display("Randomization with Overflow ADD failed!");
            error_count++;
        end
        checks_run++;
        // Add one contradictory inline-constraint experiment. Passing
        // this experiment means randomize() reports failure as predicted.
        if(item.randomize() with { ({1'b0, a} + {1'b0, b}) > 9'd255 && a < 9 && b < 23; }) begin
            $display("Intentional failure passed: %s", item.sprint());
            error_count++;
        end else begin
            $display("Intentional failure went as expected.");
        end
        checks_run++;

        if (checks_run == 0) begin
            $error("No randomization checks executed");
            error_count++;
        end

        if (error_count == 0) begin
            $display("TEST_RESULT: PASS");
            $finish;
        end

        $display("TEST_RESULT: FAIL checks=%0d errors=%0d", checks_run, error_count);
        $fatal(1, "FV-04 constrained-random lab failed");
    end
endmodule
