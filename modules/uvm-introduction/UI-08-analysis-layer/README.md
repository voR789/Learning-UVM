# UI-08: Observe traffic through the analysis layer

## Observable problem

A monitor can reconstruct correct transactions, yet the environment learns
nothing unless those observations reach every checker, coverage model, or
logger that needs them. Direct calls from the monitor would couple observation
to concrete consumers and make reuse progressively harder.

The analysis layer solves that routing problem. A publisher makes one
`write(item)` call on an `uvm_analysis_port`; every connected analysis endpoint
receives that call. The publisher neither selects one recipient nor waits for a
later response.

## Mental model

Think **typed announcement**, not request:

```text
monitor.ap.write(item)
          +--> checker.analysis_export --> checker.write(item)
          |
          +--> audit.in_imp -----------> audit.write(item)
```

`connect_phase` owns the fan-out wiring. Each consumer owns its own checking
state. Analysis `write()` is a zero-time function: consumers must not block the
publisher or send an acknowledgment.

This differs from earlier modules:

- UI-06 blocking `put/get` can wait for a receiver or data.
- UI-07 sequence-driver TLM coordinates ownership and completion with
  `get_next_item/item_done`.
- UI-08 analysis broadcasts an observation to all connected listeners with no
  grant, dequeue, or completion response.

Read [reading/analysis-mental-model.md](reading/analysis-mental-model.md), then
study the separate [worked example](worked-example.md) before editing the
worksheet.

## Deterministic contract

The publisher emits exactly these three observations, in order:

| index | id | payload |
|---:|---:|---:|
| 0 | 20 | 3 |
| 1 | 21 | 6 |
| 2 | 22 | 9 |

Both independent consumers must receive and check all three. The final trace
must report `published=3 subscriber_checks=3 audit_checks=3`.

## Prediction — answer before editing

If the publisher's analysis port is connected only to the subscriber, does
`ap.write(item)` block waiting for the missing audit consumer, silently skip
that consumer, or report an automatic UVM error? Why?

## Your task

Complete the TODOs in `tb/ui08_pkg.sv`:

1. Declare and construct the monitor's typed `uvm_analysis_port`.
2. In `ui08_env::connect_phase`, connect that one port to both the subscriber's
   analysis export and the audit component's analysis implementation.

Do not fill these TODOs from the worked example by copying names mechanically;
map publisher, transaction type, and each endpoint deliberately.

## Run

```powershell
cd "C:\Learning UVM\modules\uvm-introduction\UI-08-analysis-layer"
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\run.ps1
```

The untouched starter is expected to fail. A completed worksheet passes only
when compilation, elaboration, simulation, both consumer counts, transaction
values, ordering, pass marker, and UVM error counts all pass.

## Constraints

- Keep all routing in `connect_phase`.
- Do not call either consumer's `write()` directly.
- Do not add a FIFO, request handshake, response, barrier, or delay inside
  `write()`.
- Consumers may inspect but must not mutate the shared transaction.
- Preserve the deterministic items and exact count checks.

## Exact completion criteria

- The default command exits zero with `TEST_RESULT: PASS`.
- Exactly three observations are published.
- Both consumers independently validate all three observations in order.
- The final UVM summary has zero errors and zero fatals.
- The missing-subscriber fixture exits nonzero because `audit_checks=0`, not
  because of compilation or elaboration.
- `reflection.md` is completed in your own words.
