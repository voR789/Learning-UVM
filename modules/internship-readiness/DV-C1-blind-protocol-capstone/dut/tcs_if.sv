interface tcs_if(input logic clk);
  logic rst_n;
  logic cmd_valid, cmd_ready;
  logic [3:0] cmd_tag;
  logic [1:0] cmd_op;
  logic [7:0] cmd_a, cmd_b;
  logic rsp_valid, rsp_ready;
  logic [3:0] rsp_tag;
  logic [1:0] rsp_status;
  logic [7:0] rsp_data;

  modport dut(input clk, rst_n, cmd_valid, cmd_tag, cmd_op, cmd_a, cmd_b,
              rsp_ready, output cmd_ready, rsp_valid, rsp_tag, rsp_status,
              rsp_data);
  modport tb(input clk, cmd_ready, rsp_valid, rsp_tag, rsp_status, rsp_data,
             output rst_n, cmd_valid, cmd_tag, cmd_op, cmd_a, cmd_b, rsp_ready);
endinterface
