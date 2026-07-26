module programmable_counter (
    input  logic       clk,
    input  logic       rst_n,
    input  logic       cmd_valid,
    input  logic [1:0] cmd,
    input  logic [7:0] load_value,
    output logic [7:0] count
);
    always_ff @(posedge clk) begin
        if (!rst_n)
            count <= 8'd0;
        else if (cmd_valid) begin
            case (cmd)
                2'd0: count <= load_value;
                2'd1: count <= count + 8'd1;
                2'd2: count <= count - 8'd1;
                2'd3: count <= 8'd0;
            endcase
        end
    end
endmodule
