# Coverage subscriber mental model

## Coverage measures observed intent

Functional coverage answers whether requirement-defined situations were
observed. It does not decide whether the DUT result was correct; that remains a
scoreboard responsibility.

## Why put coverage in a subscriber?

`uvm_subscriber #(T)` supplies an analysis endpoint and requires `write(T)`.
That makes it a natural home for a model that consumes monitor observations.
The monitor stays reusable because adding or changing bins does not change the
publisher.

## Sampling sequence

The embedded covergroup name is also its instance handle in XSim; construct it
in the component constructor and call `sample()` through that name.
Covergroups in this exercise refer to simple fields owned by the subscriber.
For every incoming transaction:

1. Copy transaction fields into the subscriber's sample fields.
2. Call the covergroup instance's `sample()` once.
3. Increment the sample count.

Copying before sampling matters: `sample()` captures the fields' current values.

## Coverpoints versus crosses

Separate coverpoints can prove that every operation occurred somewhere and
that both result classes occurred somewhere. Only the cross proves that every
operation occurred with each result class. Marginal coverage can be complete
while a required combination is absent.

## Coverage is not correctness

One hundred percent coverage can be reached with incorrect DUT results if the
checker never compares them to the specification. Coverage and checking are
complementary evidence.
