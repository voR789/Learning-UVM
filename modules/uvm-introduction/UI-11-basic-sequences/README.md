# UI-11: Create and compose basic sequences

## Observable problem

UI-07 put item generation directly into one sequence. Real tests need reusable
stimulus behaviors that can be configured and combined without copying the
four-call item handshake. Otherwise every scenario becomes another monolithic
sequence with duplicated control flow.

## Mental model

```text
test starts composite_sequence
             |
             +--> configure + start leaf A --> three item handshakes
             |
             +--> configure + start leaf B --> three item handshakes
                                                |
                                                v
                                      sequencer -> driver
```

The composite owns scenario order. The leaf owns how one burst produces items.
The sequencer arbitrates requests; it does not invent the scenario or item
fields. Read [reading/sequence-composition-mental-model.md](reading/sequence-composition-mental-model.md)
and the separate [worked example](worked-example.md) first.

## Deterministic contract

The composite starts two three-item bursts:

| subsequence | IDs | payloads |
|---|---|---|
| first | 0, 1, 2 | 10, 11, 12 |
| second | 3, 4, 5 | 20, 21, 22 |

The driver must observe exactly this six-item order and acknowledge every item
exactly once.

## Prediction — answer before editing

If the composite starts only the first leaf sequence but the driver waits for
six items, which call remains blocked and what ends the run?

## Hands-on task

Complete the ten TODO regions in [tb/ui11_pkg.sv](tb/ui11_pkg.sv):

- implement the configurable leaf `body()`;
- create, configure, and start two child sequences from the composite;
- implement the driver's six-item handshake and checks;
- build and connect sequencer/driver components;
- start the composite from the test and reduce completion evidence.

## Run

```powershell
cd "C:\Learning UVM\modules\uvm-introduction\UI-11-basic-sequences"
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\run.ps1
```

## Constraints

- Use explicit `start_item`, `finish_item`, `get_next_item`, and `item_done`.
- Do not use sequence convenience macros.
- Do not duplicate the leaf item loop in the composite.
- Configure each child before calling `start`.
- Start both children on the composite's current sequencer.
- Keep exactly one `item_done()` per accepted item.

## Exact pass/fail criteria

Pass requires `completed=6`, `subsequences=2`, exact item ordering, zero UVM
errors/fatals, `SEQUENCE_TRACE`, and `TEST_RESULT: PASS`. Compile/elaboration
failure, timeout, wrong fields/order, missing acknowledgment, wrong counts, UVM
errors/fatals, or missing marker fails.
