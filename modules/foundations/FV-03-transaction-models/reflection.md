# FV-03 Reflection

Complete these in your own words after the lab passes.

1. Why did assigning one class variable to another create an alias rather than a copy?
- Assigning one class variable to another created an alias because SystemVerilog uses Object Oriented Programming. When assinging the class variable to a new handle, the code does make a copy, but only a shallow copy of just the handle. This is why the second handle acts as an alias and not an independent copy.
2. What made `independent_copy` independent, and how did you prove it?
- Independent copy was independent because we made a deep copy, generating independent internal values for each field. We proved it by changing the "expected_carry" variable within the copy, and compared it to the original.
3. Why must a transaction comparison include every verification-relevant field?
- A transaction comparison must include every verification relevant field because in verification, we want to make sure our actual transaction exactly matches our expected. Of course, in some test plans, we will want to compare only a couple of signals, so this doesn't apply to every situation.
4. Where will transaction objects replace positional arguments in a larger testbench or UVM environment?
- Transaction objects will be able to replace individual signals, as comparing, assigning, and handling individual signals can make a lot of boilerplate code, whilst bundling them into a transaction object makes our code not only cleaner, but much more reusable. In a practical sense, transactions can make data transfer between UVM compoennts cleaner, and are translated back into pin-level signals by the driver.