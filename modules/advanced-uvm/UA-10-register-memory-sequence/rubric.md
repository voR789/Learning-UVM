# UA-10 rubric

Passing score: 75/100 with no memory-independence or checking failure.

| Area | Points | Evidence |
|---|---:|---|
| Reusable register sequence | 20 | Memory behavior is implemented in `uvm_reg_sequence::body()` using the supplied model handle. |
| Indexed memory stimulus | 20 | Distinct patterns are written to logical indices 0 and 1 through the frontdoor. |
| Independent readback checking | 30 | Every status and returned value is checked against retained expectations; verified increments only after matches. |
| Fault and access evidence | 20 | Address aliasing fails, and read/write counts prove both indices and access directions were exercised. |
| Reflection and coverage reasoning | 10 | Learner explains memory indexing, sequence reuse, independent expectations, and why a coverage flag alone creates no coverage model. |
