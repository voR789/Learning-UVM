# `uvm_config_db`: give UVM components their virtual interface

## Observable problem

`tb_top` owns the real `counter_if` instance because interfaces are created in
modules. The driver and monitor are UVM classes, so neither can directly name
that top-level instance. Both still need to access the same signals: the driver
to drive them and the monitor to observe them.

## Mental model

Think of `uvm_config_db` as a labeled, hierarchy-aware cabinet. A component
with a real object or handle stores it under a key. Another component retrieves
it into a local variable if its hierarchy matches the stored scope.

```text
tb_top owns the real counter_if
  |
  | set("vif", virtual-interface handle)
  v
uvm_config_db
  |--------------------|
  v                    v
driver.vif          monitor.vif
drives signals      observes signals
```

`virtual counter_if` is a handle that lets a class refer to that one real
interface instance. It does not create a second interface or copy signals.

## The two operations

The top-level testbench stores the handle once:

```systemverilog
uvm_config_db#(virtual counter_if)::set(null, "*", "vif", vif);
```

The type parameter says what is stored. `null` starts the scope at the top,
`"*"` makes the setting visible to descendant components, `"vif"` is the key,
and the final `vif` is the handle being stored.

A component retrieves it during `build_phase`:

```systemverilog
if (!uvm_config_db#(virtual counter_if)::get(this, "", "vif", vif))
  `uvm_fatal("NO_VIF", "virtual interface was not supplied")
```

Here, `this` means the current component; `""` means retrieve a setting for
that component itself; `"vif"` must exactly match the key used by `set`; and
the final `vif` is the component's local destination handle. `get()` returns
one on success and zero if no matching setting is found.

## Governing invariant

The type and key must agree between `set()` and `get()`, and every component
that dereferences `vif` must successfully retrieve a non-null handle first.
Otherwise a driver cannot safely drive and a monitor cannot observe.

## Prediction

If `tb_top` stores the interface with the key `"counter_vif"` but the driver
calls `get(..., "vif", vif)`, what value does `get()` return, and why should the
driver stop with a fatal error?
