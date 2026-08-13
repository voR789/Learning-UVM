  class tcs_env extends uvm_env;
    `uvm_component_utils(tcs_env)
    tcs_virtual_sequencer sequencer;

    tcs_cmd_agent cmd_agent;
    tcs_rsp_agent rsp_agent;
    tcs_rst_agent rst_agent;

    tcs_coverage coverage;
    tcs_model predictor;
    tcs_scoreboard scoreboard;

    function new(string name, uvm_component parent);
      super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      sequencer  = tcs_virtual_sequencer::type_id::create("tcs_virtual_sequencer", this);

      cmd_agent  = tcs_cmd_agent::type_id::create("tcs_cmd_agent", this);
      rsp_agent  = tcs_rsp_agent::type_id::create("tcs_rsp_agent", this);
      rst_agent  = tcs_rst_agent::type_id::create("tcs_rst_agent", this);

      coverage   = tcs_coverage::type_id::create("tcs_coverage", this);
      predictor  = tcs_model::type_id::create("tcs_model", this);
      scoreboard = tcs_scoreboard::type_id::create("tcs_scoreboard", this);
    endfunction

    function void connect_phase(uvm_phase phase);
      super.connect_phase(phase);
      // Give virtual sequencer protocol sequencer handles
      sequencer.cmd_sequencer = cmd_agent.sequencer;
      sequencer.rsp_sequencer = rsp_agent.sequencer;
      sequencer.rst_sequencer = rst_agent.sequencer;

      // Connect agents to analysis components
      cmd_agent.monitor.cmd_obs_ap.connect(coverage.cmd_imp);
      cmd_agent.monitor.cmd_obs_ap.connect(predictor.analysis_export);
      cmd_agent.monitor.cmd_obs_ap.connect(scoreboard.cmd_imp);

      rsp_agent.monitor.rsp_obs_ap.connect(coverage.rsp_imp);
      rsp_agent.monitor.rsp_obs_ap.connect(scoreboard.rsp_imp);

      rst_agent.monitor.rst_obs_ap.connect(coverage.rst_imp);
      rst_agent.monitor.rst_obs_ap.connect(scoreboard.rst_imp);

      // Connect model to scoreboard
      predictor.model_ap.connect(scoreboard.exp_imp);
    endfunction
  endclass
