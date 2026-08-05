# UA-G1 verification plan

The stable architecture and boilerplate are supplied. The three
requirement-specific decision cells were completed on 2026-08-04.

| Requirement | Stimulus | Passive observation | Independent expected result | Coverage intent |
| --- | --- | --- | --- | --- |
| Disabled command is rejected | Write `DATA=0x05` before enabling | Completed APB error response | `PSLVERR=1`; no command is accepted and no architectural state changes. | Error and `DATA` address observed |
| Normal multiplication | Enable, set gain 3, submit `0x20`, poll done, read result | Completed configuration, command, status, and result transfers | Accepted `DATA=0x20` with `GAIN=3` eventually produces `RESULT=0x60`, `overflow=0`, once `STATUS.done=1`. | Normal result class |
| Saturation | Set gain 4, submit `0x80`, poll done, read result | Completed gain, command, status, and result transfers | Accepted `DATA=0x80` with `GAIN=4` eventually produces `RESULT=0xFF`, `overflow=1`, once `STATUS.done=1`. | Saturated result class |

Drain condition: two successful `RESULT` reads checked by the passive
scoreboard.

Primary fault hypothesis: an incorrect arithmetic/result path must fail from a
monitored `RESULT` read through `UAG1_MISMATCH`.
