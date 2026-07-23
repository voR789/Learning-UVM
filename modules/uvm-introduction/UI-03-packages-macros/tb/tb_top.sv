`timescale 1ns/1ps

module tb_top;
    import uvm_pkg::*;
    import ui03_pkg::*;

    initial begin : construct_registered_object
        ui03_packet packet;

        packet = ui03_packet::type_id::create("packet");
        if (packet == null) begin
            $display("TEST_RESULT: FAIL null_packet");
            $fatal(1, "Registered construction returned null");
        end

        packet.value = 42;
        if ((packet.get_name() != "packet") || (packet.value != 42)) begin
            $display("TEST_RESULT: FAIL name_or_value");
            $fatal(1, "Constructed packet did not retain required state");
        end

        $display("PACKAGE_TRACE: type=%s name=%s value=%0d",
                 packet.get_type_name(), packet.get_name(), packet.value);
        $display("TEST_RESULT: PASS");
        $finish;
    end

    initial begin
        #1us;
        $fatal(1, "UI-03 timeout");
    end
endmodule
