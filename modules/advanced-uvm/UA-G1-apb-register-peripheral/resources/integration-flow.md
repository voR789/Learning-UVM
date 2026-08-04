# Integrating RAL, passive checking, coverage, and drain control

## Observable problem

A high-level register sequence can receive the value it expected while the
environment still has a structural defect: the monitor may decode the wrong
address, the predictor may update from driver intent, coverage may sample
planned rather than completed transfers, or the test may end before checking
drains.

The governing invariant is:

> One completed bus observation fans out to prediction, checking, and coverage;
> stimulus uses responses for control but does not certify correctness.

## Data flow

```text
RAL scenario -> map/adapter -> sequencer -> driver -> APB pins -> DUT
                                                   |
                                             passive monitor
                                              /     |      \
                                      RAL predictor scoreboard coverage
```

The monitor publishes only when `psel && penable && pready` is true on a rising
edge. Its transaction contains direction, address, write data, read data, and
the error response sampled from the interface.

## Monitor publication

Create a fresh transaction for each completed transfer. Copy the request-side
signals and the returned signals into it, then call the monitor analysis port's
`write()` method. Do not publish setup cycles.

Separate example:

```systemverilog
@(posedge vif.clk);
if (vif.sel && vif.enable && vif.ready) begin
    observed = bus_item::type_id::create("observed");
    observed.write = vif.write;
    observed.addr  = vif.addr;
    observed.error = vif.error;
    completed_ap.write(observed);
end
```

## Independent scoreboard state

The scoreboard reconstructs only the architectural state needed to predict
later observations:

- last accepted enable value;
- last accepted gain value;
- expected result and overflow from each accepted command.

An error response is itself observable behavior. Predict whether a monitored
transfer should error using the pre-transfer model state. Update the model only
after an accepted write. When `RESULT` is read successfully, compare `prdata`
with the independently calculated result and account for that check.

Do not use `model.RESULT.get_mirrored_value()` as the expected result. The RAL
mirror and scoreboard receive the same observed transfer, so that would not be
an independent functional prediction.

## RAL scenario mechanics

The supplied block already binds its map to the APB sequencer and adapter. A
`uvm_reg_sequence` can therefore call:

```systemverilog
model.control.write(status, value, UVM_FRONTDOOR, model.default_map, this);
model.status.read(status, observed, UVM_FRONTDOOR, model.default_map, this);
```

For delayed completion, poll `STATUS` with a bounded loop. Stop when `done`
becomes one; fail if the bound expires. The status value is used to decide what
to do next. Correctness remains independently checked from monitor traffic.

Use this gate's scenarios:

- disabled `DATA=0x05` must be rejected;
- enable, `GAIN=3`, `DATA=0x20` must lead to `RESULT=0x60`;
- `GAIN=4`, `DATA=0x80` must lead to saturated `RESULT=0xFF` with overflow.

## Coverage source and closure

Coverage samples the monitor transaction, not sequence intent. Required
evidence is:

- every mapped address observed;
- at least one read and one write;
- at least one error and one successful transfer;
- one normal result and one saturated result.

The coverage flags in RAL do not create this sampling model. The subscriber
must implement and sample the requirement-level covergroup.

## Drain-based termination

After the scenario returns, the supplied base test waits until the scoreboard
has checked two `RESULT` reads. That explicit condition protects against ending
the test while passive analysis is still pending. A fixed delay is not proof of
drain.

## Prediction

If the monitor publishes the setup cycle and the access cycle as two
transactions, which downstream counts and models become incorrect?
