# UA-09 reflection

Answer in your own words after the learner and fault runs.

1. Immediately after the external update, why does actual state equal `0x6`
   while desired and mirrored state still equal `0x5`?

- The actual state differs because the mirror state only reacts to changes staged by the predictor, (through the observed bus + predictor, or manual observation + predict())), and the desired state is based on what the testbench set it to. The three states will only match the actual once predict() is called.

2. Why must this module obtain a value from the supplied backdoor before
   calling `predict()`? How does a normal backdoor `mirror()` combine those
   responsibilities?

- The model must obtain a value because in external updates, the RAL has no information about what operations were commited on the register, such that it has to peek through the backdoor in order to observe the new status. A normal backdoor mirror() does both operations by first looking into the backdoor to observe the status of the register, and then updating the internals.

3. What changes immediately after `set(0x3)`, and what must remain unchanged
   until `update()`?

- The set call updates the desired state, actual and mirrored must remain `0x6`, and the frontdoor count must remain unchanged.

4. Why does the final `update()` count as a frontdoor operation even though the
   value was first staged inside RAL?

- The final update call counts as a frontdoor operation because it writes to the register using the main bus, or the frontdoor.

5. Give the exact command that reproduces the predict-without-observation
   failure.

-  .\tests\run-fixture.ps1 -Test ua09_predict_without_observation_test
