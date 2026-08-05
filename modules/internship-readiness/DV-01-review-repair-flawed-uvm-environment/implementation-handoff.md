# DV-01 implementation handoff

## 2026-08-05 — creation milestone

- Roadmap contract: assessment, 180 minutes, prerequisite UA-G1, focused on code review, races, architecture, and root-cause analysis.
- Evidence-first novelty: UA-G1 already proves APB/RAL/agent/scoreboard/lifecycle integration. DV-01 assigns only the new analysis-handle snapshot invariant and the debug evidence chain.
- Learner ownership is preserved for `tb/dv01_pkg.sv`, debug plan, evidence summary, and reflection.
- The supplied starter intentionally reuses one mutable observation across two analysis writes. The independent FIFO scoreboard expects `3, 7`.
- Coaching must begin with one focused question and must not reveal the fault location before learner evidence.
- XSim 2025.2 seed-1 reference validation passed with `checked=2`, `mismatches=0`, distinct handles, and zero UVM errors/fatals.
- The direct reused-handle fixture failed nonzero through `DV01_MISMATCH` at index 0 and `DV01_RESULT` with `mismatches=1`.
- The fault fixture is independent of learner edits: it selects the known-bad publisher behavior inside the Codex-owned reference package.
- Curriculum progress remains unchanged at `current_focus: DV-01`; no DV-01 completion evidence exists.
