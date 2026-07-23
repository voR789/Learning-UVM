# UI-06: Connect UVM objects with TLM

UI-05 created components but no data could move between them. UI-06 adds typed
transaction paths without introducing pin-level driving or sequencer
handshakes yet.

## Required flow

```text
producer.item_out (blocking put port)
        ↓
fifo.put_export → buffered item → fifo.get_export
                                      ↑
                         consumer.item_in (blocking get port)

producer.audit_out (blocking put port)
        ↓
audit.in_imp → audit.put(item)
```

The FIFO path demonstrates ports connected to library exports. The audit path
demonstrates a port connected to a terminal implementation (`imp`) whose owner
provides the actual `put()` task.

## Contract

- Producer creates one item with `id=7`, `payload=42`.
- Consumer receives and checks it through a depth-one `uvm_tlm_fifo`.
- Audit sink receives and checks it through its blocking-put implementation.
- Consumer and audit each record exactly one check.
- A three-party barrier releases only after the test, consumer, and audit sink
  all reach completion.
- Connections belong in `connect_phase`; endpoint construction belongs in
  constructors/build phase.

## Task

Complete only the three TODO connections in `ui06_env::connect_phase`.

```powershell
cd "C:\Learning UVM\modules\uvm-introduction\UI-06-tlm-connections"
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\run.ps1
```

The starter compiles but fails because required TLM ports are unconnected.

## Constraints

- Do not replace TLM calls with direct component method calls.
- Do not connect both producer outputs to the FIFO.
- Do not move connections into `run_phase`.
- Do not weaken the barrier or count checks.
- Do not mutate the item in either consumer.

## Prediction

Which endpoint owns the executable `put()` implementation on the audit path:
the producer's port or the audit sink's imp?

## Completion

Passing requires one consumer check, one audit check, explicit pass evidence,
the misroute fault evidence, and reflection.
