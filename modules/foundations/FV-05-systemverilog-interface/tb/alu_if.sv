interface alu_if;
    logic [7:0] a      ;
    logic [7:0] b      ;
    logic [2:0] op     ;
    logic [7:0] result ;
    logic       carry  ;
    logic       zero   ;
    logic       invalid;

    // Declare dut_mp from the DUT's perspective.
    modport dut_mp(
        input a, b, op,
        output result, carry, zero, invalid
    );
    // Declare tb_mp from the testbench's perspective.
    modport tb_mp(
        input result, carry, zero, invalid, // Reads these values
        output a, b, op // Drives these values
    );
endinterface
