# Learning UVM

A practice-first SystemVerilog verification and UVM curriculum targeting AMD Vivado/XSim 2025.2 and preparation for design verification internships.

The canonical rules are in `AGENTS.md`, the ordered path is in `curriculum/roadmap.yaml`, and the exercise standard is in `docs/module-standard.md`.

## Current status

- Ground truth: created
- Module standard: created
- Curriculum roadmap: drafted
- Learner progress: initialized
- Repository-scoped coaching skill: created
- XSim/UVM smoke test and shared runner: verified with Vivado 2025.2
- Foundation pilot modules: next

## Start here

Run the toolchain module from PowerShell:

```powershell
cd 'C:\Learning UVM\modules\foundations\FV-00-xsim-uvm-smoke'
.\run.ps1
.\tests\verify-runner.ps1
```

The self-test proves both sides of the contract: a correct UVM test exits successfully, and a deliberate `UVM_ERROR` is rejected even though XSim itself may return zero.

## Intended workflow

1. Study the matching Siemens Verification Academy unit.
2. Ask Codex to select the next eligible module.
3. Read the specification and predict expected behavior.
4. Write or repair the verification code.
5. Run the documented PowerShell command.
6. Request review or progressive hints when needed.
7. Complete the reflection and record evidence.
8. Reuse the skill in a later integration assessment.

## Learning rule

This is not a solution repository. Starter code, checks, rubrics, and progressive hints are appropriate; complete solutions should only be produced when explicitly requested.

