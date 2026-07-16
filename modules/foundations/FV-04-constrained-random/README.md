# FV-04: Constrained-random stimulus

## Observable verification problem

Directed tests target known risks, but an 8-bit two-input ALU has far more operand combinations than a short test plan can enumerate. Random stimulus explores more combinations; constraints keep that stimulus legal and purposeful.

## Predict before coding

If `randomize()` cannot satisfy all active constraints, does it throw an exception, stop the simulation, or return a status that your testbench must check?

## Your task

Complete `tb/randomization_lab.sv`:

1. Make `a`, `b`, and `op` random fields.
2. Constrain ordinary generated operations to the five defined selectors.
3. Generate `NUM_ITEMS` legal transactions and validate each result.
4. Use an inline constraint to generate an ADD case whose mathematical sum overflows eight bits.
5. Attempt one deliberately contradictory inline constraint and prove that randomization fails.
6. Run the same seed twice and compare the generated sequence, then run a different seed.

## Run

```powershell
cd "C:\Learning UVM\modules\foundations\FV-04-constrained-random"
.\run.ps1 -Seed 1
```

The starter is expected to fail until its TODOs are completed.
