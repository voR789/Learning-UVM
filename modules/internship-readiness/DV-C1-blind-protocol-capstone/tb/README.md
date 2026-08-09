# Learner-owned testbench

Build your UVM environment here. No class skeleton is supplied: choosing the
transaction boundaries and component responsibilities is part of the capstone.

The supplied top expects a package named `dvc1_tb_pkg` containing tests named
`tcs_smoke_test`, `tcs_reset_test`, `tcs_op_test`, `tcs_protocol_test`, and
`tcs_stress_test`. Add source files to the learner source list in `run.ps1` as
your compile order grows.
