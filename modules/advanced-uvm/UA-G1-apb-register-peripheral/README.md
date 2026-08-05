# UA-G1: APB register-peripheral integration gate

## Why this gate is implementation work

Earlier modules prove each mechanism separately: reusable agents, passive
analysis, predictor/scoreboard flow, virtual coordination, maintainable tests,
RAL frontdoor access, prediction, and memory checking. This gate tests the
missing transfer skill: integrating those mechanisms around one unfamiliar
register-controlled behavior without allowing stimulus intent to become the
correctness oracle.

Repeated declarations, RAL construction, APB driving, adapter translation,
environment construction, and base-test lifecycle are supplied. You own four
behavioral boundaries in `tb/ua_g1_pkg.sv`:

1. publish completed APB transfers from the passive monitor;
2. predict and check peripheral behavior from those observations;
3. sample requirement-level coverage from the same observations;
4. run a response-driven RAL scenario that exercises rejection, normal output,
   and saturation.

You also complete the short plan decisions, evidence summary, and reflection.

## Learn first

Read [resources/integration-flow.md](resources/integration-flow.md), then read
[spec/peripheral-spec.md](spec/peripheral-spec.md). The resource explains the
connections and method contracts; the specification remains authoritative for
expected behavior.

## DUT summary

The peripheral has five 32-bit APB-style registers:

|  Address | Name       | Purpose                          |
| -------: | ---------- | -------------------------------- |
| `0x00` | `CTRL`   | bit 0 enables command acceptance |
| `0x04` | `GAIN`   | 8-bit unsigned multiplier        |
| `0x08` | `DATA`   | write-only command input         |
| `0x0C` | `STATUS` | busy, done, and overflow         |
| `0x10` | `RESULT` | saturated 8-bit result           |

Writing `DATA` while disabled must return an error. When enabled, the DUT
eventually produces `min(DATA * GAIN, 255)` and records overflow.

## Learner work

Complete the outcome-based TODO regions in:

- `tb/ua_g1_pkg.sv`;
- `plan/verification-plan.md`;
- `reports/evidence-summary.md`;
- `reflection.md`.

Do not derive scoreboard expectations from RAL mirror values, driver requests,
or DUT internals. The monitor's completed APB transfers are the scoreboard's
only observation source.

## Run

```powershell
cd "C:\Learning UVM\modules\advanced-uvm\UA-G1-apb-register-peripheral"
.\run.ps1
```

The untouched starter must fail through `UAG1_TODO`. A completed learner run
must print `TEST_RESULT: PASS`, two checked results, zero mismatches, and the
required coverage evidence.

## Direct fault command

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\tests\run-fixture.ps1 -Test ua_g1_fault_test
```

Expected result: nonzero exit through `UAG1_MISMATCH`. The same passive checking
contract is used against an incorrect result implementation.

## Prediction

If the RAL sequence expects `0x60` and its `read()` returns `0x60`, why must the
passive scoreboard still calculate and check that result independently?

## Completion

Pass the learner run at seed 1, reproduce the documented fault, complete the
three learner-owned Markdown artifacts, and explain stimulus, observation,
prediction, checking, coverage, and drain-based termination.
