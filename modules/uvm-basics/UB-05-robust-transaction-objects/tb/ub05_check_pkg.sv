package ub05_check_pkg;
  import uvm_pkg::*;
  import ub05_pkg::*;
  `include "uvm_macros.svh"

  class ub05_test extends uvm_test;
    `uvm_component_utils(ub05_test)

    function new(string name, uvm_component parent);
      super.new(name, parent);
    endfunction

    task run_phase(uvm_phase phase);
      ub05_packet original;
      ub05_packet copied;
      bit [15:0] original_data;
      string rendered;

      phase.raise_objection(this);
      original = ub05_packet::type_id::create("original");
      copied = ub05_packet::type_id::create("copied");

      if (!original.randomize())
        `uvm_fatal("UB05_RANDOMIZE", "packet randomization failed")

      if (original.address < 8'h10 || original.address > 8'h1f)
        `uvm_fatal("UB05_CONSTRAINT", "address is outside the legal range")
      if (original.write && original.data == 16'h0000)
        `uvm_fatal("UB05_CONSTRAINT", "write transaction has zero data")

      copied.copy(original);
      if (!copied.compare(original))
        `uvm_fatal("UB05_COPY", "copied packet does not match the original")

      rendered = original.convert2string();
      if (rendered.len() == 0)
        `uvm_fatal("UB05_STRING", "convert2string returned an empty string")

      original_data = copied.data;
      copied.data = original_data ^ 16'h0001;
      if (copied.compare(original))
        `uvm_fatal("UB05_COMPARE",
                   "comparison ignored a meaningful data mutation")

      $display("PACKET_TRACE: %s", rendered);
      $display("TEST_RESULT: PASS");
      phase.drop_objection(this);
    endtask
  endclass
endpackage
