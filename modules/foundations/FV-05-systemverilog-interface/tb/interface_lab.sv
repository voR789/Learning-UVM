class alu_checker;
    virtual alu_if vif;
    int unsigned checks_run = 0;
    int unsigned error_count = 0;

    function new(virtual alu_if vif);
        this.vif = vif;
    endfunction

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
        // Reject a null vif, drive through vif, wait for settling,
        // compare every output through vif, and count/report mismatches.
        if(vif == null) begin
            error_count++;
            $display("==========================================");
            $display("Error, virtual interface provided is null!"); 
        end else begin
            vif.a = stimulus_a;
            vif.b = stimulus_b;
            vif.op = stimulus_op;

            #1ns;

            if(vif.result !== expected_result) begin
                error_count++;
                $display("Error: result is incorrect!");
                $display("Expected: %d, Actual: %d", expected_result, vif.result);
            end
            if(vif.carry !== expected_carry) begin
                error_count++;
                $display("Error: carry is incorrect!");
                $display("Expected: %d, Actual: %d", expected_carry, vif.carry);
            end
            if(vif.zero !== expected_zero) begin
                error_count++;
                $display("Error: zero is incorrect!");
                $display("Expected: %d, Actual: %d", expected_zero, vif.zero);
            end
            if(vif.invalid !== expected_invalid) begin
                error_count++;
                $display("Error: invalid is incorrect!");
                $display("Expected: %d, Actual: %d", expected_invalid, vif.invalid);
            end 
        end
    endtask
endclass

module interface_lab;
    alu_if bus();
    alu_checker checker_h;

    alu dut (
        .a       (bus.a),
        .b       (bus.b),
        .op      (bus.op),
        .result  (bus.result),
        .carry   (bus.carry),
        .zero    (bus.zero),
        .invalid (bus.invalid)
    );

    initial begin
        // Construct checker with bus and invoke one known case from FV-02.
        checker_h = new(bus.tb_mp);
        checker_h.check_case("TC-SUB-01", 8'd12, 8'd4, 3'b001, 8'd8, 1'b1, 1'b0, 1'b0);

        if (checker_h == null || checker_h.checks_run == 0) begin
            $error("No interface checks executed");
            $display("TEST_RESULT: FAIL");
            $fatal(1, "FV-05 interface lab incomplete");
        end

        if (checker_h.error_count == 0) begin
            $display("TEST_RESULT: PASS");
            $finish;
        end

        $display("TEST_RESULT: FAIL checks=%0d errors=%0d", checker_h.checks_run, checker_h.error_count);
        $fatal(1, "FV-05 interface checks failed");
    end
endmodule
