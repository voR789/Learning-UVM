# FV-G1 Implementation Handoff

Updated: 2026-07-21

## Resume read order

1. Repository `AGENTS.md`
2. `.agents/skills/uvm-learning-coach/SKILL.md`
3. `curriculum/progress.yaml`
4. This module's `module.yaml`
5. `spec/fifo-hardware-specification.md`
6. `plan/verification-plan.md`
7. This handoff
8. Learner-owned `tb/fifo_tb.sv`

The specification is authoritative. Preserve learner-owned source and use the
hint ladder unless direct repair is explicitly requested.

## Current status

- FV-G1 is the active foundations integration gate.
- The authoritative FIFO specification contains 34 unique normative
  requirements.
- The verification plan contains eight rows and references all 34 requirements
  with no unknown IDs.
- Planning is complete enough to guide implementation.
- Substantial direct assistance was used to finish the simultaneous,
  full-recovery, and wraparound rows, so the planning evidence is guided.
- The learner has implemented a substantial first draft of `tb/fifo_tb.sv`:
  directed scenario tasks, request/observation structs, mailbox-based driver,
  passive monitor, queue-based predictor, scoreboard, constrained-random
  request draft, and functional-coverage model.
- Compile-only checks have been run repeatedly with Vivado/XSim 2025.2
  `xvlog -sv`. The latest check on 2026-07-21 reaches the covergroup and fails
  at `tb/fifo_tb.sv:90` because the `wr_rd` cross-bin expression and cross
  block have their semicolon in the wrong place. The expression needs its
  terminator before the closing brace; the cross block does not take a
  trailing semicolon.
- The latest compile also reports non-fatal lifetime warnings for the local
  `req_rand` and covergroup instance `cg`. No elaboration or simulation of the
  learner draft has succeeded yet.
- Before the learner edits, the starter compiled and elaborated in XSim 2025.2
  at seed 1, then intentionally failed at the 10 us zero-check timeout.
- FV-G1 has no completion score or gate result.

## Accepted architecture decisions

- FV-G1 remains plain SystemVerilog; do not introduce UVM objections, phases,
  factory, sequencers, or analysis ports.
- Keep stimulus intent separate from timed pin driving.
- A request transaction represents one intended interface operation.
- The minimal request tag may contain only normal and end-of-stream values;
  request fields carry `rst`, `wr_en`, `rd_en`, and `wdata` intent.
- Request and observed transaction types are separate and use fresh instances
  or independent value copies.
- The current transaction types are unpacked structs. Mailbox `put()` copies
  their values; they are not class handles and do not require `new()`.
- Only the driver writes DUT input pins.
- The monitor passively captures request inputs at the active edge and DUT
  outputs after sequential updates settle, publishing one completed
  observation per relevant edge.
- The predictor derives expected acceptance and state only from observed inputs
  plus its independent pre-edge model state. DUT `full`, `empty`, and `count`
  are comparison targets, not prediction oracles.
- The scoreboard compares model-derived expectations with observed outputs.
- Request-to-observed-input consistency may be checked separately to localize
  driver or timing defects.
- Blocking mailbox `get()` inside a consumer loop is preferred. An ordered
  end-of-stream request may stop the driver. The monitor and scoreboard may run
  as background consumers until explicit completion.
- The learner selected a one-bit `is_end` control field rather than an enum.
  A request with `is_end=1` is a separate driver control marker and does not
  represent a DUT operation.
- Current driver/monitor termination intent is accepted: after driving the
  final normal request at a falling edge, the driver receives the ordered end
  marker, sets persistent `driver_done`, waits until the next falling edge,
  and idles the DUT inputs. The intervening rising edge executes exactly the
  final normal request.
- At that intervening rising edge, the monitor captures and publishes the
  final normal observation after the 1 ns settling delay, increments
  `monitor_count`, then publishes a separate observation end marker when
  `driver_done && monitor_count == stimulus_count`, and breaks. Normal data
  must remain ordered before the marker in both monitor mailboxes.
- Predictor and scoreboard must inspect an observation marker before using its
  payload. The predictor should forward an ordered prediction marker without
  updating the model or sampling coverage; the scoreboard should consume the
  paired markers only after all preceding normal pairs have been checked.
- UVM objections are intentionally deferred to the later UVM curriculum.
- Assertions implement focused local and temporal invariants from
  `FIFO-GLOBAL-01`; the scoreboard still owns DUT-versus-model comparison.
- Coverage samples completed observations and proves scenario occurrence, not
  correctness.
- The functional-coverage model uses a module-scope covergroup type with a
  predictor-local instance and custom `sample()` arguments. It samples reset,
  request enables, independently predicted acceptance, and pre-update model
  occupancy. Sampling occurs before queue mutation. XSim accepts the custom
  `with function sample` construct, although TerosHDL 7.0.3's default iStyle
  formatter indents it incorrectly.
- Final pass requires the plan's completion invariant; `error_count == 0`
  alone is insufficient. Timeout remains an independent failure path.

## Learner source currently contains

- Complete directed stimulus-task drafts for reset, fill/drain, rejected read,
  simultaneous operation, full recovery, and repeated wraparound scenarios.
- A randomized-request class draft with reset distribution and conversion into
  the request struct.
- Request and observation structs with one-bit end markers and four untyped
  mailboxes.
- A falling-edge driver and rising-edge/passive monitor with final normal
  observation followed by a separate monitor marker.
- An independent predictor using a SystemVerilog queue and persistent expected
  `rdata`, plus a field-wise scoreboard.
- A custom-sample covergroup for reset, enables, acceptance, and pre-edge
  occupancy. The no-operation cross exclusion is the current compile blocker.
- No completed predictor/scoreboard marker handling, orchestration, assertions,
  final pass/fail accounting, or successful learner-code simulation yet.
- The original starter reset-driving process still writes DUT inputs and must
  be removed or reworked before enforcing sole driver ownership.

These are learner-owned attempts. Begin any review with findings and questions;
do not silently replace them.

## Next implementation milestone

Finish and execute the reset-only vertical slice before running the full suite:

1. Correct the cross-bin terminator at `tb/fifo_tb.sv:87-90`, using
   `ignore_bins` rather than `illegal_bins` if idle is legal but excluded from
   required coverage, and rerun compile-only validation.
2. Add predictor and scoreboard handling for the separate ordered observation
   and prediction end markers. Markers must bypass coverage, model mutation,
   and payload comparison.
3. Add a main orchestration process that initializes inputs, launches driver,
   monitor, predictor, and scoreboard, runs only `run_reset_basic()`, enqueues
   the request end marker, and waits for scoreboard completion.
4. Remove the competing starter reset-driving process so only the driver owns
   DUT inputs after initialization.
5. Require at least one real reset observation/check, zero errors, drained
   marker flow, and an explicit pass result while preserving the independent
   timeout failure path.
6. Compile, elaborate, and simulate the reset slice with XSim 2025.2. Diagnose
   scheduling behavior before enabling the remaining directed scenarios.

After the reset slice passes, run scenarios in verification-plan order, add
the global assertions, close required coverage, demonstrate fault detection,
and complete evidence/reflection artifacts.

## Coaching emphasis for the next chat

- Prefer diagnostic questions and governing invariants.
- The learner explicitly prefers guided hints over complete code. Give one
  hint-ladder level at a time unless stronger help is requested.
- For simple syntax review, inspect source without running XSim.
- Run XSim for scheduling, concurrency, compatibility, integration, fault, or
  completion evidence.
- Do not reveal seeded DUT defect locations before learner diagnostic evidence.
- Record the same failing seed after every random-failure repair.
