# UI-10: Add functional coverage to transaction observation

## Observable problem

UI-08 proved that transactions can reach independent consumers, but receiving
traffic does not prove the intended scenarios occurred. A coverage model must
translate verification requirements into measurable bins and sample the
monitor's completed observations—not driver intent or arbitrary clock cycles.

## Mental model

```text
publisher.ap.write(observation)
        |
        +--> coverage_subscriber.analysis_export
                    |
                    +--> write(observation)
                           copy sampled fields
                           coverage.sample()
                           increment sample_count
```

The publisher knows only that it broadcasts observations. The coverage
subscriber owns coverage intent and sampling policy. Read
[reading/coverage-subscriber-mental-model.md](reading/coverage-subscriber-mental-model.md)
and the separate [worked example](worked-example.md) before editing.

## Coverage contract

Each observation contains:

- `operation`: `0=READ`, `1=WRITE`, `2=FLUSH`, `3=STATUS`
- `result_zero`: whether the observed result is zero

The model must contain:

- `cp_operation` with four explicit named bins.
- `cp_result_zero` with explicit `zero` and `nonzero` bins.
- `cx_operation_zero`, the full cross of both coverpoints.
- `option.per_instance = 1`.

The publisher emits all eight operation/result-class combinations exactly once,
so the required result is eight samples and 100% instance coverage.

## Prediction — answer before editing

If all four operation bins and both result-class bins are hit, but
`READ/nonzero` never occurs, can the two coverpoints look complete while the
cross remains incomplete? What requirement does the cross represent?

## Hands-on task

Complete the ten TODO regions in [tb/ui10_pkg.sv](tb/ui10_pkg.sv):

- implement the covergroup bins and cross;
- construct the analysis port and embedded covergroup instance;
- publish all deterministic transaction combinations;
- implement the subscriber's `write()` sampling path;
- build and connect the environment;
- implement objection, coverage, report-count, and final-verdict logic.

This deliberately reuses UI-08 analysis and FV-07 covergroups with less
scaffolding. The learner owns the executable architecture, not just one syntax
line.

## Run

```powershell
cd "C:\Learning UVM\modules\uvm-introduction\UI-10-analysis-coverage"
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\run.ps1
```

## Constraints

- Sample only inside the coverage subscriber's `write()` function.
- Sample exactly once per received transaction.
- Do not sample publisher intent separately.
- Do not call the subscriber directly.
- Keep all analysis routing in `connect_phase`.
- Do not weaken the required eight samples or 100% coverage.
- Consumers must not mutate the received transaction.

## Exact pass/fail criteria

Pass requires `published=8`, `samples=8`, `coverage=100.00`, zero UVM
errors/fatals, `COVERAGE_TRACE`, and `TEST_RESULT: PASS`. Any missing cross
combination, incorrect sample count, compile/elaboration error, timeout, UVM
error/fatal, or missing pass marker fails.
