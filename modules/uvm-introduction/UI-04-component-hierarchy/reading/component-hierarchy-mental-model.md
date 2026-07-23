# UVM component hierarchy: types become parented runtime instances

## 1. Observable problem

Declaring a component class does not place an instance in the testbench. UVM
needs a selected top-level test and a repeatable top-down construction process
that gives every persistent component a name and parent.

The resulting hierarchy is observable through full names and topology output.

## 2. Static HDL top versus dynamic UVM top

`tb_top` is a static SystemVerilog module elaborated before simulation. It calls:

```systemverilog
run_test();
```

`run_test` asks UVM to select a registered `uvm_test` type, construct it, and
run the UVM phase schedule. The selected test instance receives the conventional
name:

```text
uvm_test_top
```

The simulator runner supplies `+UVM_TESTNAME=ui04_hierarchy_test`, so the empty
`run_test()` call does not hard-code the class in `tb_top`.

## 3. Type, handle, instance name, and full path

Keep four terms separate:

```systemverilog
ui04_container container;
container = ui04_container::type_id::create("container", this);
```

- `ui04_container`: the class type.
- `container` on the left: a handle variable.
- `"container"`: the runtime instance name.
- `this`: the runtime parent component.

If the current component is `uvm_test_top`, the child's full path becomes:

```text
uvm_test_top.container
```

## 4. Why build_phase

`build_phase` is UVM's standard structural-construction phase. UVM traverses
components top-down: a parent builds, creates children, then those children
receive their own build callbacks.

```text
construct selected test
        ↓
test.build_phase creates container
        ↓
container.build_phase creates leaf
        ↓
structure is complete before later phases
```

Using factory creation here preserves override support and gives UVM the
parent-child relationship needed for hierarchy-aware services.

## 5. Constructor versus build_phase

The constructor establishes the component's own base state:

```systemverilog
function new(string name, uvm_component parent);
    super.new(name, parent);
endfunction
```

`build_phase` creates owned child structure:

```systemverilog
function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    child = child_type::type_id::create("child", this);
endfunction
```

Calling `super.build_phase(phase)` preserves inherited build behavior.

## 6. run_phase and objections

`run_phase` is task-based and may consume simulation time. An objection says
that a participant is not yet ready for the run phase to end:

```systemverilog
phase.raise_objection(this);
// time-consuming or checked activity
phase.drop_objection(this);
```

Objections do not create components and do not prove work is complete. They
only keep the task-based phase alive until the owner reports completion.

## 7. Reading check

In `type_id::create("leaf", this)`, which argument determines the short instance
name and which argument determines its parent path?
