# UA-08 reflection

Answer in your own words after the learner and fault runs.

1. What information belongs in the register block and map rather than in each
   test?

- The register block owns the register and field definitions, while the map owns bus addressing, byte width, endianess, and access mapping. This information lives there because this data is constant to the DUT.

2. What does the adapter translate in each direction?

- The adapter translates from a bus operation to a bus item that can be understood by the verification side, and vice versa with the DUT side. `reg2bus` converts the RAL operation into a valid bus item, whilst `bus2reg` converts the bus item from the DUT to a valid RAL operation.

3. Why is automatic prediction disabled in this exercise?

- Automatic prediction is disabled in this exercise because we want to test based off of the actual operations that happen to the register buses, and not the intention from the `write()` or `read()` calls.

4. Why does the wrong-offset fixture fail even though the register field
   definitions are correct?

- The wrong offset fails because it uses the wrong offset value for the register bus, which shift's the map's definition of where the register fields are, leading them to be off, leading the frontdoor access to the wrong address.

5. Give the exact command that reproduces the wrong-offset failure.

- .\tests\run-fixture.ps1 -Test ua08_wrong_offset_test
