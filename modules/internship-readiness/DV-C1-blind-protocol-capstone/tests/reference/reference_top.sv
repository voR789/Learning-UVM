module reference_top;
  logic clk = 0;
  always #5 clk = ~clk;
  tcs_if bus(clk);
  tcs_peripheral dut(bus);
  integer errors = 0;

  task automatic command(input [3:0] tag, input [1:0] op,
                         input [7:0] a, input [7:0] b);
    begin
      @(negedge clk);
      bus.cmd_tag = tag; bus.cmd_op = op; bus.cmd_a = a; bus.cmd_b = b;
      bus.cmd_valid = 1;
      do @(posedge clk); while (!bus.cmd_ready);
      @(negedge clk);
      bus.cmd_valid = 0;
    end
  endtask

  task automatic response(input [3:0] tag, input [1:0] status,
                          input [7:0] data, input integer stall);
    integer n;
    begin
      bus.rsp_ready = 0;
      while (!bus.rsp_valid) @(negedge clk);
      for (n = 0; n < stall; n = n + 1) begin
        if (!bus.rsp_valid || bus.rsp_tag !== tag ||
            bus.rsp_status !== status || bus.rsp_data !== data) begin
          $display("DVC1_REF_STABILITY: tag=%0d", tag);
          errors = errors + 1;
        end
        @(posedge clk);
        @(negedge clk);
      end
      if (!bus.rsp_valid || bus.rsp_tag !== tag ||
          bus.rsp_status !== status || bus.rsp_data !== data) begin
        $display("DVC1_REF_MISMATCH: expected tag=%0d status=%0d data=0x%02h observed tag=%0d status=%0d data=0x%02h",
                 tag, status, data, bus.rsp_tag, bus.rsp_status, bus.rsp_data);
        errors = errors + 1;
      end
      bus.rsp_ready = 1;
      @(posedge clk);
      @(negedge clk);
      bus.rsp_ready = 0;
    end
  endtask

  initial begin
    bus.rst_n = 0; bus.cmd_valid = 0; bus.rsp_ready = 0;
    repeat (3) @(posedge clk);
    @(negedge clk);
    bus.rst_n = 1;
    command(1, 0, 8'hfe, 8'h05);
    command(2, 1, 8'h5a, 8'ha5);
    response(1, 0, 8'h03, 2);
    response(2, 0, 8'hff, 0);
    command(3, 2, 8'h80, 8'h90);
    command(4, 2, 8'h10, 8'h20);
    command(5, 3, 8'haa, 8'h55);
    response(3, 1, 8'hff, 0);
    response(4, 0, 8'h30, 0);
    response(5, 2, 8'h00, 0);
    command(6, 2, 8'hf0, 8'hf0);
    bus.rst_n = 0;
    @(posedge clk);
    @(negedge clk);
    bus.rst_n = 1;
    repeat (5) @(posedge clk);
    if (bus.rsp_valid) begin
      $display("DVC1_REF_RESET: pre-reset response survived");
      errors = errors + 1;
    end
    command(7, 0, 8'h01, 8'h02);
    response(7, 0, 8'h03, 0);
    if (errors == 0) begin
      $display("DVC1_REFERENCE: checked=6");
      $display("TEST_RESULT: PASS");
      $finish;
    end
    $display("DVC1_REFERENCE: errors=%0d", errors);
    $fatal(1, "reference contract failed");
  end
endmodule
