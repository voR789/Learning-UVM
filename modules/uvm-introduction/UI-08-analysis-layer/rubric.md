# UI-08 rubric

Passing requires at least 75/100 and no critical correctness failure.

| Area | Points | Evidence |
|---|---:|---|
| Analysis publication and fault detection | 35 | Typed port is constructed; three correct items broadcast; missing consumer is detected. |
| Architecture and separation | 20 | Monitor knows no concrete consumers; subscriber and audit check independently. |
| Connection and broadcast semantics | 20 | Both endpoints connect in `connect_phase`; no blocking/request mechanism is introduced. |
| Reproducibility and diagnostics | 10 | Seed 1 run is deterministic and prints exact counts and result. |
| Analysis-versus-request reasoning | 5 | Explanation distinguishes broadcast from UI-06/UI-07 blocking coordination. |
| Reflection | 10 | Answers connect observation, routing, checking, failure localization, and reuse. |

Critical failures include direct consumer calls from the monitor, accepting
fewer than three checks at either consumer, or a testbench that can pass when a
required analysis connection is absent.
