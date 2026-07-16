module fifo_tb;
    localparam int WIDTH = 8;
    localparam int DEPTH = 4;
    localparam int CNT_W = $clog2(DEPTH + 1);

    logic clk = 1'b0;
    logic rst;
    logic wr_en;
    logic rd_en;
    logic [WIDTH-1:0] wdata;
    logic [WIDTH-1:0] rdata;
    logic full;
    logic empty;
    logic [CNT_W-1:0] count;

    int unsigned check_count = 0;
    int unsigned error_count = 0;

    always #5ns clk = ~clk;

    sync_fifo #(
        .WIDTH(WIDTH),
        .DEPTH(DEPTH)
    ) dut (
        .clk,
        .rst,
        .wr_en,
        .rd_en,
        .wdata,
        .rdata,
        .full,
        .empty,
        .count
    );

    // TODO: Define transaction data that distinguishes requested operations
    // from operations accepted using the pre-edge full/empty status.

    // TODO: Implement separated stimulus/driver, passive observation,
    // prediction, checking, assertions, and functional coverage.

    // TODO: Add deterministic boundary tests before constrained-random traffic.

    initial begin
        rst   = 1'b0;
        wr_en = 1'b0;
        rd_en = 1'b0;
        wdata = '0;

        // Untouched starter: force a clean reset, then leave implementation
        // ownership with the learner.
        @(negedge clk);
        rst = 1'b1;
        repeat (2) @(negedge clk);
        rst = 1'b0;
    end

    initial begin
        #10us;
        $display("TEST_RESULT: FAIL checks=%0d errors=%0d", check_count, error_count);
        $fatal(1, "FV-G1 timeout or learner testbench not yet implemented");
    end
endmodule
