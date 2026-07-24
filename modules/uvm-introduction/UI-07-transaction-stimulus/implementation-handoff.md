# UI-07 Implementation Handoff

Updated: 2026-07-23

## Status

- UI-07 completed with guided evidence on 2026-07-23; UI-08 is now current
  focus.
- Learner recognizes TLM concepts but wants executable implementation practice.
- Learner owns `tb/ui07_pkg.sv` and `reflection.md`.

## Completion evidence

- Final learner run passed in XSim 2025.2 at seed 1 with exactly three
  completed items and zero UVM errors/fatals.
- The learner implemented both handshake pairs and the specialized TLM
  port-to-export connection.
- Reflection was accepted after corrections to grant, submission, ownership,
  and acknowledgment terminology.
- Progress recorded as `guided`, score 96.

## Coaching

Teach the four-call handshake and specialized TLM connection, then run the
starter before edits. Review one handshake pair at a time.

## Verification

- Valid fixture passed at seed 1 with `completed=3`, zero UVM errors, and zero
  UVM fatals.
- Missing-`item_done()` fixture failed at the 1 us timeout as intended.
- Untouched learner starter compiled and elaborated, then failed on its absent
  driver request handshake as intended.

## Guardrails

- Use explicit calls, not sequence convenience macros.
- Do not add DUT timing yet.
- Require exactly one `item_done` per `get_next_item`.
