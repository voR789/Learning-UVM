# UA-07 reflection

Answer in your own words after the regression and fault run.

1. Why should smoke and stress inherit the same `run_phase()` instead of each
   owning a copy?

- The derived test cases, smoke and stress, should inherit  the same `run_phase()` because it can be convoluted creating a different run phase for each test. For tests where the only difference is the scenario, it is much more efficient to use a singular base class `run_phase()`.

2. What prevents a scenario with zero verified work—or a disagreement between
   scenario and driver counts—from becoming a false pass?

- The base class uses a checker to verify that a faulty scenario does not pass when it has issues on the component side, scenario.verified cannot be zero, and verified must equal driven.

3. Why does the bypass fixture fail even though its scenario receives correct
   responses?

- The bypass fixture fails because the base class does not emit the finished flag, which runs separately in the check phase. The dervied class bypasses the base class's completion contract.

4. Give the exact test name and seed for one stress row, and explain why both
   values are needed to reproduce it.

- .\run.ps1 -Test ua07_stress_test -Seed 1. Both test name and seed are needed fields in order to pick the specific test from the derived classes, and to pick the same randomization values.
