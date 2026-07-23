# UI-04: Build and inspect a UVM component hierarchy

## Why this matters

UVM components are persistent roles arranged in a runtime hierarchy. Their
parentage determines full names, configuration scope, reporting context, and
later connection boundaries. A class can compile while its instance is absent
or attached to the wrong parent, so this module checks the runtime tree rather
than trusting declarations.

This is code-first but still teach-first: read the lifecycle model, trace the
separate example, make one prediction, then repair two component-creation TODOs.

## Observable contract

The required runtime topology is:

```text
uvm_test_top
└── container
    └── leaf
```

- `run_test()` must select and construct `ui04_hierarchy_test` as
  `uvm_test_top`.
- The test creates `container` during its `build_phase`.
- The container creates `leaf` during its `build_phase`.
- Both children are created through `type_id::create` with `this` as parent.
- The test prints topology and verifies the full component paths.
- The run phase raises an objection before checking and drops it only after the
  explicit pass marker.

There is no RTL DUT. The observable subject is UVM lifecycle and structure.

## Learning path

1. Read `reading/component-hierarchy-mental-model.md`.
2. Walk through `worked-example.md` and answer its prediction.
3. Run the starter; it should compile but fail because required children do not
   exist.
4. Complete the two TODOs in `tb/ui04_pkg.sv`.
5. Re-run until the hierarchy and result pass.
6. Complete `reflection.md`.

## Run

```powershell
cd "C:\Learning UVM\modules\uvm-introduction\UI-04-component-hierarchy"
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\run.ps1
```

## Constraints

- Do not change `tb_top.sv` or the required instance names.
- Do not use direct `new` for child components.
- Do not create children in `run_phase`.
- Do not pass `null` as a child component's parent.
- Do not memorize factory macro expansion; reason from type, name, and parent.

## Completion

Completion requires a passing run, semantic review, deliberate wrong-parent
evidence, and reflection. Expected time is about 75 minutes.

## Prediction before implementation

If the leaf is created with the test as parent instead of the container, what
full name will it receive and which required path will be missing?
