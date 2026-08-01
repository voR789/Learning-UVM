# UA-06 reflection

Answer concisely after the learner run and fault fixture.

1. Why does the environment assign physical sequencer handles into the virtual
   sequencer instead of the virtual sequence searching the hierarchy?

- The environemnt assigns physical sequencer handles into the virtual sequencer so we can use the p_sequencer in the sequence, making things easier, not having to search for the physical handle

2. Which responsibilities belong to the virtual sequence, and which remain in
   the typed leaf sequences?

- The virtual seqeuencer simply holds the physical handles to the sequencers, and the virtual sequence delegates them, controling starting leaf sequences. The leaf sequences do the actual transaction level sending.

3. How does virtual coordination differ from protocol-layer translation?

- Virtual coordination schedules different interface sequences in one sequence, and protocol-layer-translation converts an abstract request (composite sequence), into lower level transactions (leaf sequences).

4. Which command reproduces the missing-data-handle failure, and why is
   `UA06_VSEQR` stronger evidence than a later data timeout?

- .\tests\run-fixture.ps1 -Test ua06_missing_data_handle_test reproduces the failure, and the UA06_VSEQR error is better evidence because it tells us specifically our virtual sequence was setup wrong, such that we know it's that causing the issue and not a stall somewhere else.
