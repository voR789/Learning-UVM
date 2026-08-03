# UA-10: Reusable register sequence and memory checking

## Evidence-first scope

UA-08 and UA-09 already prove block construction, frontdoor routing,
prediction, and desired/mirrored state handling. Rebuilding those pieces would
be repetition.

The new invariant is that two logical memory indices must remain independent.
A reusable register sequence must write distinct expectations, read each
location back, and reject address aliasing.

All bus, adapter, map, memory-model, environment, and test-lifecycle code is
supplied. Your only implementation work is `ua10_memory_check_seq::body()` in
`tb/ua10_pkg.sv`, followed by the reflection.

## Learn first

Read
[resources/register-sequences-memory-coverage.md](resources/register-sequences-memory-coverage.md).
It teaches the exact `uvm_mem` APIs and explains why coverage configuration is
a reading checkpoint rather than another boilerplate TODO.

## Required behavior

Using the supplied `model.scratch` memory:

1. Write different values to indices `0` and `1`.
2. Read both indices through the frontdoor.
3. Check every returned status.
4. Compare each returned value with an independently retained expectation.
5. Increment `verified` only after a successful comparison.

The supplied final checker requires:

- index `0` = `0xD00D_0001`;
- index `1` = `0xC0DE_0002`;
- two verified readbacks;
- four total frontdoor operations;
- one read and one write at each exercised index.

## Run

```powershell
cd "C:\Learning UVM\modules\advanced-uvm\UA-10-register-memory-sequence"
.\run.ps1
```

Expected completion:

```text
UA10_TRACE mem0=0xd00d0001 mem1=0xc0de0002 verified=2 completed=4
TEST_RESULT: PASS
```

## Direct fault command

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\tests\run-fixture.ps1 -Test ua10_alias_memory_test
```

Expected result: nonzero exit through `UA10_DATA`. The fixture makes two
logical memory addresses reach the same implemented storage location.

## Prediction

If both writes report `UVM_IS_OK` but indices `0` and `1` alias the same
storage, which readback should first disagree with its independently retained
expected value?

## Completion

The learner run passes at seed 1, the alias fixture fails, and the reflection
explains sequence reuse, memory indexing, independent checking, and coverage
intent.
