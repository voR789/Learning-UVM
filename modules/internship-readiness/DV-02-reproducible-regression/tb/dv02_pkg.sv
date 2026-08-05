package dv02_pkg;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  class dv02_base_test extends uvm_test;
    `uvm_component_utils(dv02_base_test)
    int unsigned checked;
    int unsigned failures;

    function new(string name, uvm_component parent);
      super.new(name, parent);
    endfunction

    function automatic int unsigned implementation_result(
      input int unsigned operation,
      input int unsigned a,
      input int unsigned b
    );
      if (operation == 1)
        return a | b;
      return (a + b) & 'hff;
    endfunction

    function automatic int unsigned reference_result(
      input int unsigned operation,
      input int unsigned a,
      input int unsigned b
    );
      if (operation == 1)
        return a ^ b;
      return (a + b) & 'hff;
    endfunction

    task check_operation(int unsigned index, operation, a, b);
      int unsigned expected;
      int unsigned observed;
      expected = reference_result(operation, a, b);
      observed = implementation_result(operation, a, b);
      checked++;
      if (observed != expected) begin
        failures++;
        `uvm_error("DV02_DATA",
          $sformatf("index=%0d op=%0d a=0x%02x b=0x%02x expected=0x%02x observed=0x%02x",
                    index, operation, a, b, expected, observed))
      end
    endtask

    task finish_test(uvm_phase phase);
      if (failures == 0) begin
        `uvm_info("DV02_PASS", $sformatf("checked=%0d failures=0", checked), UVM_NONE)
        $display("TEST_RESULT: PASS");
      end else begin
        `uvm_error("DV02_RESULT",
          $sformatf("checked=%0d failures=%0d", checked, failures))
      end
      phase.drop_objection(this);
    endtask
  endclass

  class dv02_smoke_test extends dv02_base_test;
    `uvm_component_utils(dv02_smoke_test)
    function new(string name, uvm_component parent); super.new(name, parent); endfunction
    task run_phase(uvm_phase phase);
      phase.raise_objection(this);
      check_operation(0, 0, 8'h02, 8'h03);
      check_operation(1, 0, 8'h10, 8'h20);
      finish_test(phase);
    endtask
  endclass

  class dv02_arithmetic_test extends dv02_base_test;
    `uvm_component_utils(dv02_arithmetic_test)
    function new(string name, uvm_component parent); super.new(name, parent); endfunction
    task run_phase(uvm_phase phase);
      int unsigned a;
      int unsigned b;
      phase.raise_objection(this);
      for (int unsigned index = 0; index < 8; index++) begin
        a = $urandom_range(0, 255);
        b = $urandom_range(0, 255);
        check_operation(index, 1, a, b);
      end
      finish_test(phase);
    endtask
  endclass

  class dv02_completion_test extends dv02_base_test;
    `uvm_component_utils(dv02_completion_test)
    function new(string name, uvm_component parent); super.new(name, parent); endfunction
    task run_phase(uvm_phase phase);
      int unsigned payload;
      int unsigned issued;
      int unsigned completed;
      phase.raise_objection(this);
      for (int unsigned index = 0; index < 8; index++) begin
        payload = $urandom_range(0, 255);
        issued++;
        if (payload[1:0] != 2'b11)
          completed++;
        `uvm_info("DV02_COMPLETION",
          $sformatf("index=%0d payload=0x%02x issued=%0d completed=%0d",
                    index, payload, issued, completed), UVM_LOW)
      end
      checked = issued;
      if (completed != issued) begin
        failures = issued - completed;
        `uvm_error("DV02_MISSING",
          $sformatf("issued=%0d completed=%0d missing=%0d",
                    issued, completed, issued-completed))
      end
      finish_test(phase);
    endtask
  endclass
endpackage
