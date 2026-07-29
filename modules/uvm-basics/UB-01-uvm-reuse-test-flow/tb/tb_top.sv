`timescale 1ns/1ps
module tb_top;
  import uvm_pkg::*;
  import ub01_pkg::*;
  initial run_test();
  initial begin
    #1us;
    $fatal(1, "UB-01 timeout");
  end
endmodule
