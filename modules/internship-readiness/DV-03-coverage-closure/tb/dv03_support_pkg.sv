package dv03_support_pkg;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  typedef enum int unsigned {DV03_SHORT = 0, DV03_MEDIUM = 1, DV03_LONG = 2} dv03_length_e;

  class dv03_item extends uvm_sequence_item;
    int unsigned mode;
    dv03_length_e length_class;
    bit error;
    bit retry;
    `uvm_object_utils_begin(dv03_item)
      `uvm_field_int(mode, UVM_DEFAULT)
      `uvm_field_enum(dv03_length_e, length_class, UVM_DEFAULT)
      `uvm_field_int(error, UVM_DEFAULT)
      `uvm_field_int(retry, UVM_DEFAULT)
    `uvm_object_utils_end
    function new(string name = "dv03_item"); super.new(name); endfunction
  endclass

  class dv03_sequencer extends uvm_sequencer #(dv03_item);
    `uvm_component_utils(dv03_sequencer)
    uvm_analysis_port #(dv03_item) observed_ap;
    function new(string name, uvm_component parent);
      super.new(name, parent);
      observed_ap = new("observed_ap", this);
    endfunction
    task publish(int unsigned mode, dv03_length_e length_class, bit error, bit retry);
      dv03_item item;
      item = dv03_item::type_id::create("published_item");
      item.mode = mode;
      item.length_class = length_class;
      item.error = error;
      item.retry = retry;
      observed_ap.write(item);
      `uvm_info("DV03_OBS",
        $sformatf("mode=%0d length=%0d error=%0b retry=%0b",
                  mode, length_class, error, retry), UVM_LOW)
    endtask
  endclass

  class dv03_sequence_base extends uvm_sequence #(dv03_item);
    `uvm_object_utils(dv03_sequence_base)
    `uvm_declare_p_sequencer(dv03_sequencer)
    function new(string name = "dv03_sequence_base"); super.new(name); endfunction
    task emit(int unsigned mode, dv03_length_e length_class, bit error, bit retry);
      if (p_sequencer == null)
        `uvm_fatal("DV03_SEQR", "Target sequence has no dv03_sequencer")
      p_sequencer.publish(mode, length_class, error, retry);
    endtask
  endclass

  class dv03_coverage extends uvm_subscriber #(dv03_item);
    `uvm_component_utils(dv03_coverage)
    bit seen[6];
    int unsigned samples;
    int unsigned sampled_scenario;

    covergroup scenario_cg;
      option.per_instance = 1;
      scenario_cp: coverpoint sampled_scenario {
        bins required[] = {[0:5]};
      }
    endgroup

    function new(string name, uvm_component parent);
      super.new(name, parent);
      scenario_cg = new();
    endfunction

    function int scenario_id(dv03_item item);
      if (item.mode == 0 && item.length_class == DV03_SHORT && !item.error && !item.retry) return 0;
      if (item.mode == 0 && item.length_class == DV03_MEDIUM && item.error && !item.retry) return 1;
      if (item.mode == 1 && item.length_class == DV03_MEDIUM && !item.error && !item.retry) return 2;
      if (item.mode == 2 && item.length_class == DV03_SHORT && !item.error && !item.retry) return 3;
      if (item.mode == 1 && item.length_class == DV03_LONG && item.error && item.retry) return 4;
      if (item.mode == 2 && item.length_class == DV03_LONG && !item.error && !item.retry) return 5;
      return -1;
    endfunction

    function void write(dv03_item t);
      int id;
      id = scenario_id(t);
      samples++;
      if (id < 0) begin
        `uvm_error("DV03_ILLEGAL", $sformatf("Prohibited scenario observed: %s", t.convert2string()))
      end else begin
        sampled_scenario = id;
        seen[id] = 1;
        scenario_cg.sample();
      end
    endfunction

    function int unsigned observed_required();
      int unsigned count;
      count = 0;
      for (int index = 0; index < 6; index++)
        if (seen[index]) count++;
      return count;
    endfunction
  endclass

  class dv03_env extends uvm_env;
    `uvm_component_utils(dv03_env)
    dv03_sequencer sequencer;
    dv03_coverage coverage;
    function new(string name, uvm_component parent); super.new(name, parent); endfunction
    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      sequencer = dv03_sequencer::type_id::create("sequencer", this);
      coverage = dv03_coverage::type_id::create("coverage", this);
    endfunction
    function void connect_phase(uvm_phase phase);
      super.connect_phase(phase);
      sequencer.observed_ap.connect(coverage.analysis_export);
    endfunction
  endclass
endpackage
