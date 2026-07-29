# UB-04: Build and connect an agent

## Why this matters

An agent is reusable only when its structural ownership follows configuration.
Block-level tests may drive an interface; subsystem-level reuse may observe the
same interface without creating a second pin-driving owner.

## Observable contract

The supplied tests configure the same agent in active and passive modes:

- the monitor exists in both modes;
- the driver and sequencer exist only in active mode;
- the active driver's request port connects to the sequencer export;
- passive mode creates no driving path.

There is no RTL DUT and no verification-plan assignment. Tests and topology
checks are supplied.

## Your work

Implement the behavioral TODOs in [tb/ub04_pkg.sv](tb/ub04_pkg.sv). Class names,
handles, and method signatures are supplied. You own registration, constructors,
mode-dependent construction, and connection behavior.

Run:

```powershell
cd "C:\Learning UVM\modules\uvm-basics\UB-04-build-connect-agent"
.\run.ps1
```

The command runs active and passive tests at seed 1. Completion requires both
modes to pass; exact trace wording and hierarchy strings are not graded.

## Constraints

- Use factory creation.
- Preserve exactly one monitor in both modes.
- Never create or connect the driving pair in passive mode.
- Expected time: about 75 minutes.

## Prediction

If the agent is passive, which `connect_phase` operation becomes invalid, and
what topology decision made it invalid?
