# UI-05 Reflection

1. Why does the agent own driver and monitor while the environment owns predictor and scoreboard?
- The agent owns the DUT-facing protocol components, which consist of the driver and monitor. By centralizing the components that directly interact with the DUT pins, we can better separate the design from the rest of the testbench.
2. Why must passive mode retain the monitor but omit the driver?
- Passive mode retains the monitor because, during passive observation, the monitor still reads the DUT pins but does not drive anything. The driver should be omitted because it may conflict with another active agent.
3. Trace `agent_active` from the selected test to the agent's build decision.
- By selecting `ui05_active_test` with the simulation argument, UVM chooses `ui05_active_test` when executing `run_test()`. Inside the active test, we set `requested_active` to `1'b1` in the constructor. This variable is used in the test's build phase, where the configuration object's `agent_active` field is set from the test's `requested_active` field. The configuration object is then assigned to the environment during the same build phase. In the environment's build phase, `cfg.agent_active` is assigned to `agent.is_active` after the agent is constructed. The agent finally uses this field during its build phase to determine whether to construct the driver.
4. Why is one configured environment more reusable than separate active and passive environment classes?
- One configured environment is more reusable because we can use the same environment for both active and passive tests.
5. What transaction connections are still missing before this structure can move observations and expected results?
- We are still missing the connections between the monitor, predictor, and scoreboard. Right now, we have a skeleton that establishes the components but does not connect them.
