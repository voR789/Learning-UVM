# Register state and access paths

## Observable problem

Software intent, the RAL model, and the implemented register can disagree. For
example, hardware may update a status or control value without a register
transaction. A mirror that is never refreshed can then look valid while being
stale.

UA-09 separates three values:

| State    | Meaning                                  | Read with                    |
| -------- | ---------------------------------------- | ---------------------------- |
| actual   | Value held by the implementation         | A frontdoor or backdoor read |
| mirrored | RAL's latest believed observed value     | `get_mirrored_value()`     |
| desired  | Value RAL should write on a later update | `get()`                    |

The governing invariant is: **prediction is trustworthy only when it is fed by
an observation.** Do not use `predict()` to disguise a missing observation
path.

## Access paths

- **Frontdoor** uses the map, adapter, sequencer, and driver. It behaves like a
  normal bus access and consumes bus time.
- **Backdoor** bypasses the bus and directly reads or writes the implementation.
  In this transaction-level exercise, a supplied backdoor service reads the
  same storage used by the bus driver.

This direct service is supplied because the module has no pin-level RTL
hierarchy and XSim 2025.2's packaged UVM does not dynamically dispatch a custom
`uvm_reg_backdoor::read()` override. No bus item is generated.

## APIs used in your two methods

### Observe and synchronize in UA-09

```systemverilog
backdoor_handle.read(status, observed);
if (status == UVM_IS_OK)
    accepted = reg_handle.predict(observed);
```

The first call obtains evidence from implementation storage without bus
traffic. `predict()` then updates RAL from that observed evidence and returns
whether the prediction was accepted.

Conceptually, a normal configured RAL call:

```systemverilog
reg_handle.mirror(status, UVM_NO_CHECK, UVM_BACKDOOR);
```

bundles those two responsibilities: backdoor read, then model prediction.
`UVM_NO_CHECK` synchronizes without first reporting a mismatch against the old
mirror. UA-09 keeps them visible because of the local XSim compatibility limit.

### Stage intent

```systemverilog
reg_handle.set(next_value);
```

`set()` changes desired state only. It does not access the implementation and
does not create bus traffic. The mirror remains the last observed value.

### Commit staged intent

```systemverilog
reg_handle.update(status, UVM_FRONTDOOR, map_handle);
```

`update()` compares desired and mirrored state. If they differ, it writes the
desired value using the selected path. Here the frontdoor predictor observes
that completed write and updates the mirror.

### State inspection

```systemverilog
desired  = reg_handle.get();
mirrored = reg_handle.get_mirrored_value();
```

Neither call accesses the implementation.

### Where `predict()` fits

```systemverilog
accepted = reg_handle.predict(observed_value);
```

`predict()` tells RAL that an observed value is known to have occurred.
Predictors use it after decoding an independently observed bus item. Calling it
without first reading or monitoring the implementation can make the model agree
with a guess.

## Separate worked example

Suppose hardware changes a timer status register from `0` to `7`.

1. The actual value becomes `7`; desired and mirrored values remain `0`.
2. A backdoor read observes `7`.
3. `status_reg.predict(observed)` synchronizes desired and mirrored state to
   the observed value; all three values now equal `7`.
4. `status_reg.set(2)` changes desired state to `2`; actual and mirrored remain
   `7`.
5. `status_reg.update(status, UVM_FRONTDOOR, map)` sends a bus write.
6. The implementation and observed mirror become `2`.

## Your UA-09 flow

The supplied base test performs the surrounding steps and checks every
boundary:

1. Frontdoor-write `0x5`.
2. Model an external implementation-side change to `0x6`.
3. Call your `resynchronize_from_hardware()` method, which must obtain
   backdoor evidence before predicting it.
4. Call your `stage_desired()` method with `0x3`, then prove that only desired
   state changed and no bus transaction occurred.
5. Call your `commit_desired()` method.
6. Check final state and access counts.

Your methods should express the semantic operation, not recreate the supplied
bus or model.

## Prediction

Immediately after `set(0x3)` but before `update()`, which of actual, mirrored,
and desired state should equal `0x3`, and should the frontdoor transaction
count have changed?
