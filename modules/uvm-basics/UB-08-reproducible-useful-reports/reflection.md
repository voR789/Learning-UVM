# UB-08 Reflection

Write concise answers in your own words.

1. Which reported value lets you regenerate the randomized stimulus stream?

- The reported seed helped me regenerate the stimulus stream.

2. Why must the mismatch report include ID, expected value, and observed value
   instead of only incrementing an error count?

- It's useful to include this info so the engineer can see what values is correlated with the error, and what specific actions lead to it.

3. What does transaction recording preserve that a text report does not?

- It preserves transaction and lifetime events that can be useful to extrapolate from.

4. Why is the first failure retained separately from the total mismatch count?

- It's useful to retain it separately because it tells us our first breakpoint, and often, the issue we should look at first.

5. Which command and seed reproduce the injected-fault evidence?

- The run faulty test with seed 1 reproduce the evidence: `.\run.ps1 -SingleTest ub08_fault_test -Seed 1`.
