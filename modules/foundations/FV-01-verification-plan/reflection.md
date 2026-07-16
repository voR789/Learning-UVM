# FV-01 Reflection

Complete these in your own words after the structural check passes.

1. Which planned case is most likely to expose a plausible implementation bug, and what bug would it detect? 
- The planned case most likely to expose a plausible implementation bug is TC-ADD-03 because the result, carry, and zero logic must be implemented correctly for the test case to pass. The carry should be taken from a 9-bit addition, and implementing this incorrectly would result in bugs.
2. Choose one row and explain how its stimulus, observation, expected result, and failure criterion are distinct.
- For row TC-AND-01, the stimulus describes which specific inputs are driven by the testbench, the observation describes the specific output buses we monitor, the expected result describes the output state of the DUT after combinational settling, and the failure criterion describes which output mismatches cause the test to fail.
3. Which requirement was hardest to translate into concrete cases, and how did you resolve the ambiguity?
- The most difficult requirement to translate into concrete cases was REQ-CARRY because it is supported by all of the operation requirements. I resolved the ambiguity by adding cases for each operator that tested the carry logic.
4. What information from this plan should become reusable testbench code in FV-02, and what should remain documentation?
- The test cases should become reusable testbench code, while the scope, assumptions, and completion criteria should remain documentation. More specifically, stimulus application, expected-value prediction, and failure counting should become reusable because they remain common themes throughout the cases.
