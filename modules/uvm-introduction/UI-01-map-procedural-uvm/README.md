# UI-01: From a working procedural testbench to UVM

## Why this matters

FV-G1 already separated stimulus, timed driving, passive observation,
prediction, checking, coverage, and termination. UVM does not replace that
verification reasoning. It gives those responsibilities standard homes,
lifecycle rules, configuration paths, and transaction connections so an
environment can grow without inventing new structure for every DUT.

This is a teach-first module. You are not expected to invent UVM syntax from
memory or build an agent. First learn the mental model, inspect a small working
example, and then map architecture you already understand.

## Observable contract

There is no new DUT behavior to verify in this module. The observable target is
the verification architecture:

- stimulus intent must remain separate from timed signal driving;
- only the driver owns active DUT inputs;
- the monitor is passive;
- prediction remains specification-derived and independent of DUT status;
- checking consumes observed and expected transactions;
- coverage measures observed scenarios rather than correctness;
- one owner coordinates start and end of test.

## Learning path

1. Read `reading/uvm-mental-model.md`.
2. Read `worked-example.md` and predict the printed hierarchy before running.
3. Run the module once. The UVM example should pass; the unfinished mapping
   worksheet should fail its structural check.
4. Complete `exercise/architecture-map.md` in your own words.
5. Re-run until both the example and mapping check pass.
6. Complete `reflection.md`.

## Run

```powershell
cd "C:\Learning UVM\modules\uvm-introduction\UI-01-map-procedural-uvm"
.\run.ps1
```

The runner prints the selected test and seed, compiles and runs the annotated
UVM hierarchy in XSim 2025.2, then checks that every mapping row is complete.
The starter worksheet is intentionally incomplete.

## Constraints

- Do not rewrite FV-G1 in UVM.
- Do not memorize the example boilerplate yet.
- Explain responsibility and data flow before discussing factory overrides,
  objections, or detailed TLM APIs; those receive dedicated later modules.
- Expected time: about 45 minutes.

## Completion

Completion requires a passing run, a semantically reviewed architecture map,
and the reflection. Structural validation alone does not prove the mappings are
correct.

## Prediction before running

Which parts of FV-G1 describe short-lived transaction intent, and which parts
must remain alive for most of the simulation?
