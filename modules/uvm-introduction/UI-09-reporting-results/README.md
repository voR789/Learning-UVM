# UI-09: Control UVM reporting and end-of-test results

## Observable problem

A simulation can reach `$finish` and even print “PASS” while UVM has already
reported a serious verification failure. Conversely, indiscriminate printing
makes useful diagnostics disappear in noise. A reusable testbench needs a
report policy and an end-of-test verdict derived from evidence.

## Mental model

Every UVM report answers three separate questions:

1. **ID:** What category produced this message?
2. **Severity:** What does it mean for correctness?
3. **Verbosity:** Should this informational detail be visible at the selected
   diagnostic level?

Warnings, errors, and fatals are severity decisions; verbosity does not hide
them. At end of test, the report server provides accumulated severity counts.
The test combines those counts with component-owned functional counts before
printing a pass marker.

Read [reading/reporting-mental-model.md](reading/reporting-mental-model.md) and
the separate [worked example](worked-example.md) before editing.

## Deterministic contract

The reporter evaluates four observations:

| case | observed | expected | retry allowed | classification |
|---:|---:|---:|:---:|---|
| 0 | 10 | 10 | no | match |
| 1 | 14 | 15 | yes | recoverable warning |
| 2 | 20 | 20 | no | match |
| 3 | 25 | 25 | no | match |

Required local counts are `matches=3 retries=1 mismatches=0`. Required global
counts are `warnings=1 errors=0 fatals=0`. The reporter verbosity is
`UVM_MEDIUM`, so low-level results are visible and high-detail messages are
filtered.

## Prediction — answer before editing

If a test prints `TEST_RESULT: PASS` after one `uvm_error`, should the shared
runner accept the run? Which evidence is authoritative?

## Hands-on task

Implement the TODO regions in [tb/ui09_pkg.sv](tb/ui09_pkg.sv). You own both:

- **Report production:** classify each observation, emit reports with the
  required IDs/severities/verbosity, and maintain functional counts.
- **Verdict production:** create/configure the component, manage the objection,
  query the report server, validate exact counts, and print the final trace and
  pass marker only when all invariants hold.

This is intentionally denser than UI-08. You will implement control flow and
end-of-test policy, not merely connect existing endpoints.

## Run

```powershell
cd "C:\Learning UVM\modules\uvm-introduction\UI-09-reporting-results"
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\run.ps1
```

## Constraints

- Do not replace UVM reporting with `$display`.
- Do not downgrade a true mismatch to a warning.
- Do not use verbosity to suppress warnings/errors/fatals.
- Do not clear or reset report-server counts.
- Do not print `TEST_RESULT: PASS` before checking all local and global counts.
- Preserve the deterministic cases and expected counts.

## Exact pass/fail criteria

Pass requires:

- compilation, elaboration, and simulation succeed at seed 1;
- exactly 3 matches, 1 retry warning, and 0 mismatches;
- global UVM counts are exactly 1 warning, 0 errors, and 0 fatals;
- high-detail informational reports are filtered at `UVM_MEDIUM`;
- `REPORT_TRACE` and `TEST_RESULT: PASS` are printed.

The run fails on any compile/elaboration error, timeout, missing marker,
incorrect count, UVM error, or UVM fatal. The known-bad fixture must fail even
though it deliberately prints a pass marker.
