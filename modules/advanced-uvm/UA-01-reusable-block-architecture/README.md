# UA-01: Architect a reusable block-level testbench

## Why this is a checkpoint

This Siemens Advanced UVM unit names an architecture you have already built
and reused:

- UI-05 placed protocol-facing roles in an agent, block-level roles in an
  environment, and active/passive policy in a configuration object.
- UB-04 independently rebuilt the active/passive agent boundary.
- UB-G1 transferred that architecture to a FIFO with real stimulus,
  observation, checking, coverage, and completion.

Rewriting those classes would test transcription, not architecture. UA-01 is
therefore a read-only checkpoint. Factory overrides are genuinely new and
remain learner implementation work in UA-02.

## Read

Read [resources/reusable-block-boundaries.md](resources/reusable-block-boundaries.md).
It gives the Advanced UVM vocabulary for the ownership decisions already proven
in your earlier modules.

For a realistic end-to-end `uvm_config_db` example, continue with
[resources/config-db-worked-example.md](resources/config-db-worked-example.md).
It traces three interface handles and three agent configuration objects from
the HDL top through the test and environment into active/passive agents.

## Observable contract

A reusable block-level testbench should preserve these boundaries:

- A protocol UVC or agent owns its sequencer, driver, monitor, transaction type,
  and protocol-specific configuration.
- The block environment owns UVC instances and block-wide prediction, checking,
  coverage, and coordination.
- The test selects policy and scenario without reaching into drivers or DUT
  signals.
- Passive mode retains observation and removes driving.
- Configuration changes policy without cloning the environment.

Run the supplied checkpoint:

```powershell
cd "C:\Learning UVM\modules\advanced-uvm\UA-01-reusable-block-architecture"
.\run.ps1
```

It replays the existing active/passive architecture evidence and proves that a
passive agent containing a driver is rejected.

## Prediction

If two block environments use the same protocol agent but need different
active/passive modes, which should vary: the agent class, the environment
class, or the configuration supplied to the unchanged classes?

## Completion

No learner code, worksheet, or new reflection is required. Prior executable and
explanation evidence establishes this checkpoint; later Advanced UVM modules
must reuse the boundary without this scaffolding.
