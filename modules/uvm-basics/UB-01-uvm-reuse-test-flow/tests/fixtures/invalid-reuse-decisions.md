# UB-01 reuse decisions

## Block-level context

- Agent mode: Active.
- Signal-driving owner: TODO
- Observation/checking path retained: Monitor.
- Test-specific policy: Test.

## Subsystem context

- Agent mode: Passive.
- Signal-driving owner: TODO
- Observation/checking path retained: Monitor.
- Test-specific policy: Test.

## Test-flow ownership

| Decision | Owner and reason |
|---|---|
| Configuration before construction | Test. |
| Structural construction | Components. |
| Transaction connections | Components. |
| Timed execution and termination | Run phase. |

## Reuse boundary

TODO
