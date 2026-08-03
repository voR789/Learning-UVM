# UA-10 reflection

Answer in your own words after the learner and fault runs.

1. Why must the two memory indices receive different expected patterns for the
   alias fixture to be observable?

2. What does `UVM_IS_OK` prove, and what does it fail to prove about a memory
   read?

3. Why does `uvm_mem` avoid maintaining desired and mirrored data for every
   location, and where did this sequence retain its expectations instead?

4. Why does enabling a RAL coverage flag not create meaningful coverage when
   the register or memory class implements no sampling model?

5. Give the exact command that reproduces the alias-memory failure.
