# UB-G1 supplied verification plan

Planning was already demonstrated in FV-G1 and is not repeated as learner work.

| Scenario                   | Stimulus and response decision                                   | Passive checks                                             | Coverage intent                             |
| -------------------------- | ---------------------------------------------------------------- | ---------------------------------------------------------- | ------------------------------------------- |
| Reset priority             | Reset with read and write asserted                               | Queue clears; outputs reach reset state                    | Reset observed                              |
| Adaptive fill              | Write distinct values until a response reports full              | Every legal write accepted; count/full match model         | Occupancies 0 through DEPTH; full boundary  |
| Blocked write and recovery | Attempt a full-state write, read once, then write recovery value | Blocked sentinel absent; recovery value appears in order   | Blocked write and full-to-not-full recovery |
| Simultaneous operation     | At intermediate occupancy, request read and write together       | Oldest value returned; new value appended; count unchanged | Simultaneous accepted read/write            |
| Adaptive drain             | Read until a response reports empty, then attempt one extra read | Ordered drain; rejected read retains state and rdata       | Empty boundary and blocked read             |
| Wrap transfer              | Refill after partial drain and drain again                       | No loss, duplication, or reorder across reused positions   | Repeated full/empty and every occupancy     |

## Completion invariant

- The sequence receives one response per request and reaches its bounded stop.
- The driver and monitor operation counts agree.
- The scoreboard checks every published operation and drains its model queue.
- Required coverage is 100 percent.
- UVM error and fatal counts are zero for the known-good DUT.
- The faulty DUT fails specifically through `UBG1_MISMATCH`.
