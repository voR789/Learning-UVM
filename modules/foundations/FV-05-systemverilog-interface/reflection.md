# FV-05 Reflection

Complete these in your own words after the normal and fault runs.

1. What is the difference between the concrete `bus` interface instance and `checker_h.vif`?
- The difference between the concrete bus interface instance and checker_h.vif is that the bus interface is the complete interface, whilst checker_h.vif is a modport (limited instance) for the testbench side. This ensures the testbench does not unintentionally drive any signals that should not be driven, and reads only signals that should be read. 
2. From whose perspective are `dut_mp` and `tb_mp` directions declared?
- dut_mp is declared from the perspective of the design, so it drives (output) the results, carry, ... and reads (input) a, b, and op and tb_mp is from the perspective of the testbench, so it does vice versa.
3. Which testbench component owns driving, settling delay, sampling, and checking in this lab?
The alu_checker component owns all four of these operations. Because there is only a linear chain of events, we can compartmentalize all of them into the object, and call them with check_case().
4. Why will a virtual interface matter when the checker or driver later becomes a UVM component?
- This matters later because one, virtual interfaces make it easier to pass a bundle of relevant transaction signals to the dynamic components, and allow for fast reuse because if the components change, with individual pins, we have to refactor the whole project, while with interfaces, the abstraction provides a way for us to reuse parts better.
