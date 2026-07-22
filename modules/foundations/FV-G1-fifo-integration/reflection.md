# FV-G1 Reflection

Complete these in your own words after producing executable defect evidence.

1. Which FIFO requirement did the first seeded defect violate, and what was the earliest observable evidence?
- The FIFO requirement that was violated was `FIFO-STATE-003`, and the earliest observable evidence was at 146000 ps, from the `run_empty_full` test, in which the model and DUT had a mismatch for the value of `full` (Expected = `0`, Actual = `1`).
2. How did your environment separate requested operations, accepted operations, passive observation, prediction, and checking?
- The verification environment seperated each of these using individual components (monitor, predictor, scoreboard) linked with mailboxes from one component to another. This seperation of our logic kept the testbench clean and reusable. Specifically, for request and accepted operations, the predictor runs a with the `wr_accept` and `rd_accept` formulas to decide to accept or reject requests.
3. Which timing decision prevented a race between DUT nonblocking updates and monitor sampling?
-  At the DUT boundary, the monitor had a race condition with the DUT because the DUT updated it's outputs on the clock edge, with it's outputs being registered. To avoid this, the monitor waited for the sequential updates to settle by delaying 1ns.
4. Which coverage hole required purposeful stimulus, and why could coverage alone not prove FIFO correctness?
-  The coverage hole that required purposeful stimulus was `sim_occ`, which covered the cross between read and write requests at every occupancy level. To fix this, I introduced a test case that tested read/write's at every occupancy. Coverage alone cannot prove FIFO correctness because it only validates that our model experiences certain combinations of inputs and outputs, and not that it produces the right ones.
5. How would you map this non-UVM architecture onto UVM components and transaction flow?
- This testbench maps very well to UVM architecture, as all of the components have similar functions as UVM components, and because each component is a seperate, abstractable task, it would be very easy to translate each into a UVM component. 
