
// cmd helper sequence
class cmd_issue extends uvm_sequence #(cmd_req);
  bit [3:0] cmd_tag;
  bit [1:0] cmd_op;
  bit [7:0] cmd_a;
  bit [7:0] cmd_b;
  DRIVE_POLICY drive_mode;  // Controls command side handshake

  `uvm_object_utils(cmd_issue);

  function new(string name = "cmd_issue");
    super.new(name);
  endfunction

  function void configure(bit [3:0] tag, bit [1:0] op, bit [7:0] a, bit [7:0] b, DRIVE_POLICY dm);
    cmd_tag = tag;
    cmd_op = op;
    cmd_a = a;
    cmd_b = b;
    drive_mode = dm;
  endfunction

  // Basic send command side request, with no response handling (handled in higher levels)
  task body();
    cmd_req req;
    req = cmd_req::type_id::create("cmd_req");
    start_item(req);
    req.cmd_tag = cmd_tag;
    req.cmd_op = cmd_op;
    req.cmd_a = cmd_a;
    req.cmd_b = cmd_b;
    req.drive_mode = drive_mode;
    finish_item(req);
  endtask
endclass

class cmd_rand extends uvm_sequence #(cmd_req);
  `uvm_object_utils(cmd_rand)

  bit [3:0] cmd_tag;
  bit [1:0] cmd_op;
  int random_mode;  // 1 for overflow, 0 for non-overflow, 2 for neither, 3 for non add randomization with 
  DRIVE_POLICY drive_mode;  // Controls command side handshake

  function new(string name = "cmd_rand");
    super.new(name);
  endfunction

  function void configure(bit [3:0] tag, bit [1:0] op, int rm, DRIVE_POLICY dm);
    cmd_tag = tag;
    cmd_op = op;
    random_mode = rm;
    drive_mode = dm;
  endfunction

  task body();
    cmd_req cmd;
    cmd = cmd_req::type_id::create();
    start_item(cmd);
    cmd.cmd_tag = cmd_tag;
    cmd.cmd_op = cmd_op;
    cmd.drive_mode = drive_mode;
    if (random_mode == 1) begin // Overflow mode, selected op + drive mode
      if (!cmd.randomize(cmd_a, cmd_b) with {{1'b0, cmd_a} +{1'b0, cmd_b} > 255;})
        `uvm_fatal("RANDOMIZE_FAIL", $sformatf("cmd_req failed to randomize (overflow)"))

    end else if (random_mode == 0) begin  // Non-overflow mode, selected op + drive mode
      if (!cmd.randomize(cmd_a, cmd_b) with {{1'b0, cmd_a} +{1'b0, cmd_b} <= 255;})
        `uvm_fatal("RANDOMIZE_FAIL", "cmd_req failed to randomize (non-overflow)")
    
    end else if(random_mode == 2) begin // Selected op + drive mode
      if (!cmd.randomize(cmd_a, cmd_b)) `uvm_fatal("RANDOMIZE_FAIL", "cmd_req failed to randomize")
    
    end else if(random_mode == 3) begin // Random a, b, op, selected drive mode
      if(!cmd.randomize(cmd_op, cmd_a, cmd_b)) `uvm_fatal("RANDOMIZE_FAIL", "cmd_req failed to randomize")
    
    end else if(random_mode == 4) begin // Full random mode
      if(!cmd.randomize()) `uvm_fatal("RANDOMIZE_FAIL", "cmd_req failed to randomize")
    end
    finish_item(cmd);
  endtask
endclass
// always rsp ready sequence
class rsp_always_ready extends uvm_sequence #(rsp_req);
  `uvm_object_utils(rsp_always_ready)

  function new(string name = "rsp_always_ready");
    super.new(name);
  endfunction

  task body();
    rsp_req req;
    req = rsp_req::type_id::create("rsp_req");
    start_item(req);
    req.rsp_ready = 1'b1;
    finish_item(req);

  endtask
endclass

// Set rsp sequence
class rsp_set extends uvm_sequence #(rsp_req);
  `uvm_object_utils(rsp_set)
  bit rsp_ready;
  function new(string name = "rsp_set");
    super.new(name);
  endfunction

  function void configure(bit val);
    rsp_ready = val;
  endfunction

  task body();
    rsp_req req;
    req = rsp_req::type_id::create("rsp_req");
    start_item(req);
    req.rsp_ready = rsp_ready;
    finish_item(req);
  endtask
endclass

// Random rsp seqeunce
class rsp_rand extends uvm_sequence #(rsp_req);
  `uvm_object_utils(rsp_rand)

  function new(string name = "rsp_rand");
    super.new(name);
  endfunction

  task body();
    rsp_req req;
    req = rsp_req::type_id::create();
    start_item(req);
    if(!req.randomize() with {
      rsp_ready dist {
        1'b0 := 25,
        1'b1 := 75
      };
    }) `uvm_fatal("RANDOMIZATION FAIL", "failed to randomize rsp_req")
    finish_item(req);
  endtask
endclass

// apply reset sequence
class rst_apply_reset extends uvm_sequence #(rst_req);
  `uvm_object_utils(rst_apply_reset)

  function new(string name = "rst_apply_reset");
    super.new(name);
  endfunction

  task body();
    rst_req req;

    // Assert reset
    req = rst_req::type_id::create("rst_req0");
    start_item(req);
    req.rst_n = 1'b0;
    finish_item(req);
    // Deassert reset
    req = rst_req::type_id::create("rst_req1");
    start_item(req);
    req.rst_n = 1'b1;
    finish_item(req);
  endtask
