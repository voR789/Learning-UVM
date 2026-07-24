package ui09_pkg;
 import uvm_pkg::*;`include "uvm_macros.svh"
 class ui09_reporter extends uvm_component;`uvm_component_utils(ui09_reporter)function new(string n,uvm_component p);super.new(n,p);endfunction task run_phase(uvm_phase phase);`uvm_error("UI09_MISMATCH","deliberate mismatch before false pass marker")endtask endclass
 class ui09_test extends uvm_test;`uvm_component_utils(ui09_test)ui09_reporter reporter;function new(string n,uvm_component p);super.new(n,p);endfunction function void build_phase(uvm_phase phase);super.build_phase(phase);reporter=ui09_reporter::type_id::create("reporter",this);endfunction task run_phase(uvm_phase phase);phase.raise_objection(this);#1ns;$display("TEST_RESULT: PASS");phase.drop_objection(this);endtask endclass
endpackage
