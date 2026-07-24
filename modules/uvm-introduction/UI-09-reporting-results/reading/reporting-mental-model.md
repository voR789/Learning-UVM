# Reporting and verdict mental model

## Severity describes correctness impact

- `UVM_INFO`: normal progress or diagnostic detail.
- `UVM_WARNING`: abnormal but intentionally recoverable behavior.
- `UVM_ERROR`: the test observed an incorrect result but simulation may
  continue to collect evidence.
- `UVM_FATAL`: continuing would be meaningless or unsafe.

Choose severity from the verification contract, not from how visually loud you
want the message to be.

## Verbosity filters informational detail

The verbosity argument belongs to informational reports. A component-level
verbosity setting can reveal or hide detailed info without changing the source
that produces reports. `UVM_LOW` should carry concise useful progress;
`UVM_HIGH` can carry per-case diagnostic detail.

Verbosity is not a correctness escape hatch. Errors and fatals remain part of
the final result.

## IDs make reports controllable

A stable ID such as `UI09_MATCH`, `UI09_RETRY`, or `UI09_MISMATCH` identifies a
message category. IDs let larger environments configure or summarize related
reports without parsing prose.

## End-of-test is an evidence reduction

Component counters answer “what functional work happened?” The UVM report
server answers “what severities were reported globally?” A credible verdict
requires both:

```text
expected functional counts
AND zero unexpected mismatches
AND zero UVM errors
AND zero UVM fatals
→ print PASS and drop objection
```

Printing PASS is the last consequence, not the source of truth.
