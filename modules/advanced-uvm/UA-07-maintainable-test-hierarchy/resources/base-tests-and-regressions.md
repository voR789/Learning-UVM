# Base tests and regression rows

## Observable problem

When every derived test copies its own `run_phase()`, the family slowly stops
sharing one definition of success. One test may drop its objection too early,
another may forget an accounting check, and a third may print pass despite UVM
errors. All three can appear to run the same environment while enforcing
different completion contracts.

## Mental model

Separate **policy** from **mechanism**:

- A derived test supplies policy: which scenario should run?
- The base test supplies mechanism: how is the scenario executed, kept alive,
  checked, and declared complete?
- The regression runner supplies selection: which registered test and seed form
  this run?

The governing invariant is:

> A derived test may vary the scenario hook, but every derived test must pass
> through the same base-owned execution and completion path.

This is a template-method shape. The base method owns the stable algorithm and
calls one virtual hook for the intentional variation.

## Separate worked example

Suppose a memory environment has supplied `short_accesses` and
`contention_accesses` sequences. A `memory_base_test` owns the complete
`run_phase`: it raises an objection, calls a virtual `choose_sequence()` hook,
rejects a null result, starts the sequence, checks shared counters, records
completion, and drops the objection.

`memory_short_test` and `memory_contention_test` override only
`choose_sequence()`. They do not each write another `run_phase()`. A regression
can then select:

| Test | Seed | Intent |
|---|---:|---|
| `memory_short_test` | 1 | fast deterministic sanity |
| `memory_contention_test` | 1 | randomized contention |
| `memory_contention_test` | 29 | another randomized trajectory |

The test name selects intent; the seed reproduces the random trajectory within
that intent. Neither belongs hard-coded inside the environment.

## Safe null handling in XSim

Reject a null scenario with explicit `if` control flow before any method call
through that handle. XSim 2025.2 must not be asked to evaluate a maybe-null
method call hidden in a ternary expression.

## Regression taxonomy checkpoint

For this module:

- **smoke** is one fast deterministic structural check;
- **stress** repeats a broader randomized scenario at multiple seeds;
- the **fault fixture** validates the test-family contract and is not a normal
  regression row.

Larger projects may add feature, error-injection, long-running, or nightly
groups. Those labels are useful only when they communicate distinct intent;
duplicating the same test under many labels is not additional verification.

## Prediction

If a derived test produces correct driver responses but bypasses the
base-owned lifecycle, which result is more trustworthy: the local response
check or the violated family completion contract? Explain why before editing.
