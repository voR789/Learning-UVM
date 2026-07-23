# Packages and macros: four mechanisms, four jobs

## 1. Observable problem

A compiler must answer four different questions:

1. Has the package definition already been compiled?
2. Are names from that package visible in this scope?
3. Has the preprocessor seen the macro definition before the macro is used?
4. Has this class declared UVM's standard type-registration machinery?

Mixing these questions leads to random-looking edits. Keep the mechanisms
separate.

## 2. Compile order

SystemVerilog compilation is dependency ordered. A package must be compiled
before a source file that imports it. An `import` does not search the disk or
compile the package; it only makes names from an already-known package visible.

```text
compile definitions first:  my_pkg.sv
compile consumers second:    tb_top.sv
```

## 3. Import

`import some_pkg::*;` makes declarations exported by `some_pkg` directly
visible in the current scope. Without an import, a declaration can often be
referenced explicitly as `some_pkg::some_type`.

Import operates on language declarations. It does not paste source text.

## 4. Include

`` `include "file.svh" `` is a preprocessor operation: it textually inserts a
file at that location before SystemVerilog parsing. UVM macros such as
`` `uvm_object_utils `` are defined in `uvm_macros.svh`, so that header must be
included before those macros are expanded.

Include does not make package declarations visible and does not replace correct
compile ordering.

## 5. Registration macro

For a simple object class, this module uses:

```systemverilog
`uvm_object_utils(class_name)
```

The macro adds standard UVM type information and the `type_id` interface used
by factory-based construction. It does not create an object immediately, make
the object persistent, or turn it into a component.

## 6. Constructor

A `uvm_object` conventionally accepts a name and forwards it to `super.new`:

```systemverilog
function new(string name = "class_name");
    super.new(name);
endfunction
```

The registration macro and constructor have different jobs: registration
describes the type to UVM; construction creates one instance when requested.

## 7. Reading check

Which mechanism pastes macro definitions into the current source, and which
mechanism makes already-compiled package declarations visible?
