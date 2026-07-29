# UB-06 Implementation Handoff

Updated: 2026-07-28

## Status

- UB-06 is complete with guided evidence.
- The learner package passes XSim 2025.2 at seed 1 with three verified responses.

## Scope decision

- UI-G1 already established `start_item`/`finish_item`,
  `get_next_item`/bare `item_done`, composed sequences, and test objections.
- UB-06 does not repeat those as its lesson. Its new invariant is returning an
  identified response and validating that response in the sequence.
- Component structure and test lifetime are supplied; the learner owns the two
  new behavioral decisions.

## Prerequisite resource

- `resources/request-response-flow.md` teaches the problem, mental model,
  unrelated example, invariant, base-handle cast, and one prediction before the
  learner TODO.

## Verification boundary

- The valid fixture must verify three responses.
- The negative fixture preserves routing identity but returns the wrong result;
  it must fail with `UB06_RESPONSE`.
- Exact object names and report strings are not learner requirements.
- XSim 2025.2 seed 1 passed the valid fixture with three verified responses,
  rejected the wrong-result fixture with `UB06_RESPONSE`, and rejected the
  learner starter at its intentional `UB06_TODO`.
- The completed learner implementation copies UVM routing identity and
  request fields into a separate response, then checks result and tag against
  the originating request.
