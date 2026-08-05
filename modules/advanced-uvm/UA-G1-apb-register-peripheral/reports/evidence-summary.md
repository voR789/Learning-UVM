# UA-G1 evidence summary

Complete after the learner and fault runs.

- Learner command: .\run.ps1 -Seed 1
- Test and seed: Normal test, seed 1
- Passing trace: [UA-G1] PASS: test=ua_g1_test seed=1, UAG1_TRACE checked=2 mismatches=0 observed=10 driven=10 polls=1 coverage_samples=10
- UVM errors/fatals: None
- Direct fault command: powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\tests\run-fixture.ps1 -Test ua_g1_fault_test -Seed 1
- First meaningful fault diagnostic: UAG1_MISMATCH, RESULT: expected=0x60 observed=0x61
- Coverage evidence: For passing test: 100%, For direct fault: 87.5%
- Why the fault result is independent of sequence intent: The fault result is independent of the sequence intent because out scoreboard is independent from the sequence checking, and uses its own model to check the DUT.
