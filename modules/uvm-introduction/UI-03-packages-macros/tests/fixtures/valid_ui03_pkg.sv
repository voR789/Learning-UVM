package ui03_pkg;
    import uvm_pkg::*;
    `include "uvm_macros.svh"
    class ui03_packet extends uvm_object;
        `uvm_object_utils(ui03_packet)
        int value;
        function new(string name = "ui03_packet"); super.new(name); endfunction
    endclass
endpackage
