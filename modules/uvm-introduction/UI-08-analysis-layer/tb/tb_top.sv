`timescale 1ns/1ps
module tb_top;
    import uvm_pkg::*;
    import ui08_pkg::*;
    initial run_test();
    initial begin
        #1us;
        $fatal(1, "UI-08 timeout");
    end
endmodule
