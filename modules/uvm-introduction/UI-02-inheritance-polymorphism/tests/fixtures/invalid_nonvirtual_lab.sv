`timescale 1ns/1ps
module policy_lab;
    class check_policy;
        function bit accept(int expected, int actual);
            return expected == actual;
        endfunction
    endclass
    class tolerance_policy extends check_policy;
        function bit accept(int expected, int actual);
            int difference;
            difference = actual - expected;
            if (difference < 0) difference = -difference;
            return difference <= 1;
        endfunction
    endclass
    initial begin
        check_policy selected;
        tolerance_policy tolerant = new();
        selected = tolerant;
        if (selected.accept(10, 11) !== 1'b1) begin
            $display("TEST_RESULT: FAIL nonvirtual_base_dispatch");
            $fatal(1, "Base method was non-virtual, so the tolerance override did not dispatch");
        end
        $display("TEST_RESULT: PASS");
        $finish;
    end
endmodule
