`timescale 1ns/1ps
module tb_top;
    import uvm_pkg::*;
    import ui05_pkg::*;
    initial run_test();
    initial begin #1us; $fatal(1, "UI-05 timeout"); end
endmodule
