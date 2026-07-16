# FV-03: Transaction models

## Observable verification problem

FV-02 passes eight separate arguments into every `check_case` call. As transactions grow, positional arguments become difficult to read, copy, log, and pass between verification components. A transaction object groups related data and behavior, but class variables are handles rather than copied values.

## Predict before coding

If two class variables refer to the same object and you change a field through one variable, what will the other variable observe? How would that differ for two packed-struct variables?

## Your task

Complete the TODOs in `tb/transaction_lab.sv`:

1. Implement `copy_from` so an independent object receives every transaction field.
2. Implement `compare` so any field mismatch returns false.
3. Implement `sprint` so diagnostics identify the transaction and all fields.
4. Complete the alias and independent-copy experiments in the `initial` block.
5. Deliberately change one copied field and prove `compare` detects it.

## Run

```powershell
cd "C:\Learning UVM\modules\foundations\FV-03-transaction-models"
.\run.ps1
```

The starter is expected to fail until the TODOs are completed.
