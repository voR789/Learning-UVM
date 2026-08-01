# UA-06: Virtual-sequence coordination

## Why this is implementation work

UA-05 coordinated two children on one sequencer. UA-06 adds a different
boundary: one scenario must coordinate two independently typed sequencers—one
for control traffic and one for data traffic—without putting protocol items in
the virtual sequence itself.

Actual protocol-layer translation is covered as a reading checkpoint. Building
a synthetic upper-to-lower protocol stack here would add machinery that is not
needed for your current block-level and systolic-array goals.

## Learn first

Read [resources/virtual-versus-layered-sequences.md](resources/virtual-versus-layered-sequences.md)
and answer its prediction before editing.

## Supplied environment

The two item types, physical sequencers, drivers, leaf sequences, response
checks, environment construction, and test accounting are supplied.

The control leaf enables the design and triggers a shared event after receiving
an acknowledgement. The data leaf waits for that event, then sends three data
items. Both leaf sequences should be active under one virtual scenario.

## Your work

Complete two bounded TODO regions in `tb/ua06_pkg.sv`:

1. In `ua06_env::connect_phase()`, assign the physical control and data
   sequencer handles into the virtual sequencer.
2. In `ua06_virtual_sequence::body()`, start the supplied control and data leaf
   sequences on the correct `p_sequencer` handles and wait for both.

Do not move item generation into the virtual sequence. Do not directly call a
driver. Keep each leaf sequence on its matching typed sequencer.

Run the learner test:

```powershell
cd "C:\Learning UVM\modules\advanced-uvm\UA-06-virtual-sequence-coordination"
.\run.ps1
```

## Fault check

Run the missing-data-sequencer fixture directly:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\tests\run-fixture.ps1 -Test ua06_missing_data_handle_test
```

Expected result: nonzero exit and `UA06_VSEQR`.

Run all fixtures with:

```powershell
.\tests\verify-fixtures.ps1
```

## Prediction

If the virtual sequence starts on the virtual sequencer, but the environment
never assigns its `data_sequencer` handle, which layer should detect the missing
wiring before the data leaf starts?

## Completion

The learner test passes at seed 1 with one acknowledged control item and three
verified data items. The missing-handle fixture fails through `UA06_VSEQR`, and
the reflection explains virtual versus layered sequence responsibilities.
