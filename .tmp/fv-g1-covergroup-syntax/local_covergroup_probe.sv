module local_covergroup_probe;
    covergroup local_cg with function sample(logic value);
        value_cp: coverpoint value;
    endgroup

    task predictor();
        local_cg coverage;

        coverage = new();
        coverage.sample(1'b0);
        coverage.sample(1'b1);
    endtask

    initial predictor();
endmodule
