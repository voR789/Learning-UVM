# UA-02 hints

## Level 1 — Diagnostic question

Does the requested replacement apply to every factory request for the base type,
or only to one future hierarchy path?

## Level 2 — Concept

Use a type override for global replacement and an instance override for
path-specific replacement.

## Level 3 — Location

Install each override in the derived test's `configure()` method, before
`ua02_env` is factory-created in the base test.

## Level 4 — Reduced pseudocode

```text
type test:
    base factory proxy -> override factory proxy

instance test:
    base factory proxy + exact future path -> override factory proxy
```

## Level 5 — Minimal repair direction

Call the registered base type's static factory-override method with the derived
type's factory proxy. Add the full `uvm_test_top.env.right` path only for the
instance case.

## Level 6 — Reference direction

The type test uses `set_type_override(...)`; the instance test uses
`set_inst_override(..., "uvm_test_top.env.right")`. Both must execute before
the environment's `type_id::create()` calls.
