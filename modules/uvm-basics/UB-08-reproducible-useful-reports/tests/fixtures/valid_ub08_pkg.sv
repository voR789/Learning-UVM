package ub08_pkg;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  class ub08_observation extends uvm_sequence_item;
    int unsigned id;
    bit [7:0] expected;
    bit [7:0] observed;
    `uvm_object_utils_begin(ub08_observation)
      `uvm_field_int(id, UVM_DEFAULT)
      `uvm_field_int(expected, UVM_DEFAULT)
      `uvm_field_int(observed, UVM_DEFAULT)
    `uvm_object_utils_end
    function new(string name = "ub08_observation");
      super.new(name);
    endfunction
    function string convert2string();
      return $sformatf("id=%0d expected=0x%02h observed=0x%02h",
                       id, expected, observed);
    endfunction
  endclass

  class ub08_audit extends uvm_subscriber #(ub08_observation);
    `uvm_component_utils(ub08_audit)
    int unsigned checked;
    int unsigned mismatches;
    int unsigned run_seed;
    string first_failure;
    function new(string name, uvm_component parent);
      super.new(name, parent);
    endfunction
    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      if (!$value$plusargs("UB08_SEED=%d", run_seed))
        `uvm_fatal("UB08_SEED", "runner did not provide UB08_SEED")
    endfunction
    function void write(ub08_observation t);
      checked++;
      if (t.observed != t.expected) begin
        mismatches++;
        if (first_failure.len() == 0)
          first_failure = t.convert2string();
        `uvm_error("UB08_MISMATCH",
                   $sformatf("seed=%0d %s", run_seed,
                             t.convert2string()))
      end
    endfunction
    function void report_phase(uvm_phase phase);
      string first_text;
      super.report_phase(phase);
      if (first_failure.len() == 0)
        first_text = "none";
      else
        first_text = first_failure;
      `uvm_info("UB08_SUMMARY",
                $sformatf("seed=%0d checked=%0d mismatches=%0d first=%s",
                          run_seed, checked, mismatches,
                          first_text), UVM_NONE)
    endfunction
  endclass
endpackage
