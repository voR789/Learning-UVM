package ub05_pkg;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  class ub05_packet extends uvm_sequence_item;
    rand bit [7:0] address;
    rand bit [15:0] data;
    rand bit write;

    `uvm_object_utils_begin(ub05_packet)
      `uvm_field_int(address, UVM_DEFAULT)
      `uvm_field_int(data, UVM_DEFAULT)
      `uvm_field_int(write, UVM_DEFAULT)
    `uvm_object_utils_end

    constraint legal_c {
      address inside {[8'h10:8'h1f]};
      write -> data != 16'h0000;
    }

    function new(string name = "ub05_packet");
      super.new(name);
    endfunction

    function string convert2string();
      return $sformatf("address=0x%02h data=0x%04h write=%0b",
                       address, data, write);
    endfunction
  endclass
endpackage
