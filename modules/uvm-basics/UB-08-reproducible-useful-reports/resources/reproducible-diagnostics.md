# Reproducible diagnostics

## Problem

A regression failure may happen only for one random seed. If the report says
only “bad result,” the next run may generate different stimulus and the engineer
cannot tell which transaction caused the mismatch.

## Mental model

Useful evidence answers four different questions:

| Evidence | Question answered |
|---|---|
| Seed | How do I regenerate this randomized run? |
| Transaction context | Which values and identity failed? |
| Transaction recording | When did this transaction begin and end? |
| Final summary | How many checks and failures occurred overall? |

XSim 2025.2 does not implement `$get_initial_random_seed()`. The UB-08 runner
therefore passes the same seed used by `-sv_seed` as `+UB08_SEED=<value>`, and
the supplied audit skeleton retrieves it with `$value$plusargs`. A UVM report
can include that stored value and `convert2string()` output from the failing
transaction. Store the first failure before reporting later failures so
`report_phase` can summarize useful context after run-time activity ends.

Transaction recording is separate from text. Calls such as `accept_tr`,
`begin_tr`, and `end_tr` mark lifecycle events for a recording backend or
debugger. They do not replace a human-readable mismatch message, and a log
message does not create timing relationships in a transaction database.

## Worked example

An unrelated packet-length checker receives packets with `packet_id`,
`declared_length`, and `observed_length`. On the first mismatch it stores the
packet's formatted context. It emits a nonfatal UVM error containing the seed
and packet fields, continues checking later packets, then reports total packets,
total mismatches, and the first failing packet during report phase.

## Invariant

Every detected failure contains enough stable evidence to regenerate the run
and identify the failing transaction, while the final summary accounts for all
completed checks.

## Prediction

Why is a nonfatal mismatch report more useful than an immediate fatal when you
also need a complete end-of-run failure count?
