# UI-03 Reflection

Answer after the package exercise passes.

1. Why must `ui03_pkg.sv` compile before `tb_top.sv`?
- `ui03_pkg.sv` must compile before `tb_top.sv` because the testbench references the package, so the package itself must be compiled first so tb_top's references to the package are defined.
2. What is the difference between importing `uvm_pkg` and including
   `uvm_macros.svh`?
- The difference is that `uvm_pkg` defines visibility for the items inside of the package such that one doesn't have to use the `uvm_pkg::...` syntax, and including `uvm_macros.svh` basically inserts all of the code that defines the macros commonly used in UVM, ie it allows us to use the other UVM macros. 
3. What does `` `uvm_object_utils(ui03_packet) `` provide, and what does it not
   do automatically?
- The ``uvm_object_utils(ui03_packet)` macro provides object registration for ui03_packet to the factory, such that it can be instantiated with the `type_id::create()` function later.
4. Why does the caller use `type_id::create` rather than directly calling
   `new`, and what later reuse mechanism does that prepare for?
- It uses `type_id::create()` because it provides a higher level of abstraction through the factory such that we can reuse our code in our testbench, and change the types of objects or components instantiated through a factory override!
1. Which package, macro, registration, or construction rule remains unclear?
- None, I feel like I have a pretty good idea now, let's move on to use cases, with real UVM syntax. (Basically learn from seeing it in action, and picking up tips and tricks)
