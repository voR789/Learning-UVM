# Worked example: broadcast temperature samples

This example uses different types and names from the worksheet.

```systemverilog
class temp_sample extends uvm_object;
  `uvm_object_utils(temp_sample)
  int celsius;
  function new(string name = "temp_sample");
    super.new(name);
  endfunction
endclass

class sensor extends uvm_component;
  `uvm_component_utils(sensor)
  uvm_analysis_port #(temp_sample) sample_ap;

  function new(string name, uvm_component parent);
    super.new(name, parent);
    sample_ap = new("sample_ap", this);
  endfunction
endclass

class display_sink extends uvm_subscriber #(temp_sample);
  `uvm_component_utils(display_sink)
  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction
  function void write(temp_sample sample);
    `uvm_info("DISPLAY", $sformatf("%0d C", sample.celsius), UVM_LOW)
  endfunction
endclass

class alarm_sink extends uvm_component;
  `uvm_component_utils(alarm_sink)
  uvm_analysis_imp #(temp_sample, alarm_sink) sample_imp;
  function new(string name, uvm_component parent);
    super.new(name, parent);
    sample_imp = new("sample_imp", this);
  endfunction
  function void write(temp_sample sample);
    if (sample.celsius > 80)
      `uvm_error("ALARM", "temperature exceeded limit")
  endfunction
endclass
```

After the three components are created, their environment wires the fan-out:

```systemverilog
function void connect_phase(uvm_phase phase);
  super.connect_phase(phase);
  sensor_h.sample_ap.connect(display_h.analysis_export);
  sensor_h.sample_ap.connect(alarm_h.sample_imp);
endfunction
```

One later call to `sensor_h.sample_ap.write(sample)` immediately invokes both
receiver implementations. Neither receiver grants permission or returns a
completion acknowledgment.
