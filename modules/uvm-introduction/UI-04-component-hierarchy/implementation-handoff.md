# UI-04 Implementation Handoff

Updated: 2026-07-22

## Status

- UI-04 completed with guided evidence on 2026-07-23; UI-05 is now the current focus.
- The learner requested real UVM syntax and use cases, so the module is
  code-first with a compact lifecycle reading and separate worked example.
- The learner owns `tb/ui04_pkg.sv` and `reflection.md`.

## Completion evidence

- Final learner hierarchy passed in XSim 2025.2 at seed 1 with zero UVM
  errors/fatals and exact path `uvm_test_top.container.leaf`.
- Both owned children were factory-created during `build_phase` with `this` as
  the correct parent.
- The learner explained wrong-parent topology, phase ordering, runtime paths,
  and objection limits.
- Progress recorded as `guided`, score 95.

## Coaching start

1. Teach static `tb_top` versus dynamic `uvm_test_top` and trace `run_test`.
2. Walk through type, handle, instance-name string, parent, and full path.
3. Ask the worked-example path prediction.
4. Run the starter and classify the missing hierarchy before editing.
5. Coach one build-phase TODO at a time without filling both for the learner.

## Verification status

- XSim 2025.2 valid fixture passed at seed 1 with
  `uvm_test_top.container.leaf` and zero UVM errors/fatals.
- Wrong-parent fixture produced `uvm_test_top.leaf` and failed with one UVM
  fatal because `uvm_test_top.container.leaf` was missing.
- The unimplemented learner starter compiled and elaborated, printed only
  `uvm_test_top`, and failed with one UVM fatal because `container` was absent.
- The combined fixture wrapper may exceed a 120-second outer command timeout on
  this Windows host; the positive and negative fixtures were also verified
  individually.

## Guardrails

- Do not introduce environment composition policy beyond the nested example;
  UI-05 owns reusable environment design.
- Do not introduce TLM connections; UI-06 owns them.
- Do not let direct `new`, wrong parents, or run-phase construction satisfy the
  exercise.
- Preserve the distinction between objections and actual completion proof.
