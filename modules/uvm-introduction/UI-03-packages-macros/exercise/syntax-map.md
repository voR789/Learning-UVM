# UI-03 Syntax Map

Complete the final two columns in your own words.

| Mechanism | Local syntax | What it does | What it does not do |
|---|---|---|---|
| Compile order | `ui03_pkg.sv` before `tb_top.sv` | Orchestrates the code in the package first, before the code that uses that package, such that `tb_top.sv` references code that is already compiled. | Give a namespace for  that package, or do anything macro related. |
| Package import | `import ui03_pkg::*;` | Gives visibility for items in the package, such that explicit referencing (ui03_pkg::ui03_packet) is un-needed (can just reference ui03_packet). | Does not ensure that the package compile order is correct (will NOT work if it doesn't compile in the correct order), or anything macro related. |
| Macro include | `` `include "uvm_macros.svh" `` | Inserts the definitions of the uvm macros before any normal operations, defines UVM based macros used to streamline boilerplate. | Import any functions, packages, etc. |
| Object registration | `` `uvm_object_utils(ui03_packet) `` | Inserts code that passes information about the object to the factory, such that we can then use the factory to instantiate the object. | Make an object, or makes the constructor for it. |
| Construction request | `ui03_packet::type_id::create("packet")` | Uses the factory abstraction layer to create an instance of the ui03_packet, configurable. | Create the handle assignment, must declare handle to assign to beforehand |

## Prediction

Why can importing `uvm_pkg` not replace including `uvm_macros.svh`?

- Importing uvm_pkg only gives us access to the uvm classes, while uvm_macros specifically defines other UVM macros that run before anything else, and defines important boilerplate code, such as object registrations!
