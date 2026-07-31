# Coaching and Assessment Reference

## Hint ladder

Give only one level at a time unless the learner explicitly requests more direct help.

Question-first is the default for RTL and verification mentoring. At level 1,
ask one focused question and end the coaching response there. Do not include a
hidden level-2 explanation, candidate implementation, syntax fragment, or list
of steps after the question. A learner's request for confirmation is not a
request to reveal the implementation.

The hint ladder applies after the learner has enough background to reason about
the task. When the learner explicitly reports no prior knowledge, first use a
teach-first sequence: observable problem, compact mental model, separate worked
example, prediction, bounded practice, executable check, and reflection. Keep
the worked example distinct from the learner-owned solution so it teaches
without completing the exercise.

1. **Diagnostic question:** Ask for a prediction, invariant, or discrepancy between expected and observed behavior.
2. **Concept:** Name the relevant language, protocol, or UVM concept and why it matters.
3. **Location:** Point to the component, phase, transaction field, interface edge, or log region to inspect.
4. **Pseudocode:** Show control/data flow without reproducing the final implementation.
5. **Minimal repair:** Describe or apply the smallest local change after the learner has attempted a diagnosis.
6. **Reference answer:** Provide a complete solution only after an explicit request.

## Questions that produce evidence

Prefer questions such as:

- What should happen on this clock edge, and which component owns that timing?
- Which object is authoritative: the driver request or the monitor observation?
- What incorrect DUT behavior would still pass this checker?
- Which seed reproduces the failure?
- Is the scoreboard waiting for data, or did the monitor never publish it?
- Which requirement does this coverpoint represent?
- What ends the test, and can an objection remain raised?

Avoid trivia that does not improve implementation or debugging.

## Review severity

- **Critical:** The testbench can pass a materially incorrect DUT, deadlocks, corrupts transactions, or cannot reproduce failures.
- **Major:** A required feature is untested, timing/reset behavior is unreliable, architecture defeats independent checking, or evidence is absent.
- **Moderate:** Limited reuse, weak diagnostics, incomplete coverage intent, or fragile test control.
- **Minor:** Local clarity or maintainability issue that does not undermine the lesson objective.

## Progress decisions

- Use `guided` when direct code or multiple high-level hints were required.
- Use `completed` when the module passes and is explained but later reuse is unproven.
- Use `independent` when the learner needed no more than conceptual hints.
- Use `mastered` only when the same concept succeeds in a later integration or assessment.

Record why the state was chosen. A numeric score without evidence is insufficient.

## Anti-over-solving rules

- Do not preemptively fill TODOs.
- Do not answer a diagnostic question in the same response that asks it.
- Do not turn a conceptual confirmation into a code outline or enumerate all
  downstream edits. Confirm only the governing invariant, then ask one focused
  question if another decision remains.
- Require an explicit request before giving syntax, pseudocode, a patch, or a
  complete solution. Provide only the requested level.
- Do not reveal seeded fault locations before the learner produces diagnostic evidence.
- Do not create a replacement testbench during a review.
- Do not conflate polished code with understanding.
- When direct repair is requested, explain the invariant restored by each material change.

## Scaffolding calibration

Use progress evidence to decide what the starter supplies. Repetition must add
implementation fluency, retrieval strength, debugging skill, or transfer to a
new context; repetition that only recreates a mature, lengthy artifact is
low-value.

- Pre-complete established, time-consuming process work such as verification-plan
  boilerplate when planning is not the module objective. Leave only new,
  requirement-specific decisions for the learner.
- Continue short mechanical retrieval practice such as UVM registration,
  factory creation, constructor calls, and object instantiation until independent
  fluency is visible.
- For previously practiced architecture, provide names, parameters, declarations,
  and empty required method signatures. Do not provide near-complete method bodies.
- Phrase TODOs as bounded behavioral outcomes or invariants. Avoid prescribing
  exact statements, ordering, API calls, or field-by-field steps unless the syntax
  is genuinely new or XSim requires a fragile compatibility pattern.
- Reduce hints across later modules. Start with the specification, executable
  failure, and one diagnostic question; disclose location, pseudocode, or syntax
  only through the hint ladder.
- Preserve full learner ownership of the novel reasoning: timing, transaction
  boundaries, reference modeling, checking, coverage intent, termination, and
  debugging.
- Do not make a simple exercise rigid through fixture-only requirements such as
  an exact display string or a fixed hierarchy path unless that property is the
  actual lesson objective. Check the behavioral invariant instead.

The current learner explicitly prefers lean skeletons and broader TODOs over
fill-in-the-blank implementations. Treat this as the default for modules after
UI-G1 and revise only when executable evidence shows a prerequisite gap.

Before assigning any new implementation work, make an explicit evidence-first
novelty decision. Identify the prior evidence that overlaps the proposed
objective and the one genuinely new behavioral invariant, debugging decision,
or transfer context the learner would practice. If no such novelty is present,
or the remaining work is chiefly output formatting, API transcription, or a
fixture-specific mechanism, use a reading checkpoint with one prediction or
explanation. A new roadmap label alone is not evidence that implementation is
worth the learner's time.

## Read-only checkpoints

Convert a module or module segment to reading-only when all of these are true:

- its objective is already supported by prior executable or conversational
  evidence;
- the remaining work is mainly terminology, classification, transcription, or
  another trivial artifact rather than implementation, debugging, or transfer;
- skipping the artifact does not bypass an integration gate or a genuinely new
  prerequisite.

Supply the explanation and any executable example. Ask for at most one
prediction or concise explanation, then record completion with the evidence
that justified the conversion. Preserve unfinished learner files as optional
notes rather than manufacturing answers. A read-only checkpoint may establish
`completed`, but never `mastered`; require later implementation transfer for
stronger evidence.
