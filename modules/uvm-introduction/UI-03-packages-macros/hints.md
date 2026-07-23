# UI-03 Progressive Hints

Reveal one level at a time.

## Level 1: Diagnostic question

The caller recognizes `ui03_packet` but not `type_id`. Which class declaration
is responsible for supplying that standard UVM type interface?

## Level 2: Concept

Import makes declarations visible, include makes preprocessor macros visible,
and the registration macro adds UVM type machinery to the class.

## Level 3: Location

Inspect the TODO immediately inside `ui03_packet`, before its data fields and
constructor. The needed macro header is already included above the class.

## Level 4: Reduced example

```systemverilog
class some_object extends uvm_object;
    `uvm_object_utils(some_object)
    // fields and constructor
endclass
```

## Level 5: Minimal repair direction

Add the simple-object utility macro for `ui03_packet` at the TODO. Do not change
the caller or replace factory-based construction with `new`.

## Level 6: Reference answer

Place `` `uvm_object_utils(ui03_packet) `` directly inside the class before its
fields. Preserve the existing UVM import, macro include, and constructor.
