module tcs_peripheral (tcs_if.dut bus);
  logic [3:0] tag_q [0:3];
  logic [1:0] status_q [0:3];
  logic [7:0] data_q [0:3];
  integer delay_q [0:3];
  integer count;
  integer i;
  logic [8:0] sum;

  assign bus.cmd_ready = bus.rst_n && (count < 4) &&
                         !(bus.rsp_valid && bus.rsp_ready);
  assign bus.rsp_valid = bus.rst_n && (count > 0) && (delay_q[0] == 0);
  assign bus.rsp_tag = tag_q[0];
  assign bus.rsp_status = status_q[0];
  assign bus.rsp_data = data_q[0];

  always @(posedge bus.clk) begin
    if (!bus.rst_n) begin
      count <= 0;
      for (i = 0; i < 4; i = i + 1) begin
        tag_q[i] <= 0; status_q[i] <= 0; data_q[i] <= 0; delay_q[i] <= 0;
      end
    end else begin
      if ((count > 0) && (delay_q[0] > 0))
        delay_q[0] <= delay_q[0] - 1;
      if (bus.rsp_valid && bus.rsp_ready) begin
        for (i = 0; i < 3; i = i + 1) begin
          tag_q[i] <= tag_q[i+1]; status_q[i] <= status_q[i+1];
          data_q[i] <= data_q[i+1]; delay_q[i] <= delay_q[i+1];
        end
        count <= count - 1;
      end
      if (bus.cmd_valid && bus.cmd_ready) begin
        sum = bus.cmd_a + bus.cmd_b;
        tag_q[count] <= bus.cmd_tag;
        status_q[count] <= 0;
        case (bus.cmd_op)
          2'd0: begin data_q[count] <= sum[7:0]; delay_q[count] <= 0; end
          2'd1: begin data_q[count] <= (bus.cmd_a ^ bus.cmd_b) ^ 8'h01; delay_q[count] <= 1; end
          2'd2: begin
            data_q[count] <= sum[8] ? 8'hff : sum[7:0];
            status_q[count] <= sum[8] ? 2'd1 : 2'd0;
            delay_q[count] <= 2;
          end
          default: begin data_q[count] <= 0; status_q[count] <= 2'd2; delay_q[count] <= 0; end
        endcase
        count <= count + 1;
      end
    end
  end
endmodule
