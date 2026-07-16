# FV-06 Rubric

| Area | Points | Evidence |
|---|---:|---|
| Concurrent architecture | 20 | Generator, driver, monitor, and scoreboard run as separate responsibilities |
| Synchronization and reset | 25 | Events and deterministic edges prevent pre-reset traffic and sampling races |
| Transaction communication | 20 | Mailboxes transfer independent objects without hidden driver-monitor coupling |
| Checking and termination | 25 | Every item is checked exactly once; timeout and completion are unambiguous |
| Reflection | 10 | Learner explains ownership, blocking, races, and end-of-test behavior |

Passing requires at least 75 points, all counters equal `NUM_ITEMS`, a normal pass, and deliberate-fault evidence.
