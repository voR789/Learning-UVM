interface sync_if(input logic clk);
    logic       rst_n;
    logic       in_valid;
    logic [7:0] a;
    logic [7:0] b;
    logic       out_valid;
    logic [8:0] sum;

    modport dut_mp (
        input  clk, rst_n, in_valid, a, b,
        output out_valid, sum
    );

    modport drv_mp (
        input  clk, rst_n,
        output in_valid, a, b,
        input  out_valid, sum
    );

    modport mon_mp (
        input clk, rst_n, in_valid, a, b, out_valid, sum
    );
endinterface
