# UI-11 rubric

Passing requires at least 75/100 and no critical correctness failure.

| Area | Points | Evidence |
|---|---:|---|
| Reusable leaf sequence | 25 | Configurable loop produces correct items through explicit handshake. |
| Composite sequence | 25 | Two configured children start in order without duplicated item logic. |
| Driver protocol and checking | 20 | Six items checked and acknowledged exactly once. |
| Architecture and lifecycle | 10 | Factory construction, TLM connection, sequencer selection, objections. |
| Fault detection and reproducibility | 10 | Missing child times out; trace, seed, and report counts agree. |
| Reflection | 10 | Explains reuse, parent/child context, ordering, handshake, termination. |

Critical failures include bypassing the sequencer, duplicating leaf behavior in
the composite, missing/extra `item_done`, or accepting wrong item order.
