# UA-G1 reflection

Answer in your own words after both runs.

1. Why may the scenario use RAL read responses to decide when to continue, while
   the scoreboard must not use those responses as its correctness oracle?

   - The scenario may use the actual response returned by its frontdoor RAL read to decide control flow, such as whether STATUS.done is high. The scoreboard must not use that response as its expected-value source; it independently predicts expected behavior from monitored APB traffic and the specification.
2. Which single observation feeds the RAL predictor, scoreboard, and coverage,
   and what transfer-completion condition creates it?

   - The monitor's analysis broadcast port connects all of these to the observed inputs to the DUT. The transfer-completion condition is the accepted APB operation, which is: `vif.psel && vif.penable && vif.pready`
3. What state must the scoreboard reconstruct to predict `RESULT`, and why is
   the RAL mirror not an independent expected-value source?

   - The state the scoreboard must reconstruct is the gain register, as it is used to calculate the result, and also the enable register, as that allows for the operation to proceed (and the DATA register). The RAL mirror is not an independent expected-value source because it only mirrors the register boundary, and doesn't have an independent model of the intended internals.
4. Why does waiting for two scoreboard-checked results provide stronger
   termination evidence than waiting a fixed number of cycles?

   - Waiting for the scoreboard-checked results provides stronger termination evidence because the stimulus we take is deterministic, as we only check for results twice. It makes the code more efficient, as well as real. A fixed cycle delay can miss scoreboard evidence because we don't know how long the DUT takes for the done signal to be propogated, so it is undeterministic.
5. Give the exact learner and fault commands, including the reproducing seed.

    -`.\run.ps1 -Seed 1`, and `powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\tests\run-fixture.ps1 -Test ua_g1_fault_test -Seed 1`
