# FV-02: Directed self-checking ALU testbench

## Verification problem

A waveform can show what the DUT did, but it does not decide whether the behavior matches the specification. In this module, translate the FV-01 plan into an executable testbench that applies stimulus, predicts every output, reports mismatches, and terminates with an unambiguous result.

## Prediction before coding

If one expected value is deliberately made incorrect, what must the testbench print and how must the runner exit?

## Your task

Complete `tb/alu_tb.sv`. Implement the reusable checking task, then invoke it for the planned directed cases from FV-01. Check `result`, `carry`, `zero`, and `invalid` for every case. Wait a nonzero delay after driving inputs before sampling outputs.

Do not inspect the DUT implementation to derive expected values; use the specification and your verification plan.

## Run

```powershell
cd "C:\Learning UVM\modules\foundations\FV-02-directed-alu-testbench"
.\run.ps1
```

The untouched starter is expected to fail. Completion requires `TEST_RESULT: PASS`, a zero runner exit code, and proof that a deliberately incorrect expectation produces a nonzero result.
