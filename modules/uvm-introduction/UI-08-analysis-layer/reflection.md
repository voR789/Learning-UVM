# UI-08 reflection

Answer in your own words after the executable test passes.

1. What observable failure did the missing-subscriber fixture expose, and why
   did UVM not automatically reject a zero-listener branch?
- The missing-audit fixture exposed that we did not connect the analysis port to the audit correctly. UVM did not reject this because zero connections are legal for an analysis port.
2. How are observation, publication, routing, and checking separated here?
- These actions are separated into the different components. In this exercise, the monitor generates transaction observations and sets the id and payload before publishing them. The routing is handled by the analysis layer and the connection with `monitor.obs_port`. The checking is separated into the subscriber and the audit components.
3. Why can one `write()` call reach both consumers without a FIFO,
   `item_done()`, or response?
- One `write()` call can reach both consumers because the port was specified to be the `uvm_analysis_port`, which has the unique policy of being a port that can connect to any component with compatible `analysis_export` or `uvm_analysis_imp` endpoints. The analysis protocol does not include a request or completion handshake.
4. What symptom or count helped you localize your first failed attempt?
- The mismatch among `published`, `subscriber_checks`, and `audit_checks` helped me identify the issue.
5. In a larger environment, what additional independent analysis consumer
   could be added without changing the monitor?
- In a larger environment, we could also include coverage collectors, predictors, and other independent consumers because the analysis layer lets us connect multiple consumers to the monitor's single analysis port.
