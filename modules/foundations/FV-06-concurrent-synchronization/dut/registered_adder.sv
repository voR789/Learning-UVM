module registered_adder (
    input  logic       clk,
    input  logic       rst_n,
    input  logic       in_valid,
    input  logic [7:0] a,
    input  logic [7:0] b,
    output logic       out_valid,
    output logic [8:0] sum
);
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            out_valid <= 1'b0;
            sum       <= 9'd0;
        end else begin
            out_valid <= in_valid;
            if (in_valid)
                sum <= {1'b0, a} + {1'b0, b};
        end
    end
endmodule
