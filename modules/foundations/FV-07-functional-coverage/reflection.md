# FV-07 Reflection

Complete these in your own words after coverage closure.

1. What does a covered bin prove, and what does it not prove?
- A covered bin proves that our verification stimulus samples an input from the bin we defined. It does NOT verify that the dut itself is valid.
2. Which initial coverage hole required the most deliberate stimulus, and why?
- The initial coverage hole that required the most deliberate stimulus is the zero bin for the a and b input. It was because none of the sample_transaction calls deliberately used 0 as an a and b input.
3. Why is the operation-by-zero cross more informative than either coverpoint alone?
- The cross is more informative because it tells us which operations combined with the zero flag. If some operations do not use the zero flag, that would tell us one of our operations is not completely tested. Each coverpoint can be independently true, but being mutually true tells us that the operation observes the zero flag. For example, the operation ADD can be covered, and the zero flag can be covered, but cross ADD x zero tells us if the ADD was sampled while zero was asserted, which if not, indicates we missed a key feature/requirement.
4. Where should this coverage model sample transactions in a larger UVM environment?
The coverage model should live in the monitor classes in a larger UVM environement. The monitor "sees" all of the data going into the dut, as well as the data going out, so it is the best place to use covergroups. The sampling occurs once the monitor has a complete transaction from the dut, input and output, so putting the covergroup there covers all of the relevant verification information.
