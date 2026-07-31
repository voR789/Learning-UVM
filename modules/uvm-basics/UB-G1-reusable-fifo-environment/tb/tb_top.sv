`timescale 1ns/1ps
module tb_top;
    import uvm_pkg::*;
    import ub_g1_pkg::*;

    logic clk = 0;
    always #5ns clk = ~clk;

    fifo_if vif(clk);
    sync_fifo #(.WIDTH(8), .DEPTH(4)) dut (
        .clk(clk), .rst(vif.rst), .wr_en(vif.wr_en), .rd_en(vif.rd_en),
        .wdata(vif.wdata), .rdata(vif.rdata), .full(vif.full),
        .empty(vif.empty), .count(vif.count)
    );

    initial begin
        vif.rst = 0;
        vif.wr_en = 0;
        vif.rd_en = 0;
        vif.wdata = 0;
        vif.sample_valid = 0;
        uvm_config_db #(virtual fifo_if)::set(null, "*", "vif", vif);
        run_test();
    end

    initial begin
        #20us;
        $fatal(1, "UB-G1 timeout");
    end
endmodule
