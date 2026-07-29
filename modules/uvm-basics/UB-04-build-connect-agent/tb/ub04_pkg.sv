package ub04_pkg;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  class ub04_item extends uvm_sequence_item;
    `uvm_object_utils(ub04_item)
    function new(string name = "ub04_item");
      super.new(name);
    endfunction
  endclass

  class ub04_sequencer extends uvm_sequencer #(ub04_item);
    // TODO: Supply the standard component mechanics.
    `uvm_component_utils(ub04_sequencer)
    function new(string name, uvm_component parent);
      super.new(name, parent);
    endfunction
  endclass

  class ub04_driver extends uvm_driver #(ub04_item);
    // TODO: Supply the standard component mechanics.
    `uvm_component_utils(ub04_driver)
    function new(string name, uvm_component parent);
      super.new(name, parent);
    endfunction
  endclass

  class ub04_monitor extends uvm_component;
    // TODO: Supply the standard component mechanics.
    `uvm_component_utils(ub04_monitor)
    function new(string name, uvm_component parent);
      super.new(name, parent);
    endfunction
  endclass

  class ub04_agent extends uvm_agent;
    ub04_sequencer sequencer;
    ub04_driver driver;
    ub04_monitor monitor;

    // TODO: Supply the standard component mechanics.
    `uvm_component_utils(ub04_agent)
    function new(string name, uvm_component parent);
      super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        monitor = ub04_monitor::type_id::create("monitor", this);

        if(get_is_active() == UVM_ACTIVE) begin        
            sequencer = ub04_sequencer::type_id::create("sequencer", this);
            driver = ub04_driver::type_id::create("driver", this);
        end
    endfunction

    function void connect_phase(uvm_phase phase);
      // TODO: Establish only the connection that is valid for this mode.
        super.connect_phase(phase);
        if(get_is_active() == UVM_ACTIVE) begin
            driver.seq_item_port.connect(sequencer.seq_item_export);
        end
    endfunction
  endclass
endpackage
