# FV-G1 Evidence Summary

Complete this during verification and debug.

## Runs

| Test intent | Seed | Expected result | Actual result | Evidence |
|---|---:|---|---|---|
| Starter baseline | 1 | FAIL: no checks | FAIL | `check_count` = 0 |
| Known defective DUT | 1 | FAIL: full boundary error | FAIL | Time:  146000 ps, Expected `full`: 0, Observed `full`: 1 |
| Repaired DUT | 1 | PASS | PASS | TEST_RESULT: PASS, Coverage percent = 100, `error_count` = 0 |


## Coverage closure

- Initial holes: Simultaneous `wr_en` and `rd_en` at various occupancies
- Purposeful closure stimulus: `run_sim_all()` tests simultaneous read/write at every occupancy of the model.
- Final reachable coverage: 100%
- Exclusions and specification justification: Exclude idle operations such as `wr_en == 0 && rd_en == 0`  from coverage.

## Defect evidence

- Reproducing test and seed: `run_empty_full()`, `.\run.ps1 -Seed 1`
- First observable mismatch or assertion: `full`, 146000 ps
- Governing FIFO invariant: FIFO must assert `full` when `count == DEPTH` 
- Why this is a DUT defect rather than a testbench defect: DUT incorrectly asserts full when count = DEPTH-1, which doesn't match the hardware specification.
