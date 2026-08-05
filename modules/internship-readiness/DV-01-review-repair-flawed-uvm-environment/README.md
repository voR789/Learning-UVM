# DV-01 — Review and repair a flawed UVM environment

## Why this matters

Real DV failures often appear in the checker even when the checker is correct. Your job is to build an evidence chain, identify the component that first violates its contract, and change only what restores that contract.

## Evidence-first novelty check

UA-G1 already proves APB observation, RAL prediction, independent scoreboarding, coverage, and drain-based lifecycle control. Rebuilding those mechanisms would be repetition. The new invariant is narrower: **an analysis write transfers an object handle, not an immutable value snapshot; a publisher must preserve the published observation's identity and state for downstream consumers.**

This is an implementation assessment because the supplied failure crosses a publisher/FIFO/checker boundary. A reading-only answer would not prove that you can localize the defect, resist weakening the checker, and validate a minimal repair.

## Supplied environment contract

The environment publishes two completed observations in order:

| Observation | `result` |
|---|---:|
| 0 | `3` |
| 1 | `7` |

The scoreboard independently expects `3`, then `7`. It receives observations through a `uvm_tlm_analysis_fifo` and compares in arrival order. A correct environment reports `checked=2`, `mismatches=0`, and no UVM errors or fatals.

The starter is intentionally flawed. The location and repair are assessment work; do not assume the component reporting the mismatch caused it.

## Your task

1. Before editing, predict whether the first bad evidence will appear at stimulus, publication, FIFO retrieval, or comparison.
2. Run seed 1 and save the smallest useful evidence: first error, values, and object identity.
3. Write a one-sentence root-cause hypothesis in `plan/debug-plan.md`.
4. Make the smallest correct repair in `tb/dv01_pkg.sv`. Do not weaken, bypass, or special-case the scoreboard.
5. Re-run seed 1, then run the direct fault command.
6. Complete the evidence summary and reflection in your own words.

Work on one issue at a time. During mentoring, expect one concise diagnostic question rather than a list of repairs.

Read [Analysis handle lifetime](resources/analysis-handle-lifetime.md) before editing. It teaches the governing semantics with a separate example but does not identify the starter's fault location.

## Commands

From this directory:

```powershell
./run.ps1 -Seed 1
```

Direct known-bad fault (must return nonzero and report `DV01_MISMATCH`):

```powershell
./run.ps1 -Seed 1 -PackagePath ./tests/reused_handle_fault_pkg.sv
```

The runner prints module ID, test, seed, result, and UVM counts. Generated simulator artifacts stay under `.xsim`.

## Constraints

- Preserve the independent expected sequence `3, 7`.
- Do not suppress or downgrade `DV01_MISMATCH`.
- Do not replace the FIFO or add timing delays to hide the failure.
- Change only learner-owned files.
- Use seed 1 for required evidence.

## Completion criteria

- Default command passes with `checked=2`, `mismatches=0`, and zero UVM errors/fatals.
- Direct fault command fails nonzero for the intended mismatch.
- Your evidence shows where identity or state diverged from the contract.
- Your repair is minimal and your explanation distinguishes symptom from root cause.

## Pre-edit prediction

If a producer publishes an object and later changes that same object, what will a FIFO consumer observe: the fields at publication time or the fields when it retrieves the handle?
