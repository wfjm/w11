# ECO-029:  `CPUERR` cleared by cpu reset (2016-12-27)

### Scope
- Was in w11a from the very beginning
- Affects: all w11a systems

### Symptom summary
- the `cpuerr` register is not cleared by a `$cpu cp -creset` command
- the `cpuerr` status can affect cpu behavior, e.g. yellow stack traps are
  only taken when the corresponding `cpuerr` flag is not set
- this makes tbench test execution on FPGA potentially depending on pre-history

### Fixes
Changed `pdp11_sequencer.vhd` to clear `cpuerr` with both general reset and 
with cpu reset.

### Side effects
None because this affects a very early phase of system startup.
