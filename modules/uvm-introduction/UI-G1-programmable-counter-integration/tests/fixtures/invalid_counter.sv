module programmable_counter (
  input logic clk, rst_n, cmd_valid,
  input logic [1:0] cmd,
  input logic [7:0] load_value,
  output logic [7:0] count
);
  always_ff @(posedge clk) begin
    if (!rst_n) count <= 0;
    else if (cmd_valid)
      case (cmd)
        0: count <= load_value;
        1: count <= count + 1;
        2: count <= count + 1; // Seeded fault: DEC behaves as INC.
        3: count <= 0;
      endcase
  end
endmodule
