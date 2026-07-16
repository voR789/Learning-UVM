module alu_tb ();
    logic [7:0] a      ;
    logic [7:0] b      ;
    logic [2:0] op     ;
    logic [7:0] result ;
    logic       carry  ;
    logic       zero   ;
    logic       invalid;

    int unsigned checks_run  = 0;
    int unsigned error_count = 0;

    alu dut (.*);

    task automatic check_case(
            input string      test_id,
            input logic [7:0] stimulus_a,
            input logic [7:0] stimulus_b,
            input logic [2:0] stimulus_op,
            input logic [7:0] expected_result,
            input logic       expected_carry,
            input logic       expected_zero,
            input logic       expected_invalid
        );
        checks_run++;
        a = stimulus_a;
        b = stimulus_b;
        op = stimulus_op;

        #1ns; // Allow combinational logic to propagate.

        if(result !== expected_result || carry !== expected_carry || zero !== expected_zero || invalid !== expected_invalid) begin
            $display("Test case error!: %s", test_id);
            $display("Actual values do not match expected values!");
            $display("===========================================");
            if(result !== expected_result) begin
                $display("Expected result: %b", expected_result);
                $display("Actual Result: %b", result);
            end
            if(carry !== expected_carry) begin
                $display("Expected carry: %b", expected_carry);
                $display("Actual carry: %b", carry);
            end
            if(zero !== expected_zero) begin
                $display("Expected zero: %b", expected_zero);
                $display("Actual zero: %b", zero);
            end
            if(invalid !== expected_invalid) begin
                $display("Expected invalid: %b", expected_invalid);
                $display("Actual invalid: %b", invalid);
            end
            error_count++;
        end
    endtask

    initial begin
        check_case("TC-ADD-01", 8'd23, 8'd174, 3'b000, 8'd197, 1'b0, 1'b0, 1'b1);
        check_case("TC-ADD-02", 8'd198, 8'd235, 3'b000, 8'd177, 1'b1, 1'b0, 1'b0);
        check_case("TC-ADD-03", 8'd198, 8'd58, 3'b000, 8'd0, 1'b1, 1'b1, 1'b0);
        check_case("TC-SUB-01", 8'd12, 8'd4, 3'b001, 8'd8, 1'b1, 1'b0, 1'b0);
        check_case("TC-SUB-02", 8'd124, 8'd132, 3'b001, 8'd248, 1'b0, 1'b0, 1'b0);
        check_case("TC-AND-01", 8'b10110011, 8'b11110000, 3'b010, 8'b10110000, 1'b0, 1'b0, 1'b0);
        check_case("TC-OR-01", 8'b10100110, 8'b00110110, 3'b011, 8'b10110110, 1'b0, 1'b0, 1'b0);
        check_case("TC-XOR-01", 8'b11011111, 8'b00110010, 3'b100, 8'b11101101, 1'b0, 1'b0, 1'b0);
        check_case("TC-INVALID-01", 8'b11011111, 8'b00110010, 3'b101, 8'd0, 1'b0, 1'b1, 1'b1);
        check_case("TC-INVALID-02", 8'b11011111, 8'b00110010, 3'b110, 8'd0, 1'b0, 1'b1, 1'b1);
        check_case("TC-INVALID-03", 8'b11011111, 8'b00110010, 3'b111, 8'd0, 1'b0, 1'b1, 1'b1);
        check_case("TC-ZERO-01", 8'd0, 8'd0, 3'b000, 8'd0, 1'b0, 1'b1, 1'b0);
        check_case("TC-ZERO-02", 8'd21, 8'd21, 3'b001, 8'd0, 1'b1, 1'b1, 1'b0);
        check_case("TC-ZERO-03", 8'b00001111, 8'b11110000, 3'b010, 8'd0, 1'b0, 1'b1, 1'b0);
        check_case("TC-ZERO-04", 8'b00000000, 8'b00000000, 3'b011, 8'd0, 1'b0, 1'b1, 1'b0);
        check_case("TC-ZERO-05", 8'b00001111, 8'b00001111, 3'b100, 8'd0, 1'b0, 1'b1, 1'b0);
        if (checks_run == 0) begin
            $error("No directed checks executed; complete the TODOs in check_case and initial");
            error_count++;
        end

        if (error_count == 0) begin
            $display("TEST_RESULT: PASS");
            $finish;
        end

        $display("TEST_RESULT: FAIL checks=%0d errors=%0d", checks_run, error_count);
        $fatal(1, "FV-02 directed checks failed");
    end
endmodule
