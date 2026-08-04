# UA-G1 verification plan

The stable architecture and boilerplate are supplied. Complete only the three
requirement-specific decision cells before coding.

| Requirement | Stimulus | Passive observation | Independent expected result | Coverage intent |
|---|---|---|---|---|
| Disabled command is rejected | Write `DATA=0x05` before enabling | Completed APB error response | **TODO: state the pre-transfer rule** | Error and `DATA` address observed |
| Normal multiplication | Enable, set gain 3, submit `0x20`, poll done, read result | Completed configuration, command, status, and result transfers | **TODO: state expected result and model inputs** | Normal result class |
| Saturation | Set gain 4, submit `0x80`, poll done, read result | Completed gain, command, status, and result transfers | **TODO: state result and overflow expectation** | Saturated result class |

Drain condition: two successful `RESULT` reads checked by the passive
scoreboard.

Primary fault hypothesis: an incorrect arithmetic/result path must fail from a
monitored `RESULT` read through `UAG1_MISMATCH`.
