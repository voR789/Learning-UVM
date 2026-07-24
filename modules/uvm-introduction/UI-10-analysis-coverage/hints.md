# UI-10 progressive hints

Use one level per coaching turn.

## Level 1 — diagnostic question

Which first discrepancy distinguishes publication, connection, sampling, and
coverage-model failures: published count, sample count, or coverage percent?

## Level 2 — concept or invariant

The subscriber samples one completed observation per `write()` call. Separate
coverpoints measure marginals; the cross measures required combinations.

## Level 3 — location

Coverage intent lives in `observation_cg`; sample-field transfer lives in
`write()`; routing lives in `ui10_env::connect_phase`.

## Level 4 — pseudocode

```text
publisher: for every required combination -> ap.write(item)
subscriber.write:
  copy item fields
  coverage.sample once
  increment sample count
environment: port -> analysis_export
test: require 8 publications, 8 samples, 100 percent
```

## Level 5 — minimal repair direction

Repair only the first broken boundary shown by the trace. Do not add duplicate
sampling or relax the coverage threshold.

## Level 6 — reference solution

Available only after an explicit request following a reviewed attempt. Map the
separate response-kind example to UI-10's operation/result requirements without
copying its types or bin names.
