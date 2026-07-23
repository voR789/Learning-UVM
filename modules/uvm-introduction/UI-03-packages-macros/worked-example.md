# Worked example: packaged audit record

This example is separate from the learner-owned packet.

```systemverilog
package audit_pkg;
    import uvm_pkg::*;
    `include "uvm_macros.svh"

    class audit_record extends uvm_object;
        `uvm_object_utils(audit_record)

        function new(string name = "audit_record");
            super.new(name);
        endfunction
    endclass
endpackage
```

A consumer compiled afterward can use it:

```systemverilog
module audit_top;
    import audit_pkg::*;

    initial begin
        audit_record record;
        record = audit_record::type_id::create("record");
    end
endmodule
```

Trace each mechanism:

1. `audit_pkg.sv` compiles before the consumer.
2. `import uvm_pkg::*` exposes the `uvm_object` declaration inside the package.
3. `` `include "uvm_macros.svh" `` exposes macro definitions textually.
4. `` `uvm_object_utils(audit_record) `` registers the class and supplies its
   standard type interface.
5. `import audit_pkg::*` exposes `audit_record` inside `audit_top`.
6. `type_id::create` requests an instance by its registered type.

## Prediction

If the UVM package import remains but the macro header include is removed,
which name is still known—`uvm_object` or `` `uvm_object_utils ``—and why?
