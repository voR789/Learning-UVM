# Passive analysis broadcast

## Problem

Driving code knows what it attempted, but reusable checking and coverage need
an independent record of what appeared at the DUT interface. Multiple consumers
should receive that observation without controlling the monitor.

## Mental model

A monitor is a passive translator:

```text
DUT interface -> monitor -> observed transaction -> analysis subscribers
```

It never drives pins and never predicts the correct result. Its analysis port
broadcasts each observation to every connected consumer. A scoreboard can
check meaning while a coverage subscriber measures intent; neither consumer
owns the monitor's sampling loop.

Analysis `write()` passes an object handle. Consumers called during the same
broadcast can therefore refer to the same object. A monitor must not mutate a
published object while any consumer might retain it. Create a fresh transaction
for each publication, or deliberately clone before retaining asynchronous data.
Subscribers should treat received observations as read-only.

## Worked example

A passive interrupt monitor observes `source`, `asserted`, and a timestamp. It
publishes one transaction when an interrupt handshake completes. A latency
checker stores a private copy, while a coverage subscriber immediately samples
the source. The monitor then creates a new transaction for the next interrupt;
it does not rewrite the already-published object.

## Invariant

Each completed interface event produces one stable observed transaction, and
analysis consumers may inspect it without influencing driving or one another.

## Prediction

If a monitor publishes one object and then rewrites that same object for the
next event, what value can a subscriber that retained the original handle see
later?

- If a monitor publishes one object, and then rewrites that same object, the subscriber can see the new data because it retains the object handle. However, this can cause issues, so it's best practice to copy the data before using it.
