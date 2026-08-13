
  // Protocol indpendent drivers
  class tcs_cmd_driver extends uvm_driver #(cmd_req);
    // Drive commands through cmd_req protocol with a variety of driving policies
    `uvm_component_utils(tcs_cmd_driver)

    virtual tcs_if vif;

    function new(string name = "tcs_cmd_driver", uvm_component parent = null);
      super.new(name, parent);
    endfunction

    function void build_phase(
        uvm_phase phase
    );  // Phase handle is a reference to the UVM lifecycle phase, mainly used for objections 
      super.build_phase(phase);

      if (!uvm_config_db#(virtual tcs_if)::get(this, "", "vif", vif))
        `uvm_fatal("NO_VIF", "tcs_if was not configred!")
    endfunction

    task run_phase(uvm_phase phase);
      cmd_req req;
      req = cmd_req::type_id::create("cmd_req");
      forever begin
        @(negedge vif.clk);
        seq_item_port.get_next_item(req);
        vif.cmd_tag = req.cmd_tag;
        vif.cmd_op  = req.cmd_op;
        vif.cmd_a   = req.cmd_a;
        vif.cmd_b   = req.cmd_b;

        // Drive policy handles how we end driving transaction + handhshaking
        if (req.drive_mode == HOLD_ACCEPT) begin
          vif.cmd_valid = 1'b1;
          do begin
            @(posedge vif.clk);
          end while (!vif.cmd_ready);
          seq_item_port.item_done();
          // Block until we get an accepted response (Intention MUST eventually lead to acceptance)
        end else if (req.drive_mode == PULSE) begin
          vif.cmd_valid = 1'b1;
          @(posedge vif.clk);  // Let data sample
          seq_item_port.item_done();
        end else if (req.drive_mode == IDLE) begin
          vif.cmd_valid = 1'b0;
          @(posedge vif.clk);
          seq_item_port.item_done();
        end

        @(negedge vif.clk);
        vif.cmd_valid = 1'b0;  // Set to IDLE state after command sent
      end
    endtask
  endclass

  class tcs_rsp_driver extends uvm_driver #(rsp_req);
    // Drive rsp_ready through rsp_req with basic hold policy
    `uvm_component_utils(tcs_rsp_driver)

    virtual tcs_if vif;

    function new(string name, uvm_component parent = null);
      super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      if (!uvm_config_db#(virtual tcs_if)::get(this, "", "vif", vif))
        `uvm_fatal("NO_VIF", "tcs_if was not configured")
    endfunction

    task run_phase(uvm_phase phase);
      rsp_req req;
      req = rsp_req::type_id::create("rsp_req");
      forever begin
        seq_item_port.get_next_item(req);
        @(negedge vif.clk);
        vif.rsp_ready = req.rsp_ready;  // Just our ready value to the port, vif "holds it"
        @(posedge vif.clk);
        seq_item_port.item_done();
      end
    endtask
  endclass

  class tcs_rst_driver extends uvm_driver #(rst_req);
    // Drive rst_n through the rst_req interface as a 1 cycle pulse
    `uvm_component_utils(tcs_rst_driver)

    virtual tcs_if vif;

    function new(string name, uvm_component parent);
      super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      if (!uvm_config_db#(virtual tcs_if)::get(this, "", "vif", vif))
        `uvm_fatal("NO_VIF", "tcs_if was not configured")
    endfunction

    task run_phase(uvm_phase phase);
      rst_req req;
      req = rst_req::type_id::create("rst_req");
      forever begin
        seq_item_port.get_next_item(req);
        @(negedge vif.clk);
        vif.rst_n = req.rst_n;

        @(negedge vif.clk);
        vif.rst_n = 1'b1;  // Stop reset
        seq_item_port.item_done();

      end
    endtask
  endclass
