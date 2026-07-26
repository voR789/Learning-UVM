package ui_g1_pkg;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  class counter_txn extends uvm_sequence_item;
    `uvm_object_utils(counter_txn)
    bit is_reset;
    bit [1:0] cmd;
    bit [7:0] load_value, observed_count;
    function new(string name="counter_txn"); super.new(name); endfunction
  endclass

  class counter_scenario extends uvm_sequence #(counter_txn);
    `uvm_object_utils(counter_scenario)
    function new(string name="counter_scenario"); super.new(name); endfunction
    task body();
      counter_txn req;
      bit resets[9] = '{0,1,0,0,0,0,0,0,0};
      bit [1:0] commands[9] = '{0,0,0,1,1,2,3,2,1};
      bit [7:0] loads[9] = '{255,0,5,0,0,0,0,0,0};
      for (int i=0; i<9; i++) begin
        req = counter_txn::type_id::create($sformatf("req_%0d",i));
        start_item(req);
        req.is_reset = resets[i];
        req.cmd = commands[i];
        req.load_value = loads[i];
        finish_item(req);
      end
    endtask
  endclass

  class counter_sequencer extends uvm_sequencer #(counter_txn);
    `uvm_component_utils(counter_sequencer)
    function new(string name,uvm_component parent); super.new(name,parent); endfunction
  endclass

  class counter_driver extends uvm_driver #(counter_txn);
    `uvm_component_utils(counter_driver)
    virtual counter_if vif;
    int completed;
    function new(string name,uvm_component parent); super.new(name,parent); endfunction
    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      if (!uvm_config_db #(virtual counter_if)::get(this,"","vif",vif))
        `uvm_fatal("NO_VIF","driver requires vif")
    endfunction
    task run_phase(uvm_phase phase);
      counter_txn req;
      vif.rst_n=1; vif.cmd_valid=0; vif.cmd=0; vif.load_value=0;
      forever begin
        seq_item_port.get_next_item(req);
        @(negedge vif.clk);
        vif.rst_n=!req.is_reset;
        vif.cmd_valid=!req.is_reset;
        vif.cmd=req.cmd;
        vif.load_value=req.load_value;
        @(posedge vif.clk);
        @(negedge vif.clk);
        vif.rst_n=1;
        vif.cmd_valid=0;
        completed++;
        seq_item_port.item_done();
      end
    endtask
  endclass

  class counter_monitor extends uvm_component;
    `uvm_component_utils(counter_monitor)
    virtual counter_if vif;
    uvm_analysis_port #(counter_txn) observed_ap;
    int published;
    function new(string name,uvm_component parent);
      super.new(name,parent);
      observed_ap=new("observed_ap",this);
    endfunction
    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      if (!uvm_config_db #(virtual counter_if)::get(this,"","vif",vif))
        `uvm_fatal("NO_VIF","monitor requires vif")
    endfunction
    task run_phase(uvm_phase phase);
      counter_txn observed;
      forever begin
        @(posedge vif.clk);
        if (!vif.rst_n || vif.cmd_valid) begin
          #1ps;
          observed=counter_txn::type_id::create("observed");
          observed.is_reset=!vif.rst_n;
          observed.cmd=vif.cmd;
          observed.load_value=vif.load_value;
          observed.observed_count=vif.count;
          observed_ap.write(observed);
          published++;
        end
      end
    endtask
  endclass

  class counter_scoreboard extends uvm_component;
    `uvm_component_utils(counter_scoreboard)
    uvm_analysis_imp #(counter_txn,counter_scoreboard) observed_imp;
    bit [7:0] expected_count;
    int checks;
    function new(string name,uvm_component parent);
      super.new(name,parent);
      observed_imp=new("observed_imp",this);
    endfunction
    function void write(counter_txn observed);
      if (observed.is_reset)
        expected_count=0;
      else
        case (observed.cmd)
          0: expected_count=observed.load_value;
          1: expected_count=expected_count+1;
          2: expected_count=expected_count-1;
          3: expected_count=0;
        endcase
      if (observed.observed_count != expected_count)
        `uvm_fatal("COUNT_MISMATCH",$sformatf(
          "cmd=%0d load=%0d expected=%0d observed=%0d",
          observed.cmd,observed.load_value,expected_count,observed.observed_count))
      checks++;
    endfunction
  endclass

  class counter_coverage extends uvm_subscriber #(counter_txn);
    `uvm_component_utils(counter_coverage)
    bit [1:0] sampled_cmd;
    bit [7:0] sampled_count;
    bit sampled_reset;
    int samples;
    covergroup counter_cg;
      option.per_instance=1;
      cp_cmd: coverpoint sampled_cmd iff (!sampled_reset) {
        bins load={0}; bins inc={1}; bins dec={2}; bins clear={3};
      }
      cp_count: coverpoint sampled_count {
        bins zero={0}; bins middle={[1:254]}; bins maximum={255};
      }
    endgroup
    function new(string name,uvm_component parent);
      super.new(name,parent);
      counter_cg=new;
    endfunction
    function void write(counter_txn observed);
      sampled_cmd=observed.cmd;
      sampled_count=observed.observed_count;
      sampled_reset=observed.is_reset;
      counter_cg.sample();
      samples++;
    endfunction
  endclass

  class counter_agent extends uvm_agent;
    `uvm_component_utils(counter_agent)
    counter_sequencer sequencer;
    counter_driver driver;
    counter_monitor monitor;
    function new(string name,uvm_component parent); super.new(name,parent); endfunction
    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      sequencer=counter_sequencer::type_id::create("sequencer",this);
      driver=counter_driver::type_id::create("driver",this);
      monitor=counter_monitor::type_id::create("monitor",this);
    endfunction
    function void connect_phase(uvm_phase phase);
      super.connect_phase(phase);
      driver.seq_item_port.connect(sequencer.seq_item_export);
    endfunction
  endclass

  class counter_env extends uvm_env;
    `uvm_component_utils(counter_env)
    counter_agent agent;
    counter_scoreboard scoreboard;
    counter_coverage coverage;
    function new(string name,uvm_component parent); super.new(name,parent); endfunction
    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      agent=counter_agent::type_id::create("agent",this);
      scoreboard=counter_scoreboard::type_id::create("scoreboard",this);
      coverage=counter_coverage::type_id::create("coverage",this);
    endfunction
    function void connect_phase(uvm_phase phase);
      super.connect_phase(phase);
      agent.monitor.observed_ap.connect(scoreboard.observed_imp);
      agent.monitor.observed_ap.connect(coverage.analysis_export);
    endfunction
  endclass

  class counter_test extends uvm_test;
    `uvm_component_utils(counter_test)
    counter_env env;
    function new(string name,uvm_component parent); super.new(name,parent); endfunction
    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      env=counter_env::type_id::create("env",this);
    endfunction
    task run_phase(uvm_phase phase);
      counter_scenario scenario;
      uvm_report_server server;
      real coverage_pct;
      int errors,fatals;
      phase.raise_objection(this);
      scenario=counter_scenario::type_id::create("scenario");
      scenario.start(env.agent.sequencer);
      @(negedge env.agent.driver.vif.clk);
      coverage_pct=env.coverage.counter_cg.get_inst_coverage();
      server=uvm_report_server::get_server();
      errors=server.get_severity_count(UVM_ERROR);
      fatals=server.get_severity_count(UVM_FATAL);
      if (env.agent.driver.completed != 9 ||
          env.agent.monitor.published != 9 ||
          env.scoreboard.checks != 9 ||
          env.coverage.samples != 9 ||
          coverage_pct < 100.0 || errors != 0 || fatals != 0)
        `uvm_fatal("BAD_VERDICT","integration completion criteria not met")
      $display("INTEGRATION_TRACE: driven=%0d observed=%0d checked=%0d sampled=%0d coverage=%0.2f errors=%0d fatals=%0d",
        env.agent.driver.completed,env.agent.monitor.published,
        env.scoreboard.checks,env.coverage.samples,coverage_pct,errors,fatals);
      $display("TEST_RESULT: PASS");
      phase.drop_objection(this);
    endtask
  endclass
endpackage
