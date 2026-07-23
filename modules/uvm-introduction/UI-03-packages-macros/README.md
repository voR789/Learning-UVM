# UI-03: Packages, includes, and UVM macros

## Why this matters

UVM testbenches spread classes across reusable packages. A class may be valid
SystemVerilog yet still be unavailable because its package was compiled too
late, its names were not imported, its macro definitions were not included, or
its type was never registered. These failures look similar in a compiler log
but come from different mechanisms.

This is teach-first. You will see the exact syntax in a separate example before
repairing the learner-owned package.

## Observable contract

The exercise defines `ui03_packet`, a small `uvm_object` with one integer field.

- `ui03_pkg` must import the UVM declarations it uses.
- The UVM macro definitions must be textually included before a registration
  macro is expanded.
- `ui03_packet` must be registered with the appropriate object utility macro.
- `tb_top` imports `ui03_pkg` and constructs `ui03_packet` through
  `ui03_packet::type_id::create("packet")`.
- The package must compile before `tb_top`.
- A created packet must retain `value = 42` and produce an explicit pass result.

## Learning path

1. Read `reading/packages-macros-mental-model.md`.
2. Walk through `worked-example.md` and answer its prediction.
3. Run the starter and classify its first compiler failure.
4. Complete `exercise/syntax-map.md` in your own words.
5. Repair the TODO in `tb/ui03_pkg.sv` without changing `tb_top.sv`.
6. Re-run until XSim passes, then complete `reflection.md`.

## Run

```powershell
cd "C:\Learning UVM\modules\uvm-introduction\UI-03-packages-macros"
.\run.ps1
```

If Windows blocks scripts:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\run.ps1
```

## Constraints

- Do not replace `type_id::create` with direct `new` in the caller.
- Do not move the packet class into `tb_top.sv`.
- Do not copy UVM declarations into the learner package.
- Treat macros as source transformation, not as persistent UVM components.

## Completion

Completion requires a passing run, a correct syntax map, semantic review, and
reflection. Expected time is about 60 minutes.

## Prediction before implementation

If `tb_top.sv` imports `ui03_pkg` but the package has not been compiled yet,
will the import fix the dependency? Why or why not?
