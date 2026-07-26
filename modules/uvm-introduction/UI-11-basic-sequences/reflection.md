# UI-11 reflection

Answer in your own words after the executable test passes.

1. Which behavior belongs to the leaf sequence, and which policy belongs to the
   composite sequence?
- The leaf sequence owns the low level sequence item based behavior, including the `start_item()` and `finish_item()` handshake. The composite sequence is the main sequence run, and owns instances of the leaf sequence, which run nested within the composite sequence.
2. Why must each child be configured before `start()`?
- Each child sequence must be configured before `start()` because the start function initiates the child sequence when it is called.
3. What do `m_sequencer` and the parent-sequence argument preserve when a child
   is started?
- `m_sequencer` preserves the same sequencer throughout the nested `start()` functions, such that the sequences with the same hierarchy are using the same sequencer. The parent sequence arguement preseves the nested hierarchy between sequences.
4. Which handshake call blocks in the missing-subsequence fixture, and why does
   the timeout expose it?
- `get_next_item()` blocks because it looks for 6 sequence items, but only finds 3. The timeout exposes it because since it blocks, the run phase can never end. 
5. What additional scenario could reuse the same leaf sequence without
   changing its `body()`?
- We could reuse the same leaf sequence for any scenario, as long as it uses the leaf node's increasing id and payload structure. For example, if we wanted to create 1000 ID's and payloads, starting from 10 and 40, we could use the same leaf node, configured differently.