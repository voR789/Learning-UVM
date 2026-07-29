# UI-G1 reflection

1. Why is the monitor observation authoritative rather than the sequence item?

- The monitor observation is authorative because it reads from the virtual interface that actually goes into the DUT. If we used the sequence item, some misaligned pins or errors in our driving logic would pass, while the DUT recieves faulty information.

2. How did you ensure the monitor sampled the updated counter value?

- The monitor ensured the updated counter value after a short delay in order to let non-blocking assignments pass. (In the Xsim scheduler)

3. Which independent rule exposed the faulty decrement DUT?

- The rule that after a subtraction operation, the counter should decrease by 1 after sequential updates. In the testbench, we found a mismatch where the count was 6, when it should be 4. This indicates that the DUT incemented instead of subtracting.

4. What do the four equal transaction counts prove, and what evidence remains
   separate?

- The four equal transaction counts prove that the amount of packets processed by each component is the same. It does not prove for sure that no packets are dropped or made up, and the evidence for errors and coverage remains separate, as independent things that are proven other ways.

5. Which earlier module concept was hardest to reuse without scaffolding?

- Honestly it was all pretty easy, considering the simplicity of the DUT, and the only time I had to check is for syntax. For the next one, give a more abstract probelm, and less total guidance. However, don't focus on the stimulus as much as that part is pretty menial. (Like verification plan, making the stimulus..)
