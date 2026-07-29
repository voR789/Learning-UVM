# UB-03: Connect an environment to the DUT safely

## Reading checkpoint

This concept is already evidenced by your passing UI-G1 integration test, so
there is no new implementation or reflection assignment.

Read [resources/virtual-interface-boundary.md](resources/virtual-interface-boundary.md).
The supplied command reruns the existing UI-G1 evidence.

```powershell
cd "C:\Learning UVM\modules\uvm-basics\UB-03-connect-environment-safely"
.\run.ps1
```

Completion rests on the behavioral boundary: the static top owns the physical
interface, configuration carries its virtual handle into UVM, and components
reject a missing required handle. Exact hierarchy strings are not graded.
