`timescale 1ns/1ps

module tb_top;
    import uvm_pkg::*;
    import smoke_pkg::*;

    logic clk = 1'b0;
    always #5ns clk = ~clk;

    smoke_if smoke_vif(clk);

    smoke_counter dut (
        .clk    (clk),
        .rst_n  (smoke_vif.rst_n),
        .enable (smoke_vif.enable),
        .count  (smoke_vif.count)
    );

    initial begin
        smoke_vif.rst_n  = 1'b0;
        smoke_vif.enable = 1'b0;
        uvm_config_db#(virtual smoke_if)::set(null, "uvm_test_top", "vif", smoke_vif);
        run_test();
    end

    initial begin
        #5us;
        $fatal(1, "FV-00 timeout: test did not finish");
    end
endmodule

