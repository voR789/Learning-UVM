`timescale 1ns/1ps
module fixture_top;
    import uvm_pkg::*;
    import ua_g1_support_pkg::*;
    import ua_g1_pkg::*;
    import ua_g1_reference_pkg::*;

    logic pclk = 0;
    always #5ns pclk = ~pclk;

    apb_if vif(pclk);
    apb_math_peripheral dut (
        .pclk(pclk),
        .presetn(vif.presetn),
        .psel(vif.psel),
        .penable(vif.penable),
        .pwrite(vif.pwrite),
        .paddr(vif.paddr),
        .pwdata(vif.pwdata),
        .prdata(vif.prdata),
        .pready(vif.pready),
        .pslverr(vif.pslverr)
    );

    initial begin
        vif.presetn = 1'b0;
        vif.psel = 1'b0;
        vif.penable = 1'b0;
        vif.pwrite = 1'b0;
        vif.paddr = '0;
        vif.pwdata = '0;
        repeat (3) @(posedge pclk);
        vif.presetn = 1'b1;
    end

    initial begin
        uvm_config_db #(virtual apb_if)::set(null, "*", "vif", vif);
        run_test();
    end

    initial begin
        #50us;
        $fatal(1, "UA-G1 fixture timeout");
    end
endmodule
