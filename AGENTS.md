# Learning UVM Repository Ground Truth

## Mission

Build practical SystemVerilog verification and UVM competence until the learner can independently plan, implement, debug, and explain a reusable UVM testbench for unfamiliar RTL and present credible work when applying for a design verification internship.

This repository is a practice environment, not an answer archive. Optimize for durable understanding, independent debugging, and visible engineering evidence.

## Learner Profile

- Has digital design and RTL knowledge.
- Understands the basic shape of verification but has little hands-on verification experience.
- Is new to UVM and is completing Siemens Verification Academy material in parallel.
- Primary languages: SystemVerilog and Verilog RTL.
- Primary simulator: AMD Vivado Simulator (XSim) 2025.2.
- UVM target: the precompiled UVM 1.2 library supplied with Vivado 2025.2.
- Host environment: Windows and PowerShell.
- Weekly study time: TBD. Do not invent calendar deadlines until this is supplied.

## Source Priority

When sources disagree, use this order and document any compatibility exception:

1. The local DUT specification, module contract, and accepted repository decisions.
2. IEEE 1800 SystemVerilog and IEEE 1800.2 UVM semantics.
3. AMD Vivado 2025.2 XSim documentation and behavior observed by executable probes.
4. Siemens Verification Academy course material and UVM Cookbook.
5. Other reputable verification references.

Do not assume a construct supported by another simulator works in XSim. Add a minimal compatibility probe when support is uncertain.

## Curriculum Contract

Follow `curriculum/roadmap.yaml` in prerequisite order. Keep the path aligned with:

1. Functional Verification of Digital Logic foundations.
2. Introduction to the UVM.
3. UVM Basics.
4. Advanced UVM.
5. Independent DV internship preparation.

Use short modules for isolated skills and spaced integration modules for synthesis. Do not generate the entire course before the initial pilot has been completed and reviewed.

## Pedagogy Contract

For each new concept:

1. State the observable verification problem.
2. Ask the learner to predict behavior or failure.
3. Provide the smallest useful explanation or example.
4. Require the learner to implement or repair the code.
5. Run a self-checking test.
6. Require a short explanation or reflection.
7. Reuse the concept later without scaffolding.

Use this hint ladder unless the learner explicitly requests stronger help:

1. Ask a diagnostic question.
2. Name the relevant concept or invariant.
3. Point to the relevant file, component, phase, or interface.
4. Give pseudocode or a reduced example that is not the final answer.
5. Provide a minimal patch only when explicitly requested or after an explained attempt.
6. Provide a complete reference solution only when explicitly requested.

Default coaching style: prefer concise senior-engineer diagnostic questions over direct answers. Give enough explanation to establish the governing invariant, then return ownership of the implementation decision to the learner. Expand into direct syntax, pseudocode, or patches only when explicitly requested or after a reviewed attempt.

Never weaken a grader merely to make incorrect learner code pass. Never overwrite learner-owned code without preserving and explaining the change.

## Ownership Boundaries

The learner normally owns:

- Files under a module's `tb/` directory unless `module.yaml` says otherwise.
- Verification plans and reflection answers.
- Debugging decisions and final explanations.

Codex may normally create or maintain:

- DUTs written specifically for an exercise.
- Starter scaffolding and TODO markers.
- Runners, hidden checks, compatibility probes, rubrics, and hint files.
- Curriculum metadata and progress evidence.

When reviewing learner code, begin with findings and evidence. Do not silently replace the implementation.

## Module Contract

Every learning module must conform to `docs/module-standard.md`. At minimum, define:

- One primary objective and a small set of supporting objectives.
- Prerequisites and Siemens course mapping.
- Learner-owned deliverables.
- A deterministic run command.
- Observable pass and fail criteria.
- A rubric, progressive hints, and a reflection prompt.

Micro-modules should normally take 30 to 90 minutes. Integration modules may take 3 to 8 hours. Capstones may span multiple sessions.

## Completion and Mastery

Compilation alone is never sufficient. A module is complete only when:

- Compilation, elaboration, and simulation pass with the documented command.
- The testbench distinguishes expected behavior from at least one meaningful fault or negative case.
- The learner can explain stimulus, observation, prediction, checking, and termination.
- Required assertions or coverage are implemented when in scope.
- The reflection is completed in the learner's own words.

Use these progress states:

- `not_started`: no meaningful attempt.
- `guided`: completed with substantial hints or direct repair.
- `completed`: passes and is explained, but later independent reuse is unproven.
- `independent`: completed with at most conceptual hints.
- `mastered`: successfully reused in a later integration module or assessment.

Record evidence in `curriculum/progress.yaml`; never award `mastered` from one isolated exercise.

## Verification Quality Expectations

Grow these expectations with the curriculum rather than forcing full UVM architecture into early exercises:

- Derive checks from the specification, not DUT implementation details.
- Keep stimulus, driving, monitoring, prediction, and checking conceptually separate.
- Prefer self-checking tests and reproducible seeds.
- Treat reset, concurrency, handshakes, backpressure, and end-of-test behavior explicitly.
- Check transaction fields and temporal behavior, not merely final signal values.
- Make monitors passive and scoreboards independent of the driver.
- Use functional coverage to measure intent; do not confuse code coverage with completeness.
- Use assertions for temporal/interface invariants when supported by the lesson and simulator.
- Log the test name, seed, result, and relevant UVM error counts.
- Re-run the failing seed after every random failure fix.

## Toolchain Contract

- Target Vivado/XSim 2025.2 first.
- Use PowerShell entry points for learner-facing commands.
- Use `.sv` for SystemVerilog sources.
- For standalone XSim UVM flows, compile and elaborate against the precompiled `uvm` library.
- Keep generated simulator artifacts outside source directories where practical and ignore them in Git.
- A runner must return nonzero on compile, elaboration, UVM, assertion, timeout, or scoreboard failure.
- Until the shared runner is implemented, run commands may be marked `planned`, not falsely reported as verified.

## Repository Change Rules

- Read this file, the relevant `module.yaml`, and learner progress before changing a module.
- Preserve prerequisite order and stable module IDs.
- Do not advance progress without executable or review evidence.
- Do not commit generated Vivado projects, waves, logs, coverage databases, or work libraries.
- Keep skill instructions concise; keep project facts here rather than duplicating them in a skill.
- Cite a source or record an explicit project decision for non-obvious methodology rules.
- Favor small reviewable changes and validate modified metadata.

## Initial Build Order

1. Establish this ground truth and repository structure.
2. Define the standard module schema and rubric.
3. Define the roadmap and initial progress state.
4. Create and validate the repository-scoped `uvm-learning-coach` skill.
5. Build and verify a Vivado 2025.2 UVM smoke test and shared XSim runner.
6. Create the foundation pilot modules only.
7. Complete the pilot, revise the teaching system, then expand one Siemens unit at a time.
