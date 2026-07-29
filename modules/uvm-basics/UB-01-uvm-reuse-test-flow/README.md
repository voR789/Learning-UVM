# UB-01: UVM reuse and test flow

## Why this matters

UI-G1 proved that you can assemble a complete UVM environment. The next step is
to decide which parts remain stable when verification moves from an isolated
block to a larger subsystem. Reuse is not copying every class; it is preserving
responsibility boundaries while tests select configuration and scenarios.

## Observable contract

The supplied example runs the same agent in two contexts:

- an active block test contains a driver and a monitor;
- a passive subsystem test contains the same monitor but no driver;
- the test chooses the mode before the environment is built;
- the environment and agent own structure;
- run-phase work occurs only after construction and connection;
- the final verdict must agree with the selected topology.

There is no new RTL DUT in this module. The observable behavior is the UVM
topology and phase-controlled test flow.

## Reading checkpoint

1. Read [resources/reuse-and-test-flow.md](resources/reuse-and-test-flow.md).
2. Predict both topologies, then run the supplied example.

The learner already identified the one-driver ownership invariant and the
active-to-passive reuse decision. The original decision worksheet and reflection
remain available as optional notes, but they are not completion requirements.

## Run

```powershell
cd "C:\Learning UVM\modules\uvm-basics\UB-01-uvm-reuse-test-flow"
.\run.ps1
```

The runner executes active and passive tests at seed 1.

## Constraints

- Do not add a driver to the passive context.
- Do not move monitor or checking ownership into a sequence.
- Treat scenario choice as test policy, not agent structure.
- Expected time: about 45 minutes.

## Completion

This reading checkpoint is complete from the passing XSim examples and the
learner's correct explanation of driver ownership. Later implementation reuse
is still required before this concept can be considered mastered.

## Prediction before running

When the agent changes from active to passive, which component should disappear,
and which observation path must remain unchanged?
