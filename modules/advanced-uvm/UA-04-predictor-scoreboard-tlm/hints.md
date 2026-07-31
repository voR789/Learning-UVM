# UA-04 hints

## Level 1 — diagnostic question

For one command ID, which component creates the expected value, and which
component is allowed to compare it with the actual value?

## Level 2 — concept

Prediction transforms observed input into expected output. Checking pairs that
expected output with independent observation.

## Level 3 — location

Inspect `ua04_predictor::write()` and `ua04_scoreboard::run_phase()` only.

## Level 4 — pseudocode

Predictor: create, copy identity, calculate, publish, count. Scoreboard: get from
expected FIFO, get from actual FIFO, compare identity/value, report, count.

## Level 5 — minimal repair direction

Use the existing analysis port and FIFO handles. Do not add a direct predictor
call from the scoreboard or source.

## Level 6 — reference direction

Ask for a direct code review or minimal patch after attempting both regions.
