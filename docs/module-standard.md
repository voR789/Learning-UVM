# Learning Module Standard

## Purpose

Every module must be independently understandable, runnable, assessable, and small enough to produce focused practice.

## Required layout

```text
modules/<phase>/<module-id>-<slug>/
  module.yaml
  README.md
  dut/
  tb/
  tests/
  run.ps1
  rubric.md
  hints.md
  reflection.md
```

Integration modules may add `plan/`, `sequences/`, `coverage/`, or `reports/` when useful.

## Required `module.yaml` fields

```yaml
id: FV-01
title: Build a self-checking combinational testbench
phase: foundations
kind: micro
status: planned
estimated_minutes: 60
siemens_mapping:
  track: Functional Verification of Digital Logic
  unit: Verification Process Overview
prerequisites: []
objectives:
  primary: Separate expected-value calculation from DUT observation.
  supporting: []
learner_owns: []
codex_owns: []
run:
  shell: powershell
  command: ./run.ps1
  verified_with: null
completion_evidence: []
```

Use stable IDs from `curriculum/roadmap.yaml`. Never recycle a published ID.

## `README.md` requirements

Include:

1. Why the skill matters in verification work.
2. A behavioral DUT specification without leaking implementation-dependent checking details.
3. The exact task and learner-owned deliverables.
4. Constraints, allowed references, and expected time.
5. The run command and interpretation of results.
6. Completion criteria.
7. A short pre-coding prediction question.

Do not include the final implementation in the exercise README.

## Exercise sizing

### Micro-module

- Target 30 to 90 minutes.
- Teach one primary concept.
- Require one focused artifact or repair.
- Include at least one meaningful negative or fault case.

An explicitly documented read-only checkpoint may replace the focused artifact
when the objective is already evidenced and the remaining exercise would be
clerical. It still needs an observable example and recorded learner evidence,
and it cannot replace an integration gate.

### Integration module

- Target 3 to 8 hours.
- Combine at least three previously practiced concepts.
- Reduce scaffolding and hints.
- Require a short verification plan and evidence summary.

### Capstone

- Span multiple study sessions.
- Begin from a specification and RTL rather than a testbench skeleton.
- Require planning, architecture, implementation, regression, coverage analysis, debugging, and a concise report.
- Include seeded defects or independently reviewed fault cases.

## Test and grader requirements

- The default command must compile, elaborate, run, and report a clear result.
- Use deterministic directed checks before constrained randomness.
- Print or record the test name and random seed.
- Fail on compile errors, elaboration errors, timeouts, assertions, scoreboard mismatches, or UVM errors/fatals.
- Verify intended correct behavior passes.
- Verify at least one representative incorrect behavior fails for the intended reason.
- Keep checks independent of learner implementation details.
- Do not expose hidden fault details in starter files.

## Rubric standard

Use 100 points unless the roadmap declares a diagnostic-only exercise.

| Area | Default weight |
|---|---:|
| Functional correctness and fault detection | 35 |
| Architecture and separation of concerns | 20 |
| Protocol, timing, reset, and concurrency | 15 |
| Assertions, coverage, or randomization in scope | 10 |
| Reproducibility, diagnostics, and clarity | 10 |
| Explanation and reflection | 10 |

Passing normally requires 75 points and no critical correctness failure. Integration gates require 80; capstones require 85.

## Hint standard

Write hints in six labeled levels:

1. Diagnostic question.
2. Concept or invariant.
3. Location or component boundary.
4. Pseudocode or reduced example.
5. Minimal repair direction.
6. Reference solution or detailed patch.

Clearly separate levels 5 and 6 so the learner can stop before seeing them.

## Reflection standard

Ask three to five questions covering:

- What observable bug the testbench could detect.
- How stimulus, observation, prediction, and checking are separated.
- What failed during development and how it was localized.
- Which seed or test reproduces important behavior.
- How the solution would change in a larger reusable environment.

## Review outcome

A review should produce:

1. Evidence-backed findings ordered by severity.
2. Test or simulation evidence.
3. Rubric scoring with justification.
4. The smallest appropriate next hint.
5. A proposed progress-state update.

Do not modify learner code during a review-only request.
