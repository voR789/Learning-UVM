# UA-09: Register access and model-state semantics

## Evidence-first scope

UA-08 already proves that you can construct a register block and connect its
map, adapter, sequencer, and predictor. Repeating that work would add little.

The new invariant is state coherence: a register has an implemented value plus
RAL desired and mirrored values, and each API changes or observes different
parts of that state.

All architecture is supplied. Your work is three short methods in
`tb/ua09_pkg.sv`:

1. Observe an externally changed register through the supplied transaction-
   level backdoor, then predict that observed value into the model.
2. Stage a new desired value without bus traffic.
3. Commit that staged value through the frontdoor.

## Learn first

Read [resources/register-state-and-access.md](resources/register-state-and-access.md)
before editing. It includes the exact APIs and a separate worked example.

## Run

```powershell
cd "C:\Learning UVM\modules\advanced-uvm\UA-09-register-access-semantics"
.\run.ps1
```

Expected completion:

```text
UA09_TRACE actual=0x3 mirrored=0x3 desired=0x3 frontdoor=2 backdoor_reads=1
TEST_RESULT: PASS
```

## Direct fault command

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\tests\run-fixture.ps1 -Test ua09_predict_without_observation_test
```

Expected result: nonzero exit through `UA09_SYNC`. The fixture calls
`predict()` without first obtaining backdoor evidence from the implementation.

## Completion

The learner run passes at seed 1, the direct fault fails, and the reflection
explains the actual/mirrored/desired transitions and access-path choices.
