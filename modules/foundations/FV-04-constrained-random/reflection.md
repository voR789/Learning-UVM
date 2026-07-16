# FV-04 Reflection

Complete these in your own words after the seed experiments pass.

1. Why must every call to `randomize()` have its return value checked?
- randomize() must be checked because the solution checker may not have any valid solutions. When randomize() is called, a solution checker attempts to create a "solution space" with all of the valid solutions to the constraints, and if that space is empty, randomize() will fail and return 0. Checking that return value ensures that if randomize() fails, we don't end up with unintended values that don't follow the testing intention.
2. What belongs in a reusable class constraint versus an inline constraint?
- Reusable class constraints should hold constraints that apply to the whole of the system (every case of randomization), such as constraining invalid values for variables, or impossible situations. Inline constraints can be used to generate a specific case based on a specific test case, which can be useful when fishing for specific, yet random values.
3. What evidence showed that a seed reproduces a random transaction sequence?
- The first experiment, the repeated randomize() showed that a seed will produce a specific set of random values for a testbench. The seed 1 runs produced the same sequence, while the seed 2 run produced a different random sequence. This is useful for reproducing the random values that caused an error.
4. What should remain directed even after constrained-random stimulus is available?
- Constrained random stimulus is useful for cases in which we want to stress test values across a design's range easily, but directed tests are still useful in the sense we can target specific "edge" values in the design.
