# UI-04 Progressive Hints

Reveal one level at a time.

## Level 1: Diagnostic question

Which component owns each missing child, and what should that imply about the
parent argument passed to `create`?

## Level 2: Concept

Persistent UVM structure is factory-created during `build_phase`. The instance
name string supplies the short name; `this` supplies the current component as
parent.

## Level 3: Location

There is one TODO in `ui04_container::build_phase` and one in
`ui04_hierarchy_test::build_phase`. Do not change `run_phase` or `tb_top`.

## Level 4: Reduced example

```systemverilog
child_handle = child_type::type_id::create("child_name", this);
```

## Level 5: Minimal repair direction

In each build phase, assign the corresponding handle from its class
`type_id::create`, using the required quoted instance name and `this`.

## Level 6: Reference answer

The container creates `leaf` as
`ui04_leaf::type_id::create("leaf", this)`. The test creates `container` as
`ui04_container::type_id::create("container", this)`.
