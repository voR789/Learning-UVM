# Reflection — learner owned

1. What was the first symptom, and what evidence separated it from the root cause?

   - The first symptom was the mismatch of the subscriber recieving the second transacation data instead of the first one. index=0 expected=3 observed=7 handle=455. The evidence that separated it from the root cause was that the subscriber passes for the second transaction on it's second process, which makes it more likely the subscriber works, and the issue is somewhere else.
2. How did object identity and field values localize the violated boundary?

   - The object identity and field values localized the violated boundary by providing the exact scope of where the issue came from, and showed that the handle was the same.
3. Why is changing the scoreboard expectation or suppressing the mismatch an invalid repair?

   - Changing the scoreboard expectation or suppressing the mismatch an invalid repair because it's not solving the root problem. Slapping band aids on it won't help us verify a correct DUT.
4. Which exact command and seed reproduce the known fault?

   - ./run.ps1 -Seed 1 -PackagePath ./tests/reused_handle_fault_pkg.sv
5. What ownership rule would you document for a larger reusable monitor/analysis environment?

*     I would say the monitor should own all transaction indexing issues.
