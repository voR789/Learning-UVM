module sync_fifo #(
    parameter int WIDTH = 8,
    parameter int DEPTH = 4,
    parameter int PTR_W = $clog2(DEPTH),
    parameter int CNT_W = $clog2(DEPTH + 1)
) (
    input logic clk, input logic rst,
    input logic wr_en, input logic rd_en,
    input logic [WIDTH-1:0] wdata,
    output logic [WIDTH-1:0] rdata,
    output logic full, output logic empty,
    output logic [CNT_W-1:0] count
);
    logic [WIDTH-1:0] mem [0:DEPTH-1];
    logic [PTR_W-1:0] wr_ptr, rd_ptr;

    assign empty = (count == 0);
    // Seeded representative fault: capacity is reported one entry too early.
    assign full = (count == DEPTH - 1);

    always_ff @(posedge clk) begin
        if (rst) begin
            wr_ptr <= '0;
            rd_ptr <= '0;
            count <= '0;
            rdata <= '0;
        end else begin
            if (wr_en && !full) begin
                mem[wr_ptr] <= wdata;
                wr_ptr <= wr_ptr + 1'b1;
            end
            if (rd_en && !empty) begin
                rdata <= mem[rd_ptr];
                rd_ptr <= rd_ptr + 1'b1;
            end
            case ({wr_en && !full, rd_en && !empty})
                2'b10: count <= count + 1'b1;
                2'b01: count <= count - 1'b1;
                default: count <= count;
            endcase
        end
    end
endmodule
