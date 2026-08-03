# UA-08: Register-model setup

## Why this is implementation work

UA-04 established a separate predictor and checker, but it did not model
memory-mapped registers or translate abstract register operations into bus
transactions. UA-08 adds that genuinely new path.

Repeated bus-agent, driver, adapter, test-lifecycle, and checking mechanics are
supplied. Your work is limited to constructing one register block and connecting
its map and predictor.

## Learn first

Read [resources/ral-setup-flow.md](resources/ral-setup-flow.md) and answer its
prediction before editing.

## Register contract

The authoritative local specification is
[dut/register-spec.md](dut/register-spec.md). This module uses one 32-bit
control register at byte offset `0x0`.

## Your work

Complete two bounded TODO regions in `tb/ua08_pkg.sv`:

1. In `ua08_reg_block::build()`, construct, configure, build, map, and lock the
   supplied control-register type.
2. In `ua08_env::connect_phase()`, bind the default map to the bus sequencer and
   adapter, configure the predictor with the same map and adapter, and connect
   completed bus observations to the predictor.

Do not implement another bus driver, adapter, or test. Do not manually assign
the register mirror from the test.

## Run

```powershell
cd "C:\Learning UVM\modules\advanced-uvm\UA-08-register-model-setup"
.\run.ps1
```

Expected learner completion: one frontdoor write reaches address `0x0`, the
driver stores `0x5`, and the register mirror becomes `0x5`.

## Direct fault command

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\tests\run-fixture.ps1 -Test ua08_wrong_offset_test
```

Expected result: nonzero exit and `UA08_STATUS`.

The fixture verifier is available for module maintenance:

```powershell
.\tests\verify-fixtures.ps1
```

## Prediction

If the register is mapped at byte offset `0x4` but the DUT implements it at
`0x0`, which boundary should first expose the disagreement: field modeling,
frontdoor bus status, or mirror comparison?

## Completion

The learner run passes at seed 1, the wrong-offset fixture fails through
`UA08_STATUS`, and the reflection explains how the frontdoor operation and
observed prediction paths differ.
