 // sequencers
  class tcs_cmd_sequencer extends uvm_sequencer #(cmd_req);
    `uvm_component_utils(tcs_cmd_sequencer)
    function new(string name = "tcs_cmd_sequencer", uvm_component parent);
      super.new(name, parent);
    endfunction
  endclass

  class tcs_rsp_sequencer extends uvm_sequencer #(rsp_req);
    `uvm_component_utils(tcs_rsp_sequencer)
    function new(string name = "tcs_rsp_sequencer", uvm_component parent);
      super.new(name, parent);
    endfunction
  endclass

  class tcs_rst_sequencer extends uvm_sequencer #(rst_req);
    `uvm_component_utils(tcs_rst_sequencer)
    function new(string name = "tcs_rst_sequencer", uvm_component parent);
      super.new(name, parent);
    endfunction
  endclass

  class tcs_virtual_sequencer extends uvm_sequencer;
    `uvm_component_utils(tcs_virtual_sequencer)
    tcs_cmd_sequencer cmd_sequencer;
    tcs_rsp_sequencer rsp_sequencer;
    tcs_rst_sequencer rst_sequencer;
    // Hold handles to agent owned sequencers
    function new(string name = "tcs_virtual_sequencer", uvm_component parent);
      super.new(name, parent);
    endfunction
  endclass
