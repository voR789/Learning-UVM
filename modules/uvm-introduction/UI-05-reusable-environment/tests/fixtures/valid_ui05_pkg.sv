package ui05_pkg;
    import uvm_pkg::*;
    `include "uvm_macros.svh"
    class ui05_env_config extends uvm_object; `uvm_object_utils(ui05_env_config) bit agent_active=1; function new(string name="ui05_env_config"); super.new(name); endfunction endclass
    class ui05_driver extends uvm_component; `uvm_component_utils(ui05_driver) function new(string name,uvm_component parent);super.new(name,parent);endfunction endclass
    class ui05_monitor extends uvm_component; `uvm_component_utils(ui05_monitor) function new(string name,uvm_component parent);super.new(name,parent);endfunction endclass
    class ui05_predictor extends uvm_component; `uvm_component_utils(ui05_predictor) function new(string name,uvm_component parent);super.new(name,parent);endfunction endclass
    class ui05_scoreboard extends uvm_component; `uvm_component_utils(ui05_scoreboard) function new(string name,uvm_component parent);super.new(name,parent);endfunction endclass
    class ui05_agent extends uvm_component;
        `uvm_component_utils(ui05_agent) bit is_active; ui05_driver driver; ui05_monitor monitor;
        function new(string name,uvm_component parent);super.new(name,parent);endfunction
        function void build_phase(uvm_phase phase);super.build_phase(phase);monitor=ui05_monitor::type_id::create("monitor",this);if(is_active)driver=ui05_driver::type_id::create("driver",this);endfunction
    endclass
    class ui05_env extends uvm_env;
        `uvm_component_utils(ui05_env) ui05_env_config cfg;ui05_agent agent;ui05_predictor predictor;ui05_scoreboard scoreboard;
        function new(string name,uvm_component parent);super.new(name,parent);endfunction
        function void build_phase(uvm_phase phase);super.build_phase(phase);if(cfg==null)`uvm_fatal("CFG","missing") agent=ui05_agent::type_id::create("agent",this);predictor=ui05_predictor::type_id::create("predictor",this);scoreboard=ui05_scoreboard::type_id::create("scoreboard",this);agent.is_active=cfg.agent_active;endfunction
    endclass
    class ui05_base_test extends uvm_test;
        `uvm_component_utils(ui05_base_test) ui05_env_config cfg;ui05_env env;bit requested_active=1;
        function new(string name,uvm_component parent);super.new(name,parent);endfunction
        function void build_phase(uvm_phase phase);super.build_phase(phase);cfg=ui05_env_config::type_id::create("cfg");cfg.agent_active=requested_active;env=ui05_env::type_id::create("env",this);env.cfg=cfg;endfunction
        task run_phase(uvm_phase phase);phase.raise_objection(this);uvm_top.print_topology();if((env.agent==null)||(env.predictor==null)||(env.scoreboard==null)||(env.agent.monitor==null))`uvm_fatal("HIER","missing") if(requested_active&&(env.agent.driver==null))`uvm_fatal("HIER","missing driver") if(!requested_active&&(env.agent.driver!=null))`uvm_fatal("HIER","passive driver") $display("ENV_TRACE: mode=%s",requested_active?"active":"passive");$display("TEST_RESULT: PASS");phase.drop_objection(this);endtask
    endclass
    class ui05_active_test extends ui05_base_test;`uvm_component_utils(ui05_active_test)function new(string name,uvm_component parent);super.new(name,parent);requested_active=1;endfunction endclass
    class ui05_passive_test extends ui05_base_test;`uvm_component_utils(ui05_passive_test)function new(string name,uvm_component parent);super.new(name,parent);requested_active=0;endfunction endclass
endpackage
