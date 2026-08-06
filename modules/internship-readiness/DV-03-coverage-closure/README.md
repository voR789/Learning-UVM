# DV-03 — Close functional coverage without gaming metrics

## Why this matters

Coverage closure is not making a percentage turn green. It is showing that every requirement has either been observed or has a defensible reason it cannot occur. A waived reachable behavior is a verification hole with better formatting.

## Evidence-first novelty check

UA-G1 already proves monitor-driven covergroup sampling and requirement flags. Rebuilding subscribers, agents, or coverage syntax would be repetition. DV-03 gives you the existing passive coverage path and asks for the new judgment: classify holes, create minimal targeted legal stimulus, and reject invalid exclusions.

## Behavioral contract

Read [scenario-spec.md](spec/scenario-spec.md). It defines six required legal scenarios and prohibited combinations. Coverage is sampled only from items published by the supplied sequencer into the passive coverage subscriber.

The starter deliberately covers four of the six required scenarios. Your job is to discover the holes from executable evidence, not from private implementation details.

## Your work

1. Before editing, predict whether every uncovered combination should receive more stimulus.
2. Run seed 1 and inspect the first `DV03_HOLE` reports plus the generated functional-coverage report.
3. Complete the decision rows in [coverage-disposition.md](reports/coverage-disposition.md).
4. Add the smallest legal targeted stimulus in [dv03_target_pkg.sv](tb/dv03_target_pkg.sv).
5. Re-run seed 1 and prove all required scenarios were passively observed.
6. Run the independent baseline-only fault command.

There is no separate reflection or generic evidence summary.

## Commands

Learner run:

```powershell
./run.ps1 -Seed 1
```

Independent baseline-only fault:

```powershell
./run.ps1 -Seed 1 -TargetPackagePath ./tests/baseline_only_pkg.sv
```

Known-good validation oracle:

```powershell
./run.ps1 -Seed 1 -TargetPackagePath ./tests/reference_target_pkg.sv
```

The runner generates a bin-level coverage report under `build/coverage-report/`.

## Constraints

- Do not edit supplied support, test, top, runner, or fixture files.
- Do not directly assign coverage flags or counters.
- Do not remove, ignore, rename, or merge a required reachable scenario.
- Do not publish a specification-prohibited scenario to manufacture a hit.
- Keep the repair inside the targeted sequence and make it minimal.

## Completion criteria

- `observed_required=6/6` and zero UVM errors/fatals.
- Every required scenario was observed through the passive subscriber.
- The baseline-only fixture fails nonzero through `DV03_HOLE`.
- The disposition table cites the specification for every unreachable combination.
- You can distinguish a legal exclusion from metric gaming in one sentence.

## Prediction

If a bin is uncovered, what evidence must you gather before deciding between targeted stimulus and an unreachable-bin disposition?
