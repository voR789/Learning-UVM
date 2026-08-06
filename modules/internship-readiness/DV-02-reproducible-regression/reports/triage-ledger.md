# DV-02 triage ledger

This is the only learner-authored explanation artifact. Keep it terse and evidence-based.

## Regression summary

- Source state: branch: main, commit: 790e31f, worktree: clean
- Vivado/XSim version: 2025.2
- Matrix: regression-matrix.csv
- Total / pass / fail: 7 / 1 / 6
- Did every row execute after the first failure?: Yes

## Failure buckets

Create the smallest defensible set of buckets. Add or remove sections as the evidence requires.

### Operation 1 Incorrect

- Exact failing test/seed runs: dv02_arithmetic_test, Seed 1, 17, 31
- First decisive signatures: [DV02_DATA] index=0 op=1 a=0xc9 b=0xc2 expected=0x0b observed=0xcb, applies to all 3 seeds
- Shared evidence: Fails when operation = 1;
- Closest passing contrast: smoke passes with operation 0; arithmetic fails with operation 1. This suggests operation may matter, but test type also differs.
- Root-cause hypothesis: Operation 1 is implemented incorrectly in the DUT
- Evidence that would contradict this bucket: Operation 1 passes for some seed.
- Smallest next experiment: Run arithmetic test with explicit operation 0 and operation 1
- Exact rerun command and result: ./run.ps1 -Test dv02_arithmetic_test -Seed 1 → FAIL, DV02_DATA

### Completion Condition Incorrect

- Exact failing test/seed runs: dv02_completion_test, Seed 1, 17, 31
- First decisive signatures: [DV02_MISSING] issued=8 completed=7 missing=1, applies to all 3 seeds
- Shared evidence: Issued transactions are not being marked as completed
- Closest passing contrast: No same-test passing run in this matrix
- Root-cause hypothesis: DUT is not keeping last 2 bits high.
- Evidence that would contradict this bucket: A request with `[1:0] = 2'b11` is completed correctly.
- Smallest next experiment: Run completion test with known valid transactions
- Exact rerun command and result: ./run.ps1 -Test dv02_completion_test -Seed 1 → FAIL, DV02_MISSING

## One-sentence conclusion

How many failing runs reduced to how many probable root causes, and with what confidence?

- 6 failing runs reduced to 2 probably causes, and we are very confident since each some to the same two reasons.
