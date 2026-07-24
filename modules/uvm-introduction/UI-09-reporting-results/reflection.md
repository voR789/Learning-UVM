# UI-09 reflection

Answer in your own words after the executable test passes.

1. Why is the retry case a warning while an unapproved mismatch is an error?
- The retry case is a warning because, according to our specification, it is abnormal but intentionally recoverable behavior. The unapproved mismatch is an error because it is not recoverable as defined by the specification, which means verification correctness failed.
2. What changes when reporter verbosity moves from `UVM_MEDIUM` to `UVM_HIGH`,
   and what must not change?
- The `UVM_INFO` reports made by the reporter are filtered by the verbosity level. When it moves to `UVM_HIGH`, it shows the UVM reports marked with high verbosity. However, the warning, error, and fatal counts remain the same regardless of the verbosity level.
3. Why are stable report IDs more useful than encoding categories only in
   prose?
- A stable report ID provides a standard, easily searchable classification for the error, allowing us to sort and search for error categories by report ID. The prose provides the detailed report.
4. Which local and global evidence jointly authorizes `TEST_RESULT: PASS`?
- The local evidence from the match, retry, mismatch, and detail counts, together with global UVM reporting evidence such as the warning, error, and fatal counts, determines the verdict.
5. Why does the known-bad fixture fail even though it prints a pass marker?
- It emits a UVM error, which the runner checks when deciding whether the run passed.
