  class tcs_base_test extends uvm_test;
    `uvm_component_utils(tcs_base_test)

    tcs_env env;

    function new(string name = "tcs_base_test", uvm_component parent = null);
      super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      env = tcs_env::type_id::create("tcs_env", this);
    endfunction

  endclass

  class tcs_smoke_test extends tcs_base_test;
    `uvm_component_utils(tcs_smoke_test)

    function new(string name = "tcs_smoke_test", uvm_component parent = null);
      super.new(name, parent);
    endfunction

    task run_phase(uvm_phase phase);
      tcs_smoke_seq seq;  // Create virtual sequence in run_phase because it's only used once.
      phase.raise_objection(this);
      seq = tcs_smoke_seq::type_id::create("tcs_smoke_seq");
      seq.start(super.env.sequencer);
      #1us;
      phase.drop_objection(this);

    endtask
  endclass

  class tcs_reset_test extends tcs_base_test;
    `uvm_component_utils(tcs_reset_test)

    function new(string name = "tcs_reset_test", uvm_component parent);
      super.new(name, parent);
    endfunction

    task run_phase(uvm_phase phase);
      tcs_reset_seq seq;
      phase.raise_objection(this);
      seq = tcs_reset_seq::type_id::create("tcs_reset_seq");
      seq.start(super.env.sequencer);
      #1us; // allow drainage TODO: improve with more robust system
      phase.drop_objection(this);
    endtask
  endclass

  class tcs_op_test extends tcs_base_test;
    `uvm_component_utils(tcs_op_test)

    function new(string name = "tcs_op_test", uvm_component parent);
      super.new(name, parent);
    endfunction

    task run_phase(uvm_phase phase);
      tcs_op_seq seq;
      phase.raise_objection(this);
      seq = tcs_op_seq::type_id::create("tcs_op_seq");
      seq.start(super.env.sequencer);
      #1us;
      phase.drop_objection(this);
    endtask
  endclass

  class tcs_protocol_test extends tcs_base_test;
    `uvm_component_utils(tcs_protocol_test)

    function new(string name = "tcs_protocol_test", uvm_component parent);
      super.new(name, parent);
    endfunction

    task run_phase(uvm_phase phase);
      tcs_protocol_seq seq;
      phase.raise_objection(this);
      seq = tcs_protocol_seq::type_id::create("tcs_protocol_seq");
      seq.start(super.env.sequencer);
      #1us; // Allow commands to drain
      phase.drop_objection(this);
    endtask
  endclass

  class tcs_stress_test extends tcs_base_test;
    `uvm_component_utils(tcs_stress_test)

    function new(string name = "tcs_stress_test", uvm_component parent);
      super.new(name, parent);
    endfunction

    task run_phase(uvm_phase phase);
      tcs_stress_seq seq;
      phase.raise_objection(this);
      seq = tcs_stress_seq::type_id::create("tcs_stress_seq");
      seq.start(super.env.sequencer);
      #2us; // allow drain
      phase.drop_objection(this);
    endtask
  endclass
  
