package dv03_target_pkg;
  import uvm_pkg::*;
  import dv03_support_pkg::*;
  `include "uvm_macros.svh"

  class dv03_target_sequence extends dv03_sequence_base;
    `uvm_object_utils(dv03_target_sequence)
    function new(string name = "dv03_target_sequence"); super.new(name); endfunction

    task body();
      // Supplied baseline observations.
      emit(0, DV03_SHORT,  0, 0);
      emit(0, DV03_MEDIUM, 1, 0);
      emit(1, DV03_MEDIUM, 0, 0);
      emit(2, DV03_SHORT,  0, 0);

      // TODO: Add only the minimal legal targeted observations needed to
      // close every reachable requirement-level hole.
    endtask
  endclass
endpackage
