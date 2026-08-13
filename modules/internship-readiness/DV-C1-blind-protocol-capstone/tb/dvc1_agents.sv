  // Agents
  class tcs_cmd_agent extends uvm_agent;
    `uvm_component_utils(tcs_cmd_agent)

    tcs_cmd_sequencer sequencer;
    tcs_cmd_driver driver;
    tcs_cmd_mon monitor;

    function new(string name = "tcs_cmd_agent", uvm_component parent = null);
      super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      monitor = tcs_cmd_mon::type_id::create("tcs_cmd_mon", this);

      if (get_is_active() == UVM_ACTIVE) begin
        sequencer = tcs_cmd_sequencer::type_id::create("tcs_cmd_sequencer", this);
        driver = tcs_cmd_driver::type_id::create("tcs_cmd_driver", this);
      end
    endfunction


    function void connect_phase(uvm_phase phase);
      super.connect_phase(phase);
      if (get_is_active() == UVM_ACTIVE) begin
        driver.seq_item_port.connect(sequencer.seq_item_export);
      end
    endfunction
  endclass

  class tcs_rsp_agent extends uvm_agent;
    `uvm_component_utils(tcs_rsp_agent)

    tcs_rsp_sequencer sequencer;
    tcs_rsp_driver driver;
    tcs_rsp_mon monitor;

    function new(string name = "tcs_rsp_agent", uvm_component parent = null);
      super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      monitor = tcs_rsp_mon::type_id::create("tcs_rsp_mon", this);
      if (get_is_active() == UVM_ACTIVE) begin
        sequencer = tcs_rsp_sequencer::type_id::create("tcs_rsp_seqeuncer", this);
        driver = tcs_rsp_driver::type_id::create("tcs_rsp_driver", this);
      end
    endfunction

    function void connect_phase(uvm_phase phase);
      super.connect_phase(phase);
      if (get_is_active() == UVM_ACTIVE) begin
        driver.seq_item_port.connect(sequencer.seq_item_export);
      end
    endfunction
  endclass

  class tcs_rst_agent extends uvm_agent;
    `uvm_component_utils(tcs_rst_agent)

    tcs_rst_sequencer sequencer;
    tcs_rst_driver driver;
    tcs_rst_mon monitor;

    function new(string name = "tcs_rst_agent", uvm_component parent = null);
      super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      monitor = tcs_rst_mon::type_id::create("tcs_rst_mon", this);
      if (get_is_active() == UVM_ACTIVE) begin
        sequencer = tcs_rst_sequencer::type_id::create("tcs_rst_seqeuncer", this);
        driver = tcs_rst_driver::type_id::create("tcs_rst_driver", this);
      end
    endfunction

    function void connect_phase(uvm_phase phase);
      super.connect_phase(phase);
      if (get_is_active() == UVM_ACTIVE) begin
        driver.seq_item_port.connect(sequencer.seq_item_export);
      end
    endfunction
  endclass
