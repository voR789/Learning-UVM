module coverage_lab;
    logic [7:0] sample_a;
    logic [7:0] sample_b;
    logic [2:0] sample_op;
    logic       sample_result_zero;

    int unsigned sample_count = 0;
    int unsigned error_count  = 0;
    real coverage_pct;

    covergroup alu_cg;
        option.per_instance = 1;

        cp_op : coverpoint sample_op {
            bins add         = {3'b000};
            bins subtract    = {3'b001};
            bins bitwise_and = {3'b010};
            bins bitwise_or  = {3'b011};
            bins bitwise_xor = {3'b100};
            bins invalid_101 = {3'b101};
            bins invalid_110 = {3'b110};
            bins invalid_111 = {3'b111};
        }

        cp_a : coverpoint sample_a {
            bins zero = {8'd0};
            bins middle = {[8'd1 : 8'd254]};
            bins maximum = {8'd255};
        }
        cp_b : coverpoint sample_b {
            bins zero = {8'd0};
            bins middle = {[8'd1 : 8'd254]};
            bins maximum = {8'd255};
        }

        cp_zero: coverpoint sample_result_zero {
            bins true = {1'b1};
            bins false = {1'b0};
        }

        cx_op_zero: cross cp_op, cp_zero {
            ignore_bins invalid_ops = binsof(cp_op.invalid_101) ||
                                       binsof(cp_op.invalid_110) ||
                                       binsof(cp_op.invalid_111);
        }
    endgroup

    alu_cg coverage;

    task automatic sample_transaction(
        input logic [7:0] a,
        input logic [7:0] b,
        input logic [2:0] op,
        input logic       result_zero
    );
        sample_a           = a;
        sample_b           = b;
        sample_op          = op;
        sample_result_zero = result_zero;
        coverage.sample();
        sample_count++;
    endtask

    initial begin
        coverage = new();

        // Starter stimulus intentionally leaves coverage holes.
        sample_transaction(8'd12, 8'd4, 3'b000, 1'b0);
        sample_transaction(8'd21, 8'd21, 3'b001, 1'b1);
        sample_transaction(8'hF0, 8'h0F, 3'b010, 1'b1);
        sample_transaction(8'hA5, 8'h5A, 3'b011, 1'b0);
        sample_transaction(8'hFF, 8'hFF, 3'b100, 1'b1);
        sample_transaction(8'd1, 8'd2, 3'b101, 1'b1);
        sample_transaction(8'd0, 8'd0, 3'b010, 1'b0); // Zero case was uncovered in both coverpoints a and b

        // Close the two missing invalid encodings.
        sample_transaction(8'd3, 8'd4, 3'b110, 1'b0);
        sample_transaction(8'd3, 8'd4, 3'b111, 1'b0);

        // Close the missing defined-operation-by-zero-result combinations.
        sample_transaction(8'd0, 8'd0, 3'b000, 1'b1);
        sample_transaction(8'd3, 8'd4, 3'b001, 1'b0);
        sample_transaction(8'd0, 8'd0, 3'b011, 1'b1);
        sample_transaction(8'd3, 8'd4, 3'b100, 1'b0);

        coverage_pct = coverage.get_inst_coverage();
        $display("==============================================");
        $display("COVERAGE_RESULT: percent=%0.2f samples=%0d", coverage_pct, sample_count);

        if (coverage_pct < 100.0) begin
            $error("Functional coverage is incomplete: %0.2f%%", coverage_pct);
            error_count++;
        end
        $display("==============================================");
        if (error_count == 0) begin
            $display("TEST_RESULT: PASS");
            $finish;
        end

        $display("TEST_RESULT: FAIL coverage=%0.2f errors=%0d", coverage_pct, error_count);
        $fatal(1, "FV-07 coverage closure incomplete");
    end
endmodule
