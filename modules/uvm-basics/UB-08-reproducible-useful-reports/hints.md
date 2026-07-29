# UB-08 Hints

## Level 1 — Diagnostic question

Which four pieces of evidence would let another engineer reproduce the run,
identify the failing observation, and understand the overall result?

## Level 2 — Invariant

Every mismatch must carry seed plus live transaction context, and report phase
must account for every completed check without discarding the first failure.

## Level 3 — Location

Per-transaction accounting belongs in `ub08_audit::write`; aggregate evidence
belongs in `ub08_audit::report_phase`.

## Level 4 — Reduced pseudocode

```text
write(observation):
  count the check
  when values differ:
    count mismatch
    preserve first failure once
    report seed plus formatted observation

report phase:
  choose "none" or stored first failure
  report seed, counts, and first-failure context
```

## Level 5 — Minimal repair direction

Use the initial-seed system function and the observation's formatting method in
the mismatch report. Keep mismatch severity nonfatal so report phase still runs.

## Level 6 — Reference direction

Compare the resource's unrelated packet example with the supplied observation
fields. Do not change the source, fault injection, tests, or runner contract.
