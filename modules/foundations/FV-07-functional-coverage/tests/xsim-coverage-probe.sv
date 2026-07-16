module xsim_coverage_probe;
    logic [1:0] value;
    real pct;

    covergroup probe_cg;
        cp_value: coverpoint value {
            bins zero = {2'd0};
            bins one  = {2'd1};
        }
    endgroup

    probe_cg cg;

    initial begin
        cg = new();
        value = 2'd0;
        cg.sample();
        value = 2'd1;
        cg.sample();
        pct = cg.get_inst_coverage();

        if (pct < 100.0)
            $fatal(1, "Coverage API probe failed: %0.2f%%", pct);

        $display("COVERAGE_PROBE: PASS percent=%0.2f", pct);
        $display("TEST_RESULT: PASS");
        $finish;
    end
endmodule
