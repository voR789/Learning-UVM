module tb_top;
  import uvm_pkg::*;
  import dvc1_tb_pkg::*;
  logic clk = 0;
  always #5 clk = ~clk;
  tcs_if bus(clk);
  tcs_peripheral dut(bus);
  initial begin
    uvm_config_db#(virtual tcs_if)::set(null, "*", "vif", bus);
    run_test();
  end
endmodule
