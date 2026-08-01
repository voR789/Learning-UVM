# UA-05 hints

## Level 1 — diagnostic question

Does a blocking child `start()` return before or after that child finishes?

## Level 2 — concept

Two blocking calls are concurrent only when they execute in separate processes.

## Level 3 — location

Only `ua05_parallel_sequence::body()` is learner-owned implementation work.

## Level 4 — pseudocode

Launch one child start per concurrent branch, then wait for all branches.

## Level 5 — minimal repair direction

Use the two supplied child handles, the supplied `m_sequencer`, and this parent
sequence as context.

## Level 6 — reference direction

Ask for a direct syntax example after attempting the single TODO.
