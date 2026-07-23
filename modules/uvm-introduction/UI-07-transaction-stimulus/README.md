# UI-07: Explicit sequence-to-driver handshake

UI-06 connected general TLM endpoints. UI-07 applies the same principle to
UVM's standard stimulus path:

```text
sequence → sequencer → driver
                        ↓
                 later: DUT pins
```

## Contract

The sequence produces three items:

| ID | Payload |
|---:|---:|
| 0 | 10 |
| 1 | 20 |
| 2 | 30 |

For every item:

```text
sequence: start_item(req)
sequence: fill fields
sequence: finish_item(req) ───────────────┐
                                          ↓
driver:   get_next_item(req) → check/act → item_done()
```

`finish_item()` cannot complete its request handshake until the driver calls
`item_done()`.

## Your task

Complete the TODOs in `tb/ui07_pkg.sv`:

1. Sequence-side request handshake.
2. Driver-side request handshake and completion.
3. Agent TLM connection.

Run:

```powershell
cd "C:\Learning UVM\modules\uvm-introduction\UI-07-transaction-stimulus"
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\run.ps1
```

Do not use `` `uvm_do `` macros; implement the explicit handshake.

## Prediction

If the driver calls `get_next_item()` but never calls `item_done()`, which
sequence operation remains blocked and why?
