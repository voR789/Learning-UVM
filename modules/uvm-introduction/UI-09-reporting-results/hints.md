# UI-09 progressive hints

Use one level per coaching turn.

## Level 1 — diagnostic question

Which invariant failed first: the reporter's functional counts, the global
severity counts, or the enabled/filtered verbosity checks?

## Level 2 — concept or invariant

Severity records correctness impact; verbosity filters informational detail.
The final verdict must combine functional work with accumulated severities.

## Level 3 — location

Report production belongs in `ui09_reporter::evaluate`. Verbosity configuration
belongs after construction. Verdict reduction belongs in
`ui09_test::run_phase`.

## Level 4 — pseudocode

```text
attempt high-detail info
if exact: count match; low info
else if recoverable: count retry; warning
else: count mismatch; error

after work:
  read global warning/error/fatal counts
  verify local counts and verbosity policy
  only then print PASS
```

## Level 5 — minimal repair direction

Change only the classification branch, count query, verbosity setting, or
verdict condition identified by the first failed invariant. Do not relax the
expected counts.

## Level 6 — reference solution

Available only after an explicit request following a reviewed attempt. Use the
parser example to map severity decisions, but retain UI-09's distinct data,
IDs, counts, and final policy.
