# FV-00 Reflection

Complete these in your own words after running the module.

1. What does `xvlog` produce or validate?
- xvlog is a command from Vivado's CLI (command line interface) that compiles the HDL Verilog/SystemVerilog code into a format that the simulator understands.
2. What additional work does `xelab` perform, and what is a snapshot?
  - xelab is the elaboration phase of the simulation process, in which Vivado links all of the underlying modules, and produces syntax warning/errors, as well as any other linter violations.
3. Why must the runner inspect UVM errors instead of trusting only XSim's process exit code?
- The runner must inspect UVM errors because XSim's process exit code only indicates that the simulation finished sucessfully, not guarunteeing that the testbench operated successfully.
4. How do the test name and seed make a failure reproducible?
  - The test name describes which test is being ran, and the seed is the base of the randomized values, which allows us to run the same randomized values and observe what specific values are producing a failiure.
5. Which files under `build/` would you inspect first for a compilation failure, an elaboration failure, and a runtime failure?
- For a compilation failiure, the info, errors and warnings are in the xvlog file. Similary the same for elaboration and runtime is in xelab, and xsim respectively.
