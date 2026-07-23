# Worked example: test owns a reporter

This example is separate from the learner's nested container and leaf.

```systemverilog
class status_reporter extends uvm_component;
    `uvm_component_utils(status_reporter)

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction
endclass

class reporting_test extends uvm_test;
    `uvm_component_utils(reporting_test)

    status_reporter reporter;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        reporter = status_reporter::type_id::create("reporter", this);
    endfunction
endclass
```

Trace it:

1. `run_test` constructs `reporting_test` as `uvm_test_top`.
2. UVM calls `uvm_test_top.build_phase`.
3. The test asks the factory for `status_reporter`.
4. `"reporter"` supplies the child's short name.
5. `this` refers to the test and supplies the parent.
6. The reporter's full name becomes `uvm_test_top.reporter`.

The handle variable could be named `my_handle` without changing the runtime
path. Runtime naming comes from the string passed to `create`, not the handle's
source-code identifier.

## Prediction

If the handle variable remains `reporter` but the factory call becomes
`create("diagnostics", this)`, what full path will `print_topology` show?
