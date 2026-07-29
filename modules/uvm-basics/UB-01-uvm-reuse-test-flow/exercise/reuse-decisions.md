# UB-01 reuse decisions

Replace each `TODO` with a concise decision and justification. Do not describe
individual syntax statements; explain ownership and reuse boundaries.

## Block-level context

- Agent mode: The agent should be active because it is the only agent on the input side of the design.
- Signal-driving owner: The driver within the agent owns and drives the signals.
- Observation/checking path retained: Owned by the monitor, scoreboard, and coverage subscriber.
- Test-specific policy: Test should configure an active agent, and connect signals to the active driver.

## Subsystem context

- Agent mode: The agent should be passive because an external source is already driving the inputs.
- Signal-driving owner: The driver from the susbsystem.
- Observation/checking path retained: Owned by the monitor, scoreboard, and coverage subscriber.
- Test-specific policy: Test should configure agent as passive, and connect signals to the higher level driver.

## Test-flow ownership

| Decision                          | Owner and reason |
| --------------------------------- | ---------------- |
| Configuration before construction | TODO             |
| Structural construction           | TODO             |
| Transaction connections           | TODO             |
| Timed execution and termination   | TODO             |

## Reuse boundary

TODO
