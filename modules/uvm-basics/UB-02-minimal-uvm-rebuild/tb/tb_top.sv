`timescale 1ns/1ps
module tb_top;
  import uvm_pkg::*;
  import ub02_pkg::*;

  initial run_test();

  initial begin
    #1us;
    $fatal(1, "UB-02 timeout");
  end
endmodule
