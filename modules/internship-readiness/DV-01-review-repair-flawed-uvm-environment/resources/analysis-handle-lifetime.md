# Analysis handle lifetime

## Observable problem

A monitor log can show the right value at publication while a later scoreboard sees a different value. That discrepancy can occur without a race in the RTL: SystemVerilog class variables are handles, and UVM analysis paths transport those handles.

## Mental model

Think of `analysis_port.write(item)` as handing consumers an address, not taking a photograph. If the publisher later changes the object at that address, a consumer that queued the handle can observe the changed fields.

Governing invariant: **once an observation is published, its identity and checked fields must remain stable for every downstream consumer that may retain the handle.**

Common safe ownership policies include creating a fresh transaction per completed observation or publishing a correctly copied snapshot. The policy belongs at the boundary that owns observation creation; a checker should not guess which earlier state was intended.

## Separate worked example

Suppose a temperature sampler publishes `sample.celsius = 20`, then reuses the same object and assigns `25`. A subscriber that stores both handles may later read `25` twice. Creating a new sample for each measurement preserves `20, 25`.

Do not infer that every receiver must clone every object. Decide which component owns snapshot stability, document that contract, and keep the repair local to the violating boundary.

## Prediction

Two queued handles compare equal with `==`. What additional field evidence would distinguish “two legitimate observations happen to match” from “one mutable object was queued twice”?

## References

- IEEE 1800 SystemVerilog class variables have reference (handle) semantics.
- IEEE 1800.2 UVM analysis ports broadcast transaction object handles to subscribers.
