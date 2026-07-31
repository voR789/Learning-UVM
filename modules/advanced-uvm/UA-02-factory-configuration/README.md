# UA-02: Factory overrides and configuration

## Why this is implementation work

You have repeatedly registered and factory-created UVM objects and components.
You also used configuration objects and `uvm_config_db`. What you have not yet
implemented is factory replacement:

- replace every construction of a registered base type;
- replace only one hierarchy instance of that type;
- vary instance data independently from the selected implementation.

That distinction is the new behavioral invariant. It cannot be established by
another registration or config-db transcription exercise.

## Learn first

Read [resources/factory-versus-configuration.md](resources/factory-versus-configuration.md)
before editing. The worked example uses different class names from the learner
exercise.

## Supplied environment

`ua02_env` factory-creates two components through the same
`ua02_base_policy` type:

```text
uvm_test_top.env.left
uvm_test_top.env.right
```

Each component retrieves its own `ua02_policy_cfg`. The unchanged environment
does not know which derived policy the factory may produce.

## Your work

Complete the two behavioral TODO regions in `tb/ua02_pkg.sv`:

1. In `ua02_type_override_test`, install one type override so both policy
   instances become `ua02_add_policy`.
2. In `ua02_instance_override_test`, install one instance override so only
   `uvm_test_top.env.right` becomes `ua02_xor_policy`.

The distinct left/right configuration objects and the environment are supplied.
Do not directly construct derived policies or branch on the selected test in
the environment.

Run each test:

```powershell
cd "C:\Learning UVM\modules\advanced-uvm\UA-02-factory-configuration"
.\run.ps1 -Test ua02_type_override_test
.\run.ps1 -Test ua02_instance_override_test
```

The starter compiles and intentionally fails because no override is installed.

## Fault check

Run the seeded wrong-instance-path fixture directly:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\tests\run-fixture.ps1 -Test ua02_wrong_path_test
```

Expected result: a nonzero exit and `UA02_OVERRIDE`. The fixture installs an
override at a nonmatching future path, so `right` remains the base policy
instead of becoming the XOR policy.

To run the full fixture suite—both valid cases, the wrong-path fault, and the
unfinished learner starter—use:

```powershell
.\tests\verify-fixtures.ps1
```

## Prediction

If a type override is installed for `ua02_base_policy`, but `env.right` is
constructed with `new()` instead of `type_id::create()`, which implementation
will `env.right` actually contain?

## Constraints

- Keep `ua02_env` unchanged.
- Keep factory construction at both replacement points.
- Use a type override for the global case and an instance override for the
  one-path case.
- Use configuration only for per-instance operand data, not to select a class
  with an `if` statement.
- Expected learner time: 45 to 75 minutes.

## Completion

Both learner tests pass at seed 1, the wrong-path fixture fails through
`UA02_OVERRIDE`, and the reflection explains replacement scope and
configuration ownership.
