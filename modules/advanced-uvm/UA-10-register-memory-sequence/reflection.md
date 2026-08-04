# UA-10 reflection

Answer in your own words after the learner and fault runs.

1. Why must the two memory indices receive different expected patterns for the
   alias fixture to be observable?

- The two memory indices must recieve different expected patterns such that the if both calls alias the same storage, we know that there should be a different value in each.

2. What does `UVM_IS_OK` prove, and what does it fail to prove about a memory
   read?

- UVM_IS_OK proves that the internal UVM memory abstraction layer system sucessfully completed an operation without any issues. It proves the memory read went through. It does not prove the data is correct.

3. Why does `uvm_mem` avoid maintaining desired and mirrored data for every
   location, and where did this sequence retain its expectations instead?

- uvm_mem avoids maintaining the different pseduostates for the memory and the model because it is not simulation efficient for a large memory model such as uvm_mem. It works well enough for small models such as the uvm_reg. The sequence retains its expectations instead either by manually checking independent values, or using a larger memory array.

4. Why does enabling a RAL coverage flag not create meaningful coverage when
   the register or memory class implements no sampling model?

- Enabling the coverage flag does not create meaningful coverage when no sampling model is introduced because a coverage flag only enables/queries an already-implemented coverage model; it does not create a covergroup or sampling even.

5. Give the exact command that reproduces the alias-memory failure.

- powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\tests\run-fixture.ps1 -Test ua10_alias_memory_test
