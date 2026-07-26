# UI-G1: Programmable-counter UVM integration gate

This is the first UVM integration gate. It intentionally repeats earlier
implementation work with less scaffolding: hierarchy, factory construction,
sequence composition, explicit handshakes, interface access, passive analysis
publication, scoreboard prediction, coverage subscription, reporting, and
termination.

## Architecture contract

```text
test -> scenario -> sequencer -> driver -> counter_if -> DUT
                                         |
DUT -> counter_if -> passive monitor -> analysis_port
                                      ├──> scoreboard
                                      └──> coverage subscriber
```

The driver owns pin activity. The monitor alone creates authoritative observed
transactions. The scoreboard predicts from the specification, not DUT
implementation. Coverage measures observed commands/results.

## Required scenario

Execute these nine observed operations. Reset is an explicit sequence item so
the monitor and scoreboard prove that it clears a known nonzero sentinel.

| index | operation | load value | expected count |
|---:|---|---:|---:|
| 0 | LOAD | 255 | 255 |
| 1 | RESET | 0 | 0 |
| 2 | LOAD | 5 | 5 |
| 3 | INC | 0 | 6 |
| 4 | INC | 0 | 7 |
| 5 | DEC | 0 | 6 |
| 6 | CLEAR | 0 | 0 |
| 7 | DEC | 0 | 255 |
| 8 | INC | 0 | 0 |

## Your work

1. Complete [plan/verification-plan.md](plan/verification-plan.md) before code.
2. Implement the TODO regions in [tb/ui_g1_pkg.sv](tb/ui_g1_pkg.sv).
3. Run the deterministic seed.
4. Complete [reflection.md](reflection.md).

This gate is expected to take multiple hours. Work one boundary at a time:
stimulus, driver, monitor, scoreboard, coverage, environment, then verdict.

## Prediction

If the driver sends the correct nine operations but the monitor samples before
the DUT's nonblocking update becomes visible, which component receives stale
data and what symptom should the scoreboard report?

## Run

```powershell
cd "C:\Learning UVM\modules\uvm-introduction\UI-G1-programmable-counter-integration"
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\run.ps1
```

Pass requires nine driven, monitored, checked, and sampled transactions,
100.00% coverage, zero UVM errors/fatals, exact `INTEGRATION_TRACE`, and
`TEST_RESULT: PASS`. The faulty decrement DUT must fail by scoreboard mismatch.
