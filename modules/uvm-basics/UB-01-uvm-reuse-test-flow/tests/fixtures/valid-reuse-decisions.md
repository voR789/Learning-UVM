# UB-01 reuse decisions

## Block-level context

- Agent mode: Active because this environment supplies protocol stimulus.
- Signal-driving owner: The agent driver is the only pin-driving owner.
- Observation/checking path retained: Monitor, analysis path, and checker remain.
- Test-specific policy: The test selects mode and block scenarios.

## Subsystem context

- Agent mode: Passive because subsystem RTL supplies interface activity.
- Signal-driving owner: The connected subsystem RTL owns the pins; this agent does not.
- Observation/checking path retained: Monitor, analysis path, and checker remain.
- Test-specific policy: The subsystem test selects passive mode and coordinated scenarios.

## Test-flow ownership

| Decision | Owner and reason |
|---|---|
| Configuration before construction | Test, because policy must precede child build. |
| Structural construction | Environment and agent build phases own persistent children. |
| Transaction connections | Component connect phases own topology wiring. |
| Timed execution and termination | Run phase owns timed work and objection control. |

## Reuse boundary

Reuse the agent's observation and checking mechanism; let the test replace mode
and scenario policy for each integration context.
