interface fifo_if(input logic clk);
    logic rst;
    logic wr_en;
    logic rd_en;
    logic [7:0] wdata;
    logic [7:0] rdata;
    logic full;
    logic empty;
    logic [2:0] count;
    logic sample_valid;
endinterface
