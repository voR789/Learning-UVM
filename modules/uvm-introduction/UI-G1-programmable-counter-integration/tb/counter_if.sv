interface counter_if(input logic clk);
    logic       rst_n;
    logic       cmd_valid;
    logic [1:0] cmd;
    logic [7:0] load_value;
    logic [7:0] count;
endinterface
