package ub01_pkg;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  class ub01_driver extends uvm_component;
    `uvm_component_utils(ub01_driver)
    function new(string name, uvm_component parent);
      super.new(name, parent);
    endfunction
  endclass

  class ub01_monitor extends uvm_component;
    `uvm_component_utils(ub01_monitor)
    function new(string name, uvm_component parent);
      super.new(name, parent);
    endfunction
  endclass

  class ub01_agent extends uvm_agent;
    `uvm_component_utils(ub01_agent)
    bit requested_active;
    ub01_driver driver;
    ub01_monitor monitor;

    function new(string name, uvm_component parent);
      super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      if (!uvm_config_db#(bit)::get(this, "", "requested_active",
                                    requested_active))
        `uvm_fatal("UB01_CONFIG", "agent mode was not configured")
      monitor = ub01_monitor::type_id::create("monitor", this);
      if (requested_active)
        driver = ub01_driver::type_id::create("driver", this);
    endfunction
  endclass

  class ub01_env extends uvm_env;
    `uvm_component_utils(ub01_env)
    ub01_agent agent;

    function new(string name, uvm_component parent);
      super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      agent = ub01_agent::type_id::create("agent", this);
    endfunction
  endclass

  class ub01_base_test extends uvm_test;
    `uvm_component_utils(ub01_base_test)
    ub01_env env;
    bit expected_active;

    function new(string name, uvm_component parent);
      super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
      uvm_config_db#(bit)::set(this, "env.agent", "requested_active",
                               expected_active);
      super.build_phase(phase);
      env = ub01_env::type_id::create("env", this);
    endfunction

    task run_phase(uvm_phase phase);
      int driver_present;
      phase.raise_objection(this);
      if (env.agent.monitor == null)
        `uvm_fatal("UB01_TOPOLOGY", "monitor must exist in every mode")
      if (env.agent.driver == null)
        driver_present = 0;
      else
        driver_present = 1;
      if (driver_present != expected_active)
        `uvm_fatal("UB01_TOPOLOGY", "driver topology contradicts test mode")
      $display("FLOW_TRACE: test=%s active=%0d driver=%0d monitor=1",
               get_type_name(), expected_active, driver_present);
      $display("TEST_RESULT: PASS");
      phase.drop_objection(this);
    endtask
  endclass

  class ub01_active_test extends ub01_base_test;
    `uvm_component_utils(ub01_active_test)
    function new(string name, uvm_component parent);
      super.new(name, parent);
      expected_active = 1;
    endfunction
  endclass

  class ub01_passive_test extends ub01_base_test;
    `uvm_component_utils(ub01_passive_test)
    function new(string name, uvm_component parent);
      super.new(name, parent);
      expected_active = 0;
    endfunction
  endclass
endpackage
