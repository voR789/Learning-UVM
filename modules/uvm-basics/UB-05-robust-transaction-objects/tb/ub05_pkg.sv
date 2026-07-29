package ub05_pkg;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  class ub05_packet extends uvm_sequence_item;
    rand bit [7:0] address;
    rand bit [15:0] data;
    rand bit write;

    // TODO: Register the object and its meaningful fields for UVM operations.

    constraint legal_c {
      // TODO: Express the legal address range and nonzero write-data rule.
    }

    function new(string name = "ub05_packet");
      // TODO: Initialize the UVM object.
    endfunction

    function string convert2string();
      // TODO: Return a concise representation of all live field values.
    endfunction
  endclass
endpackage
