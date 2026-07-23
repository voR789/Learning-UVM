# UI-05: Compose a reusable UVM environment

## Challenge

UI-04 proved parent-child mechanics. UI-05 applies them to a realistic
verification structure and moves faster: one environment must support both
active and passive use without copying the environment class.

Required active topology:

```text
uvm_test_top
└── env
    ├── agent
    │   ├── driver
    │   └── monitor
    ├── predictor
    └── scoreboard
```

Required passive topology:

```text
uvm_test_top
└── env
    ├── agent
    │   └── monitor
    ├── predictor
    └── scoreboard
```

## Architectural contract

- `ui05_agent` owns protocol-facing roles.
- Its monitor always exists because both active and passive agents observe.
- Its driver exists only when `is_active` is true.
- `ui05_env` owns the agent plus testbench-wide predictor and scoreboard.
- `ui05_env_config` carries the active/passive structural choice.
- Active and passive tests configure and reuse the same environment class.
- This module checks structure only; UI-06 adds transaction connections.

## Task

Complete the TODOs in `tb/ui05_pkg.sv`:

1. Build the agent's unconditional and conditional children.
2. Build the environment's four owned roles.
3. Propagate the environment configuration into the agent before its build
   phase executes.

Do not change the topology checker or create separate active/passive
environment classes.

## Run both configurations

```powershell
cd "C:\Learning UVM\modules\uvm-introduction\UI-05-reusable-environment"
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\run.ps1 -Test ui05_active_test
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\run.ps1 -Test ui05_passive_test
```

The starter compiles but fails because required structure is absent.

## Prediction

Why must the monitor exist in both configurations while the driver must not
exist in passive mode?

## Completion

Both tests must pass at seed 1, the always-driver fault must fail passive mode,
and the reflection must pass semantic review. Expected time is 60–75 minutes.
