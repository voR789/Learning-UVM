# UI-G1 integration rubric

Passing requires at least 80/100 and no critical correctness failure.

| Area | Points |
|---|---:|
| Stimulus, driver, and handshake correctness | 20 |
| Passive observation and timing | 20 |
| Independent prediction and fault detection | 20 |
| Coverage intent and sampling | 15 |
| Architecture, reuse, and connections | 10 |
| Completion, reporting, and reproducibility | 10 |
| Plan and reflection | 5 |

Critical failures include checking driver intent instead of monitor observation,
sampling stale count values, missing the faulty DUT, duplicated acknowledgments,
or printing PASS with incomplete evidence.
