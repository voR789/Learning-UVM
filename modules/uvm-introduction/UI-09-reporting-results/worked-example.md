# Worked example: packet-parser reporting

This separate example shows the decision boundary without using the worksheet's
classes, counts, IDs, or data.

```systemverilog
class parser_reporter extends uvm_component;
  `uvm_component_utils(parser_reporter)
  int accepted;
  int rejected;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void classify(bit header_ok, bit optional_extension_unknown);
    if (!header_ok) begin
      rejected++;
      `uvm_error("PARSER_HEADER", "required header is invalid")
    end
    else if (optional_extension_unknown) begin
      accepted++;
      `uvm_warning("PARSER_EXTENSION", "ignored unknown optional extension")
    end
    else begin
      accepted++;
      `uvm_info("PARSER_ACCEPT", "packet accepted", UVM_LOW)
    end

    `uvm_info("PARSER_DETAIL", "classification complete", UVM_HIGH)
  endfunction
endclass
```

A test can set this component to `UVM_MEDIUM`: the low result remains visible,
the high detail is filtered, and warnings/errors still contribute to the report
summary. At end of test, it queries `uvm_report_server` severity counts and
combines them with `accepted` and `rejected` before deciding whether to pass.