endclass

// virtual smoke sequence
class tcs_smoke_seq extends uvm_sequence;
  `uvm_object_utils(tcs_smoke_seq)
  `uvm_declare_p_sequencer(tcs_virtual_sequencer)

  function new(string name = "tcs_smoke_seq");
    super.new(name);
  endfunction

  task body();
    cmd_issue cmd_seq;
    rsp_always_ready rsp_seq;
    rst_apply_reset rst_seq;

    cmd_seq = cmd_issue::type_id::create();
    rsp_seq = rsp_always_ready::type_id::create();
    rst_seq = rst_apply_reset::type_id::create();

    rst_seq.start(p_sequencer.rst_sequencer);

    // Set sequence properties
    cmd_seq.configure(4'h1, 2'h0, 8'h1, 8'h2, HOLD_ACCEPT);  // Wrapping add, 1 + 2

    // Make vif hold rsp_ready, no need for fork
    rsp_seq.start(p_sequencer.rsp_sequencer);

    cmd_seq.start(p_sequencer.cmd_sequencer);


  endtask
endclass

class tcs_reset_seq extends uvm_sequence;
  `uvm_object_utils(tcs_reset_seq)
  `uvm_declare_p_sequencer(tcs_virtual_sequencer)

  function new(string name = "tcs_reset_seq");
    super.new(name);
  endfunction

  task body();
    cmd_issue cmd_seq;
    rsp_always_ready rsp_seq;
    rst_apply_reset rst_seq;

    cmd_seq = cmd_issue::type_id::create();
    rsp_seq = rsp_always_ready::type_id::create();
    rst_seq = rst_apply_reset::type_id::create();

    // TC-RST-01
    rst_seq.start(p_sequencer.rst_sequencer);
    // TC-RST-02
    rsp_seq.start(p_sequencer.rsp_sequencer);

    cmd_seq.configure(4'h1, 2'b00, 8'h1, 8'h2, HOLD_ACCEPT);
    cmd_seq.start(p_sequencer.cmd_sequencer);

    rst_seq.start(p_sequencer.rst_sequencer);

    cmd_seq.configure(4'h2, 2'b00, 8'h10, 8'h20, HOLD_ACCEPT);
    cmd_seq.start(p_sequencer.cmd_sequencer);
  endtask
endclass

