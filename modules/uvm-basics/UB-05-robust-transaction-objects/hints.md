# UB-05 Hints

## Level 1 — Diagnostic question

Which declaration determines whether a field participates in the standard UVM
copy and compare operations?

## Level 2 — Invariant

Every meaningful field must have consistent generation, copy/compare, and
diagnostic semantics.

## Level 3 — Location

Inspect the object-registration block, `legal_c`, and `convert2string()`.

## Level 4 — Reduced pseudocode

```text
register object:
  include each meaningful scalar field

constraint:
  bound address
  if write, exclude zero data

string:
  format current address, data, and write values
```

## Level 5 — Minimal repair direction

Use one `uvm_object_utils_begin/end` registration block, one `uvm_field_int`
entry per meaningful scalar, and ensure the constructor delegates to the parent
object.

## Level 6 — Reference direction

Compare the structure with the unrelated worked example in the resource. Keep
the same four aligned views—legality, state, copy/compare, diagnostics—without
copying its field names.
