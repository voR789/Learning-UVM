# Evidence summary — learner owned

| Stage              | Command / seed                                                    | First decisive evidence                       | Result |
| ------------------ | ----------------------------------------------------------------- | --------------------------------------------- | ------ |
| Initial flawed run | .\run.ps1 -Seed 1                                                 | [DV01_MISMATCH] index=0 expected=3 observed=7 | Fail   |
| Repaired run       | .\run.ps1 -Seed 1                                                 | [DV01_PASS] checked=2 mismatches=0]           | Pass   |
| Direct fault run   | ./run.ps1 -Seed 1 -PackagePath ./tests/reused_handle_fault_pkg.sv | [DV01_MISMATCH] index=0 expected=3 observed=7 | Fail   |

## Root cause

- Monitor did not create separate transaction objects for each transaction.

<!-- Symptom, violated invariant, and component that first violated it. -->

## Repair

- Create a new transaction object after the first publication.

<!-- Smallest change and why it restores the contract without weakening checking. -->
