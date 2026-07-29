# Transaction object semantics

## Problem

Verification components must agree on what a transaction means. A packet can
look correct in a log while copying or comparing the wrong subset of fields.

## Mental model

Treat a transaction as one value with four aligned views:

```text
legal generation <-> stored fields <-> copy/compare <-> diagnostics
```

Constraints define legal generated values. Field automation tells standard UVM
operations which state participates in copy and compare. `convert2string()`
turns the same live state into a compact diagnostic.

For scalar fields, the registration form is:

```systemverilog
`uvm_object_utils_begin(example_txn)
  `uvm_field_int(field_a, UVM_DEFAULT)
  `uvm_field_int(field_b, UVM_DEFAULT)
`uvm_object_utils_end
```

This also supplies the factory registration normally provided by
`uvm_object_utils`, so do not use both registration forms on the same class.

## Worked example

An unrelated interrupt transaction contains `rand bit [3:0] source` and
`rand bit asserted`. A constraint prevents source zero when asserted. Both
fields appear in its field automation, and `convert2string()` reports the source
and asserted state. After copying it, changing only `source` must make
`compare()` return false.

## Invariant

Every meaningful transaction field participates consistently in legality,
copy/compare behavior, and diagnostics unless a documented reason excludes it.

## Prediction

If a field appears in `convert2string()` but not in field automation, can two
objects print differently while UVM `compare()` still says they match?
