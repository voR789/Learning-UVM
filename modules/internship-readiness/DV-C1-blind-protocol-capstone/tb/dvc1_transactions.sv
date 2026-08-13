// Driver requests are strictly different from pin observation: in this case, we can encapsulate cmd data into the request, 
  // and handle handshaking/driving behavior with a drive_mode variable
  class cmd_req extends uvm_sequence_item;
    // Don't use logic because we would never want to req X or Z
    bit [3:0] cmd_tag;
    rand bit [1:0] cmd_op;
    rand bit [7:0] cmd_a;
    rand bit [7:0] cmd_b;
    rand DRIVE_POLICY drive_mode;  // Drive mode handles cmd side handshaking for us
    `uvm_object_utils(cmd_req)

    function new(string name = "cmd_req");
      super.new(name);
    endfunction

    function string convert2string();
      return $sformatf("cmd_tag=0x%0h cmd_op=0x%0h cmd_a=0x%0h cmd_b=%0h", cmd_tag, cmd_op, cmd_a,
                       cmd_b);
    endfunction
  endclass

  class rsp_req extends uvm_sequence_item;
    // Don't use logic because we would never want to req X or Z
    rand bit rsp_ready;
    `uvm_object_utils(rsp_req)

    function new(string name = "rsp_req");
      super.new(name);
    endfunction

    function string convert2string();
      return $sformatf("rsp_ready=%0h", rsp_ready);
    endfunction
  endclass

  class rst_req extends uvm_sequence_item;
    rand bit rst_n;
    `uvm_object_utils(rst_req)

    function new(string name = "rst_req");
      super.new(name);
    endfunction

    function string convert2string();
      return $sformatf("rst_n=%0h", rst_n);
    endfunction
  endclass

  class cmd_obs extends uvm_object;
    bit [3:0] cmd_tag;
    bit [1:0] cmd_op;
    bit [7:0] cmd_a;
    bit [7:0] cmd_b;
    int acc_cycle;

    `uvm_object_utils(cmd_obs)
    function new(string name = "cmd_obs");
      super.new(name);
    endfunction

    function string convert2string();
      return $sformatf(
          "cmd_tag=0x%0h cmd_op=0x%0h cmd_a=0x%0h cmd_b=%0h acc_cycle=%0d",
          cmd_tag,
          cmd_op,
          cmd_a,
          cmd_b,
          acc_cycle
      );
    endfunction
  endclass

  class rsp_obs extends uvm_object;
    bit [3:0] rsp_tag;
    bit [1:0] rsp_status;
    bit [7:0] rsp_data;
    int rsp_cycle;

    // Coverage flag
    bit stalled_obs;

    `uvm_object_utils(rsp_obs)
    function new(string name = "rsp_obs");
      super.new(name);
    endfunction

    function string convert2string();
      return $sformatf(
          "rsp_tag=%0h rsp_status=%0h rsp_data=%0h rsp_cycle=%0d",
          rsp_tag,
          rsp_status,
          rsp_data,
          rsp_cycle
      );
    endfunction
  endclass

  class rst_obs extends uvm_object;
    bit reset;  // Observe active high reset

    `uvm_object_utils(rst_obs)
    function new(string name = "rst_obs");
      super.new(name);
    endfunction

    function string convert2string();
      return $sformatf("reset=%0h", reset);
    endfunction
  endclass
