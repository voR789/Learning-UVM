`timescale 1ns/1ps
module tb_top;
    import uvm_pkg::*;
    import ui_g1_pkg::*;
    logic clk = 0;
    always #5ns clk = ~clk;
    counter_if vif(clk);
    programmable_counter dut(
        .clk(clk), .rst_n(vif.rst_n), .cmd_valid(vif.cmd_valid),
        .cmd(vif.cmd), .load_value(vif.load_value), .count(vif.count)
    );
    initial begin
        uvm_config_db #(virtual counter_if)::set(null,"*","vif",vif);
        run_test();
    end
    initial begin #10us; $fatal(1,"UI-G1 timeout"); end
endmodule
