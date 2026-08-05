package dv02_pkg;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  class dv02_base_test extends uvm_test;
    `uvm_component_utils(dv02_base_test)
    int unsigned checked;
    int unsigned failures;
    function new(string name, uvm_component parent); super.new(name, parent); endfunction
    task check_operation(int unsigned index, operation, a, b);
      checked++;
    endtask
    task finish_test(uvm_phase phase);
      `uvm_info("DV02_PASS", $sformatf("checked=%0d failures=0", checked), UVM_NONE)
      $display("TEST_RESULT: PASS");
      phase.drop_objection(this);
    endtask
  endclass

  class dv02_smoke_test extends dv02_base_test;
    `uvm_component_utils(dv02_smoke_test)
    function new(string name, uvm_component parent); super.new(name, parent); endfunction
    task run_phase(uvm_phase phase);
      phase.raise_objection(this); checked = 2; finish_test(phase);
    endtask
  endclass
  class dv02_arithmetic_test extends dv02_base_test;
    `uvm_component_utils(dv02_arithmetic_test)
    function new(string name, uvm_component parent); super.new(name, parent); endfunction
    task run_phase(uvm_phase phase);
      phase.raise_objection(this); checked = 8; finish_test(phase);
    endtask
  endclass
  class dv02_completion_test extends dv02_base_test;
    `uvm_component_utils(dv02_completion_test)
    function new(string name, uvm_component parent); super.new(name, parent); endfunction
    task run_phase(uvm_phase phase);
      phase.raise_objection(this); checked = 8; finish_test(phase);
    endtask
  endclass
endpackage
