# Inheritance and polymorphism: one contract, replaceable behavior

## 1. Observable problem

Suppose a scoreboard caller knows how to obtain `expected` and `actual`, but
different products require different comparison rules. Duplicating the caller
for exact, tolerant, masked, and protocol-specific comparisons mixes data flow
with comparison policy.

We want the caller to depend on one stable contract while the selected object
supplies the comparison behavior.

## 2. Four separate ideas

### Base class

A base class declares the common contract. A variable declared with the base
type is a **handle** capable of referring to a compatible derived object.

### Derived class

`class child extends parent` inherits the accessible members of `parent` and
may add state or provide a new implementation of a method.

### Overriding

A derived class overrides a method by declaring a compatible method with the
same contract. This supplies specialized behavior.

### Polymorphic dispatch

If the base method is `virtual`, a call through a base handle selects the
implementation belonging to the actual object. The handle's declared type
defines what may be called; the object's runtime type selects which override
runs.

```systemverilog
parent_handle = child_object;
parent_handle.do_work(); // child override runs when do_work is virtual
```

Inheritance alone does not guarantee runtime dispatch. The virtual method is
the important part of the contract.

## 3. Why verification uses this

The caller can remain unchanged while a test selects another compatible
policy. This is the object-oriented foundation beneath many later UVM ideas,
including replaceable components and transaction behavior. UVM adds standard
construction and configuration mechanisms later; it does not change normal
SystemVerilog virtual-method rules.

## 4. Handle identity

Assigning a derived object to a base handle does not copy or slice the object.
Both handles can refer to the same object. The base handle exposes only the
base-class contract, while virtual dispatch still remembers the actual derived
type.

## 5. Reading check

If the caller must ask what derived type it received and branch manually, what
benefit of polymorphism has been lost?
