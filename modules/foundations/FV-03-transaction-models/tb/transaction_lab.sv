typedef struct packed {
    logic [7:0] a;
    logic [7:0] b;
    logic [2:0] op;
} alu_stimulus_t;

class alu_transaction;
    string         name;
    alu_stimulus_t stimulus;
    logic [7:0]    expected_result;
    logic          expected_carry;
    logic          expected_zero;
    logic          expected_invalid;

    function new(string name = "unnamed");
        this.name = name;
    endfunction

    function void copy_from(input alu_transaction rhs);
        // Copy every transaction field from rhs into this object.
        name = rhs.name;
        stimulus = rhs.stimulus;
        expected_result = rhs.expected_result;
        expected_carry = rhs.expected_carry;
        expected_zero = rhs.expected_zero;
        expected_invalid = rhs.expected_invalid;
    endfunction

    function bit compare(input alu_transaction rhs);
        // Return one only when every verification-relevant field matches.
        if(stimulus !== rhs.stimulus) 
          return 1'b0;
        if(expected_result !== rhs.expected_result) 
          return 1'b0;
        if(expected_carry !== rhs.expected_carry) 
          return 1'b0;
        if(expected_zero !== rhs.expected_zero) 
          return 1'b0;
        if(expected_invalid !== rhs.expected_invalid) 
          return 1'b0;
        return 1'b1;
    endfunction

    function string sprint();
        // Return one useful diagnostic string containing all fields.
        return $sformatf(
        "Name: %s, Input Stimulus [a=%0d, b=%0d, op=%0b], Expected [result=%0d, carry=%0b, zero=%0b, invalid=%0b]",
        name,
        stimulus.a,
        stimulus.b,
        stimulus.op,
        expected_result,
        expected_carry,
        expected_zero,
        expected_invalid
        );
    endfunction
endclass

module transaction_lab;
    int unsigned checks_run = 0;
    int unsigned error_count = 0;

    alu_transaction original;
    alu_transaction alias_handle;
    alu_transaction independent_copy;

    initial begin
        original = new("original");
        original.stimulus.a       = 8'd23;
        original.stimulus.b       = 8'd174;
        original.stimulus.op      = 3'b000;
        original.expected_result  = 8'd197;
        original.expected_carry   = 1'b0;
        original.expected_zero    = 1'b0;
        original.expected_invalid = 1'b0;

        // Make alias_handle refer to the same object as original.
        // Change one field through alias_handle and check what original sees.
        $display("=========================");
        $display("Starting alias experiment");
        alias_handle = original;
        alias_handle.expected_result = 8'd132; 
        $display("original: %s", original.sprint());
        $display("copy:     %s", alias_handle.sprint());
        $display("=========================");
        if(original.expected_result !== 8'd132) begin
            $display("Error: original does not change with alias!");
            error_count++;
        end
        // Aliases act as one to one handles for objects!
        alias_handle.expected_result = 8'd197; // Revert changes
        checks_run++;

        independent_copy = new("independent_copy");
        independent_copy.copy_from(original);
        
        // Prove independent_copy compares equal, then change one copied
        // field and prove compare detects the mismatch without changing original.
        $display("=========================");
        $display("Starting copy vs original test");
        $display("original: %s", original.sprint());
        $display("copy:     %s", independent_copy.sprint());
        if(original.compare(independent_copy) == 1'b1) begin
            $display("Independent copy is the same as original before change!");
        end else begin
            $display("Independent copy is NOT the same as original before change!");
            error_count++;
        end
        independent_copy.expected_carry = 1'b1;
        if(original.expected_carry == 1'b1) begin
            $display("Error: original changes with copy!");
            error_count++;
        end
        $display("After change to copy: ");
        $display("original: %s", original.sprint());
        $display("copy:     %s", independent_copy.sprint());
        if(original.compare(independent_copy) == 1'b1) begin
            $display("Independent copy is the same as original after change!");
            error_count++;
        end else begin
            $display("Independent copy is NOT the same as original after change!");
        end
        $display("=========================");
        checks_run++;
        if (checks_run == 0) begin
            $error("No transaction checks executed");
            error_count++;
        end

        if (error_count == 0) begin
            $display("TEST_RESULT: PASS");
            $finish;
        end

        $display("TEST_RESULT: FAIL checks=%0d errors=%0d", checks_run, error_count);
        $fatal(1, "FV-03 transaction lab failed");
    end
endmodule