class tcs_op_seq extends uvm_sequence;
  `uvm_object_utils(tcs_op_seq)
  `uvm_declare_p_sequencer(tcs_virtual_sequencer)
  bit [3:0] tag_count;

  function new(string name = "tcs_op_seq");
    super.new(name);
  endfunction

  task body();
    cmd_issue cmd_seq;
    cmd_rand cmd_rand_seq;
    rsp_always_ready rsp_seq;
    rst_apply_reset rst_seq;

    cmd_seq = cmd_issue::type_id::create();
    cmd_rand_seq = cmd_rand::type_id::create();
    rsp_seq = rsp_always_ready::type_id::create();
    rst_seq = rst_apply_reset::type_id::create();

    tag_count = 1;
    // TC-WRAP-ADD-01
    rst_seq.start(p_sequencer.rst_sequencer);
    rsp_seq.start(p_sequencer.rsp_sequencer);

    // send w-add non overflow

    cmd_rand_seq.configure(tag_count, 2'b00, 0, HOLD_ACCEPT);
    cmd_rand_seq.start(p_sequencer.cmd_sequencer);
    tag_count++;

    // send w-add overflow

    cmd_rand_seq.configure(tag_count, 2'b00, 1, HOLD_ACCEPT);
    cmd_rand_seq.start(p_sequencer.cmd_sequencer);
    tag_count++;


    // TC-XOR-01
    cmd_rand_seq.configure(tag_count, 2'b01, 2, HOLD_ACCEPT);
    cmd_rand_seq.start(p_sequencer.cmd_sequencer);
    tag_count++;
    // TC-SAT-ADD-01
    // send s-add non overflow
    cmd_rand_seq.configure(tag_count, 2'b10, 0, HOLD_ACCEPT);
    cmd_rand_seq.start(p_sequencer.cmd_sequencer);
    tag_count++;
    // send s-add overflow
    cmd_rand_seq.configure(tag_count, 2'b10, 1, HOLD_ACCEPT);
    cmd_rand_seq.start(p_sequencer.cmd_sequencer);
    tag_count++;

    // TC-INVALID-OP
    cmd_seq.configure(tag_count, 2'b11, 8'h1, 8'h2, HOLD_ACCEPT);
    cmd_seq.start(p_sequencer.cmd_sequencer);
    tag_count++;
  endtask
endclass

class tcs_protocol_seq extends uvm_sequence;
  `uvm_object_utils(tcs_protocol_seq)
  `uvm_declare_p_sequencer(tcs_virtual_sequencer)

  function new(string name = "tcs_protocol_seq");
    super.new(name);
  endfunction

  task body();
    // Declare leaf-sequences
    int tag_count;
    cmd_rand cmd_seq;
    rsp_set rsp_seq;
    rst_apply_reset rst_seq;

    tag_count = 1;
    cmd_seq = cmd_rand::type_id::create("cmd_seq");
    rsp_seq = rsp_set::type_id::create("rsp_seq");
    rst_seq = rst_apply_reset::type_id::create("rst_seq");

    // TC-FULL-01
    rst_seq.start(p_sequencer.rst_sequencer);
    rsp_seq.configure(1'b0); // Set rsp_ready low
    rsp_seq.start(p_sequencer.rsp_sequencer);
    
    repeat(4) begin // drive 4 randomized ops with HOLD_ACCEPT
      cmd_seq.configure(tag_count++, 2'b00, 3, HOLD_ACCEPT);
      cmd_seq.start(p_sequencer.cmd_sequencer);
    end
    cmd_seq.configure(tag_count++, 2'b00, 3, PULSE); // Send probe (should not be accepted)
    cmd_seq.start(p_sequencer.cmd_sequencer);

    rsp_seq.configure(1'b1); // Re-arm rsp_ready
    rsp_seq.start(p_sequencer.rsp_sequencer);

    #1us; // Allow tcs to drain

    // Recovery op
    cmd_seq.configure(tag_count++, 2'b00, 3, HOLD_ACCEPT);
    cmd_seq.start(p_sequencer.cmd_sequencer);
    #1us; // Drain

    // TC-LATENCY-01
    tag_count = 1;
    rst_seq.start(p_sequencer.rst_sequencer);
    // Send randomized value commands
    cmd_seq.configure(tag_count++, 2'b00, 2, HOLD_ACCEPT);
    cmd_seq.start(p_sequencer.cmd_sequencer);
    
    cmd_seq.configure(tag_count++, 2'b01, 2, HOLD_ACCEPT);
    cmd_seq.start(p_sequencer.cmd_sequencer);
    
    cmd_seq.configure(tag_count++, 2'b10, 2, HOLD_ACCEPT);
    cmd_seq.start(p_sequencer.cmd_sequencer);
    
    cmd_seq.configure(tag_count++, 2'b11, 2, HOLD_ACCEPT);
    cmd_seq.start(p_sequencer.cmd_sequencer);
    #1us; // Drain

    // TC-LATENCY-02
    tag_count = 1;
    rst_seq.start(p_sequencer.rst_sequencer);
    rsp_seq.configure(1'b0); // De-arm rsp_ready;
    rsp_seq.start(p_sequencer.rsp_sequencer);

    cmd_seq.configure(tag_count++, 2'b00, 3, HOLD_ACCEPT);
    cmd_seq.start(p_sequencer.cmd_sequencer);

    cmd_seq.configure(tag_count++, 2'b00, 3, HOLD_ACCEPT);
    cmd_seq.start(p_sequencer.cmd_sequencer);

    rsp_seq.configure(1'b1); // Re-arm rsp_ready;
    rsp_seq.start(p_sequencer.rsp_sequencer);

    cmd_seq.configure(tag_count++, 2'b00, 3, HOLD_ACCEPT);
    cmd_seq.start(p_sequencer.cmd_sequencer);
    
    cmd_seq.configure(tag_count++, 2'b00, 3, HOLD_ACCEPT);
    cmd_seq.start(p_sequencer.cmd_sequencer);    
  endtask
endclass

class tcs_stress_seq extends uvm_sequence;
  `uvm_object_utils(tcs_stress_seq)
  `uvm_declare_p_sequencer(tcs_virtual_sequencer)

  function new(string name = "tcs_stress_seq");
    super.new(name);
  endfunction

  task body();
    int tag_count;
    cmd_rand cmd_seq;
    rsp_rand rsp_seq;
    rsp_always_ready rsp_seq_drain;
    rst_apply_reset rst_seq;

    tag_count = 1;
    cmd_seq = cmd_rand::type_id::create();
    rsp_seq = rsp_rand::type_id::create();
    rsp_seq_drain = rsp_always_ready::type_id::create();
    rst_seq =  rst_apply_reset::type_id::create();

    // Start w/ reset
    rst_seq.start(p_sequencer.rst_sequencer);

    repeat(10) begin
      cmd_seq.configure(tag_count++, 2'b00, 4, HOLD_ACCEPT); // Randomized a, b, op, drive policy
      fork
        cmd_seq.start(p_sequencer.cmd_sequencer); 
        rsp_seq.start(p_sequencer.rsp_sequencer);// TODO: Figure out if this workks
      join
      
      rsp_seq_drain.start(p_sequencer.rsp_sequencer);
    end
  endtask
  
endclass
