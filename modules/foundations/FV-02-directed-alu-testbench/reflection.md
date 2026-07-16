# FV-02 Reflection

Complete these in your own words after both the normal and deliberate-fault runs.

1. Why is seeing correct waveform values weaker evidence than a self-checking pass?
- Seeing correct waveform values is weaker evidence because waveform analysis must be performed manually and is prone to user error. A self-checking pass should be the first option, while waveform analysis should be used for debugging.
2. How does `check_case` separate stimulus, observation, expected behavior, and failure criteria?
- `check_case` separates stimulus by assigning values with blocking statements and observation by waiting 1 ns before checking the DUT outputs. The expected behavior is provided by the user when calling the `check_case` task, and the failure criterion compares the DUT outputs against the user-provided expected outputs.
3. What deliberate expected-value fault did you introduce, and what output proved the checker detected it?
- The expected-value fault I introduced was setting the expected invalid flag true for a valid operation, which caused error messages in the console and simulation output. The expected and actual invalid values were printed, `error_count` was 1, the terminal showed `TEST_RESULT: FAIL`, and the script returned a nonzero exit code.
4. Why does the testbench wait before sampling a combinational DUT?
- The testbench waits before sampling to allow the combinational logic to "settle." The simulator can execute testbench statements without advancing simulation time unless a timing control is encountered. If the testbench drives inputs and samples outputs in the same delta cycle, it can create a race in which the DUT has not yet updated its outputs.
