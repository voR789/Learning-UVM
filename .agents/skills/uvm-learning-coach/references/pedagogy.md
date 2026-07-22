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
