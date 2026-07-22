# Valid UI-01 mapping fixture

| FV-G1 responsibility | Evidence in FV-G1 | Proposed UVM responsibility | Why this boundary remains useful |
|---|---|---|---|
| Request intent | request | transaction object | Keeps data separate from pin timing |
| Timed pin driving | driver | active driver role | Gives one owner to active pins |
| Passive observation | monitor | passive monitor role | Publishes what happened independently |
| Independent prediction | predictor | reference model role | Derives expectations from the specification |
| Correctness checking | scoreboard | checking role | Compares expected and observed transactions |
| Scenario coverage | covergroup | coverage role | Measures scenario occurrence separately |
| Test orchestration and termination | main | test role | Coordinates scenario and completion |

1. Prediction
   - Active driver role
2. Prediction
   - Reference model role
