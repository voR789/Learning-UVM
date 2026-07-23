`timescale 1ns/1ps

module tb_top;
    import uvm_pkg::*;
    import ui04_pkg::*;

    initial begin
        run_test();
    end

    initial begin
        #1us;
        $fatal(1, "UI-04 timeout: UVM hierarchy did not finish");
    end
endmodule
