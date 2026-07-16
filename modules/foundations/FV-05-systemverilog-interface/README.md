# FV-05: Connect through a SystemVerilog interface

## Observable verification problem

FV-02 directly references eight module-level signals. Larger protocols may contain dozens of related pins shared by drivers, monitors, assertions, and DUT instances. An interface groups those signals behind one connection boundary; a virtual interface lets class-based testbench code refer to the concrete interface instance.

## Predict before coding

An interface instance contains signals. Does a virtual interface construct a second set of signals, or does it act as a handle to an existing interface instance? What happens if that handle is null?

## Your task

1. Complete directional `dut_mp` and `tb_mp` modports in `tb/alu_if.sv`.
2. Complete `alu_checker.check_case` using only its virtual interface—not hierarchical DUT references.
3. Construct the checker with the concrete interface instance.
4. Run at least one passing directed case.
5. Deliberately make one expectation incorrect and prove the checker returns a nonzero result; then restore it.

The testbench owns combinational timing: drive through the interface, wait a nonzero delay, then sample through the interface.

## Run

```powershell
cd "C:\Learning UVM\modules\foundations\FV-05-systemverilog-interface"
.\run.ps1
```
