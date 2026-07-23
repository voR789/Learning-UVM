# UI-03 Rubric

| Area | Points | Evidence |
|---|---:|---|
| Package organization and compile order | 25 | Package precedes consumer and learner explains why import cannot repair reversed order |
| Imports and includes | 20 | UVM declarations and macro definitions are made available by the correct distinct mechanisms |
| UVM object registration | 25 | Correct object utility macro supplies type_id construction without modifying the caller |
| Construction evidence | 10 | Created object retains required name and value and emits explicit pass evidence |
| Diagnostic reasoning | 10 | Learner classifies missing package, missing macro, and missing registration failures |
| Reflection | 10 | Answers distinguish source organization, preprocessing, registration, and runtime construction |

Passing requires at least 75 points, a passing XSim run, and no critical
misconception such as treating import as compilation or registration as object
construction.
