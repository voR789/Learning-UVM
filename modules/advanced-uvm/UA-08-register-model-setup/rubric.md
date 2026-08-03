# UA-08 rubric

Passing score: 75/100 with no critical frontdoor or mirror failure.

| Area | Points | Evidence |
|---|---:|---|
| Register-block construction | 25 | Control register is configured, built, mapped at offset `0x0`, and the model is locked. |
| Frontdoor integration | 25 | Default map uses the supplied sequencer and adapter. |
| Observed prediction | 20 | Completed bus items update the mirror through the configured predictor with auto-predict disabled. |
| Functional result | 15 | Stored DUT-model value and register mirror both become `0x5`. |
| Fault evidence | 10 | Wrong offset fails through `UA08_STATUS`. |
| Reflection | 5 | Learner explains model/map/adapter/predictor responsibilities and reproduction. |
