`timescale 1ns/1ps

module tb_top;
    import uvm_pkg::*;
    import ui01_pkg::*;

    initial begin
        run_test();
    end

    initial begin
        #1us;
        $fatal(1, "UI-01 timeout: UVM hierarchy example did not finish");
    end
endmodule
