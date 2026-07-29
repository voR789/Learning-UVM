package ub04_check_pkg;
  import uvm_pkg::*;
  import ub04_pkg::*;
  `include "uvm_macros.svh"

  class ub04_base_test extends uvm_test;
    `uvm_component_utils(ub04_base_test)
    ub04_agent agent;
    uvm_active_passive_enum requested_mode;

    function new(string name, uvm_component parent);
      super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
      uvm_config_db#(uvm_active_passive_enum)::set(
        this, "agent", "is_active", requested_mode
      );
      super.build_phase(phase);
      agent = ub04_agent::type_id::create("agent", this);
    endfunction

    task run_phase(uvm_phase phase);
      int driver_present;
      int sequencer_present;
      int monitor_present;
      int request_connected;

      phase.raise_objection(this);
      driver_present = 0;
      sequencer_present = 0;
      monitor_present = 0;
      request_connected = 0;

      if (agent == null)
        `uvm_fatal("UB04_TOPOLOGY", "agent was not constructed")
      else begin
        if (agent.monitor != null)
          monitor_present = 1;
        if (agent.driver != null)
          driver_present = 1;
        if (agent.sequencer != null)
          sequencer_present = 1;

        if (requested_mode == UVM_ACTIVE) begin
          if (!monitor_present || !driver_present || !sequencer_present)
            `uvm_fatal("UB04_ACTIVE_TOPOLOGY",
                       "active mode requires monitor, driver, and sequencer")
          if (agent.driver.seq_item_port.size() > 0)
            request_connected = 1;
          if (!request_connected)
            `uvm_fatal("UB04_CONNECTION",
                       "active driver request port is not connected")
        end
        else begin
          if (!monitor_present || driver_present || sequencer_present)
            `uvm_fatal("UB04_PASSIVE_TOPOLOGY",
                       "passive mode requires monitor only")
        end

        $display("AGENT_TRACE: mode=%s monitor=%0d driver=%0d sequencer=%0d connected=%0d",
                 requested_mode.name(), monitor_present, driver_present,
                 sequencer_present, request_connected);
        $display("TEST_RESULT: PASS");
      end
      phase.drop_objection(this);
    endtask
  endclass

  class ub04_active_test extends ub04_base_test;
    `uvm_component_utils(ub04_active_test)
    function new(string name, uvm_component parent);
      super.new(name, parent);
      requested_mode = UVM_ACTIVE;
    endfunction
  endclass

  class ub04_passive_test extends ub04_base_test;
    `uvm_component_utils(ub04_passive_test)
    function new(string name, uvm_component parent);
      super.new(name, parent);
      requested_mode = UVM_PASSIVE;
    endfunction
  endclass
endpackage
