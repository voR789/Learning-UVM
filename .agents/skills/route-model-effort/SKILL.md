---
name: route-model-effort
description: Classify incoming Learning UVM repository work by model and reasoning needs before acting. Use for UVM questions, reflection checks, code review, debugging, module creation, fixture validation, integration gates, and XSim failures. Keep lightweight work on Terra Low, but briefly pause and recommend Sol Light or Sol Medium before demanding work, then resume the original request when the user replies go, continue, or an equivalent confirmation.
---

# Route Model Effort

Route work without adding ceremony to ordinary mentoring.

## Classify the request

- **Terra Low:** Simple UVM questions, syntax clarification, concise mental-model
  explanations, reflection checks, and small read-only checks. Proceed immediately
  without mentioning the model.
- **Terra Medium:** Normal learner-code review, routine diagnosis, or a focused
  issue requiring several related observations. Recommend it only if Terra Low is
  materially likely to miss the issue; otherwise proceed.
- **Sol Light:** Creating a module or fixture, implementing a planned multi-file
  change, validating known-good and known-bad behavior, or performing a substantial
  repository update.
- **Sol Medium:** Difficult cross-component architecture bugs, unexplained XSim
  behavior, repeated failed diagnosis, integration-gate assessment, or work with
  consequential ambiguity and edge cases.

Do not recommend Sol High, Max, Extra High, or Ultra for this learning workflow
unless the user explicitly asks for a fresh recommendation.

## Pause before an upgrade

When Sol Light or Sol Medium is warranted, do not inspect files, call tools, make a
plan, or start the task. Reply with one short sentence:

`Switch to Sol Light, then reply "go" and I'll start.`

or:

`Switch to Sol Medium, then reply "go" and I'll start.`

Keep the user's full pending request in conversation context. Do not ask them to
repeat it.

Do not pause when:

- the user says they have already selected the recommended setting;
- the current turn follows this skill's recommendation and the user says `go`,
  `continue`, `start`, `ready`, or an equivalent confirmation;
- work is already underway in the current logical task;
- the request is lightweight enough for Terra Low.

## Resume cleanly

After confirmation, execute the pending request from the preceding conversation.
Do not repeat the recommendation, reclassify the same task, or ask what the user
wants done. Apply any other relevant repository skill normally.

If the task grows substantially harder only after executable evidence reveals an
unexpected problem, finish safe read-only inspection, summarize the blocker, and
recommend Sol Medium before continuing.

## Avoid false precision

This skill recommends a setting; it does not change the active model or reasoning
level itself. Do not claim that a switch occurred unless the user confirms it or
the current environment explicitly exposes that state.
