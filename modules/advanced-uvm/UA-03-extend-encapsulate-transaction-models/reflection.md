# UA-03 reflection

Answer concisely after the learner run and fault fixture.

1. What state would be lost if a derived transaction copies its fields but
   omits the base copy?

- The address and kind states would be lost if the derived transaction omitted the base copy.

2. Why does derived validation call the base validation rather than replacing it?

- The dervied validation calls the base validation to abstract the base class's own internal checking from the derived class, and to re-use the checker we have already made.

3. Why are configuration/query methods preferable to exposing transaction fields
   to every caller?

- Methods are more preferable because they provide a layer of abstraction that simplifies code and makes it reusable. We also prevent callers from creating invalid states, by leaving it to methods, we have a layer of security about our transactions.

4. Which command reproduces the extension-loss failure, and what does it prove?

- The .\tests\run-fixture.ps1 -Test ua03_extension_loss_test command reproduces the failure, and it it proves that our testbench correctly detects a lost extension state.
