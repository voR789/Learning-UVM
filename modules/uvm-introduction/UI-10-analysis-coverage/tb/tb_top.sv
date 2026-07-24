`timescale 1ns/1ps
module tb_top;
    import uvm_pkg::*;
    import ui10_pkg::*;
    initial run_test();
    initial begin
        #1us;
        $fatal(1, "UI-10 timeout");
    end
endmodule
