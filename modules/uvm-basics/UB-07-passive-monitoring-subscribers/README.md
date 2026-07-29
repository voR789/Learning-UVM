# UB-07: Passive monitoring and subscribers

## Reading checkpoint

You already implemented this architecture in UI-G1: a passive monitor sampled
the interface, published observed transactions through an analysis port, and
fed independent scoreboard and coverage consumers. Rebuilding it here would be
clerical repetition.

Read [resources/passive-analysis-broadcast.md](resources/passive-analysis-broadcast.md),
answer its prediction mentally, then rerun the supplied integration evidence:

```powershell
cd "C:\Learning UVM\modules\uvm-basics\UB-07-passive-monitoring-subscribers"
.\run.ps1
```

There is no required implementation or written reflection. The later UB-G1
integration module will require this architecture again without a supplied
solution.

## Completion

The checkpoint is complete when UI-G1 again reports 13 observed, checked, and
sampled transactions with full functional coverage and no UVM errors or fatals.
