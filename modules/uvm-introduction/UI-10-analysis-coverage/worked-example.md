# Worked example: response-kind coverage subscriber

This example uses different fields and bins from UI-10.

```systemverilog
class response_item extends uvm_object;
  `uvm_object_utils(response_item)
  bit [1:0] kind;
  bit       retried;
  function new(string name = "response_item");
    super.new(name);
  endfunction
endclass

class response_coverage extends uvm_subscriber #(response_item);
  `uvm_component_utils(response_coverage)
  bit [1:0] sampled_kind;
  bit       sampled_retried;
  int       samples;

  covergroup response_cg;
    option.per_instance = 1;
    cp_kind: coverpoint sampled_kind {
      bins accepted = {0};
      bins rejected = {1};
    }
    cp_retried: coverpoint sampled_retried {
      bins first_try = {0};
      bins retry = {1};
    }
    cx_kind_retry: cross cp_kind, cp_retried;
  endgroup

  function new(string name, uvm_component parent);
    super.new(name, parent);
    response_cg = new();
  endfunction

  function void write(response_item item);
    sampled_kind = item.kind;
    sampled_retried = item.retried;
    response_cg.sample();
    samples++;
  endfunction
endclass
```

The covergroup measures combinations seen at the subscriber boundary. It does
not generate traffic and does not decide whether each response was correct.
