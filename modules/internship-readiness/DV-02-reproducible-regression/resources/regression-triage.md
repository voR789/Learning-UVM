# Regression triage: from red runs to root-cause buckets

## Observable problem

A regression produces several failures. Some are repeated manifestations of one defect; others only look similar because the same scoreboard reports them.

## Mental model

A run is identified by its **test, seed, configuration, source state, and tool version**. A failure signature is the earliest observation that violates a contract, with enough field and timing context to compare runs.

A bucket is a root-cause hypothesis, not a folder named after an error string. Two failures belong together only when shared evidence supports one causal explanation and no observed evidence contradicts it.

Governing invariant: **every triage conclusion must remain traceable to an exactly reproducible run and a falsifiable shared-cause hypothesis.**

## Separate example

Three packet tests report `PKT_BAD_DATA`; two involve only odd-length packets while the third involves reset. The shared report ID is weak evidence. Re-running odd/even lengths may support one padding bucket, while a reset-only experiment may establish a separate initialization bucket.

## Useful comparisons

- Same test, different seeds: does input shape predict failure?
- Different tests, same invariant: does one cause cross scenario boundaries?
- Same seed after rerun: is the result deterministic?
- First decisive signature versus final summary: where did the contract first break?
- Passing neighbors: what changed between the closest pass and fail?

## Prediction

If two failures have different final summaries but share the same first bad transaction field and condition, should they begin in one bucket or two?
