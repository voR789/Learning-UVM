# UA-09 hints

Use one level at a time.

1. Which operation must obtain evidence from implementation storage before RAL's belief can be changed responsibly?
2. `predict()` does not read anything. It needs a value supplied by an observation path.
3. Inspect the three bounded virtual methods in `tb/ua09_pkg.sv`.
4. First read through the supplied backdoor, then predict the observed value. Separately stage desired state and commit it through the frontdoor.
5. The learning resource gives the exact signatures for the four required API calls.
