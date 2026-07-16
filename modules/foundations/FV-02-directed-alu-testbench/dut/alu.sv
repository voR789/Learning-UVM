module alu (
    input  logic [7:0] a,
    input  logic [7:0] b,
    input  logic [2:0] op,
    output logic [7:0] result,
    output logic       carry,
    output logic       zero,
    output logic       invalid
);
    logic [8:0] arithmetic_result;

    always_comb begin
        result            = 8'h00;
        carry             = 1'b0;
        invalid           = 1'b0;
        arithmetic_result = 9'h000;

        case (op)
            3'b000: begin
                arithmetic_result = {1'b0, a} + {1'b0, b};
                result            = arithmetic_result[7:0];
                carry             = arithmetic_result[8];
            end
            3'b001: begin
                result = a - b;
                carry  = (a >= b);
            end
            3'b010: result = a & b;
            3'b011: result = a | b;
            3'b100: result = a ^ b;
            default: invalid = 1'b1;
        endcase

        zero = (result == 8'h00);
    end
endmodule
