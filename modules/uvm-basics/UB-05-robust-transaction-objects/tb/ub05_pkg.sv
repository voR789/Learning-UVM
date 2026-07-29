package ub05_pkg;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  class ub05_packet extends uvm_sequence_item;
    rand bit [7:0] address;
    rand bit [15:0] data;
    rand bit write;

    // TODO: Register the object and its meaningful fields for UVM operations.
    `uvm_object_utils_begin(ub05_packet) // Individual registration
        `uvm_field_int(address, UVM_DEFAULT)
        `uvm_field_int(data, UVM_DEFAULT)
        //`uvm_field_int(write, UVM_DEFAULT)
    `uvm_object_utils_end
    constraint legal_c {
      // TODO: Express the legal address range and nonzero write-data rule.
        address inside {[8'h10:8'h1F]};
        if(write) data != 0;
    }

    function new(string name = "ub05_packet");
      // TODO: Initialize the UVM object.
        super.new(name);
    endfunction

    function string convert2string();
      // TODO: Return a concise representation of all live field values.
        return $sformatf("address: %h, data: %h, write: %b", address, data, write);
    endfunction
  endclass
endpackage
