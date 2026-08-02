# UA-07 hints

Reveal one level at a time.

## Level 1: diagnostic question

Which actions must be identical for smoke and stress even though their selected
scenario types differ?

## Level 2: concept

This is a template-method boundary: the base method owns the invariant
lifecycle, and a virtual hook supplies only the intended variation.

## Level 3: location

Inspect `ua07_base_test::run_phase()`, `select_scenario()`, and the inherited
`check_phase()` contract. The derived tests should not need another run phase.

## Level 4: pseudocode

Hold the phase alive, ask the hook for a scenario, reject an absent selection,
execute it, compare independent completion counts, record shared completion,
report the result, and release the phase.

## Level 5: minimal repair direction

Implement only the base-test TODO. Keep all maybe-null handle use behind an
explicit guard, and set the completion flag only after the accounting invariant
passes.

## Level 6: reference solution

Request a complete reference implementation explicitly only after explaining
the current failure and your attempted lifecycle.
