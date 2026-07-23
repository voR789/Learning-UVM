`timescale 1ns/1ps
module policy_lab;
    class check_policy;
        virtual function bit accept(int expected, int actual);
            return expected == actual;
        endfunction
        virtual function string policy_name(); return "check_policy"; endfunction
    endclass
    class exact_policy extends check_policy;
        virtual function bit accept(int expected, int actual);
            return expected == actual;
        endfunction
        virtual function string policy_name(); return "exact_policy"; endfunction
    endclass
    class tolerance_policy extends check_policy;
        int tolerance;
        function new(int tolerance = 1); this.tolerance = tolerance; endfunction
        virtual function bit accept(int expected, int actual);
            int difference;
            difference = actual - expected;
            if (difference < 0) difference = -difference;
            return difference <= tolerance;
        endfunction
        virtual function string policy_name(); return "tolerance_policy"; endfunction
    endclass
    int checks = 0;
    int errors = 0;
    task automatic expect_decision(check_policy policy, int expected, int actual, bit wanted);
        bit got;
        got = policy.accept(expected, actual);
        checks++;
        if (got !== wanted) begin errors++; $error("POLICY_MISMATCH policy=%s", policy.policy_name()); end
    endtask
    initial begin
        check_policy selected;
        exact_policy exact = new();
        tolerance_policy tolerant = new(1);
        selected = exact;
        expect_decision(selected, 10, 10, 1'b1);
        expect_decision(selected, 10, 11, 1'b0);
        expect_decision(selected, 10, 13, 1'b0);
        selected = tolerant;
        expect_decision(selected, 10, 10, 1'b1);
        expect_decision(selected, 10, 11, 1'b1);
        expect_decision(selected, 10, 13, 1'b0);
        if ((checks == 6) && (errors == 0)) begin
            $display("POLICY_SUMMARY: checks=%0d errors=%0d", checks, errors);
            $display("TEST_RESULT: PASS");
            $finish;
        end
        $display("TEST_RESULT: FAIL checks=%0d errors=%0d", checks, errors);
        $fatal(1, "UI-02 valid fixture failed");
    end
    initial begin #1us; $fatal(1, "UI-02 timeout"); end
endmodule
