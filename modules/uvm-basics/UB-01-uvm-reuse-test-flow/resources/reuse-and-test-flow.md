# Reuse and test-flow mental model

## Observable problem

A block-level environment may drive a protocol directly. When that block is
instantiated inside a subsystem, another hardware block may already drive the
same interface. Reusing the original driver would create contention, but
discarding the monitor and checker would waste trusted verification logic.

## Mental model

Separate stable mechanism from test policy:

```text
test policy
  selects mode and scenario
       |
       v
environment structure
  agent + checking
       |
       v
agent mechanism
  active:  driver + monitor
  passive:          monitor
```

The test configures before child construction. Components are created during
`build_phase`, endpoints are wired during `connect_phase`, timed behavior occurs
during `run_phase`, and the verdict is reduced only after required work finishes.

## Worked example: UART receiver

At UART block level, an active agent drives serial bits and monitors decoded
frames. In a SoC test, the processor's UART transmitter drives those bits, so
the receiver agent becomes passive. Its serial monitor, frame transactions,
coverage, and checker remain useful. The SoC test changes configuration and
scenario coordination; it does not rewrite frame observation.

## Governing invariant

Exactly one owner drives an interface, while passive observation and checking
remain reusable in both active and passive contexts. Configuration must be
available before the conditional component is built.

## Prediction

If a subsystem test leaves the reused agent active while another component
already drives the pins, what observable failure could occur even when both
drivers individually generate legal values?

- s
