# ECO-040: fix CPUERR register rsv flag behavior (2023-01-11)

### Scope
- was in w11a since 2008
- affects: all w11a systems

### Background
The `CPUERR` register in an 11/70 has 6 flags that allow the cause of vector 4
abort to be determined. The bit 2 is referred to as _'Red Zone Stack Limit'_
in the 11/70 documentation. It is set when a stack limit error is detected.
Other address errors that escalate to a fatal stack error do not set this bit.
That leads to the `CPUERR` settings:

| Condition             | `hlt` | `odd` | `nxm` | `ito` | `ysv` | `rsv` |
| :-------------------- | :---: | :---: | :---: | :---: | :---: | :---: |
| odd address on kstack | 0 | 1 | 0 | 0 | 0 | 0 |
| nxm abort on kstack   | 0 | 0 | 1 | 0 | 0 | 0 |
| ito abort on kstack   | 0 | 0 | 0 | 1 | 0 | 0 |
| MMU abort on kstack   | 0 | 0 | 0 | 0 | 0 | 0 |
| yellow zone  trap     | 0 | 0 | 0 | 0 | 1 | 0 |
| red zone abort        | 0 | 0 | 0 | 0 | 0 | 1 |

The `CPUERR` register in the J11 has the same function, bit 2 has the very
similar name _'Red Stack Trap'_, and is set whenever a fatal stack error is
detected, and thus also when other address errors escalate to a fatal stack
error. That leads to different `CPUERR` settings:

| Condition             | `hlt` | `odd` | `nxm` | `ito` | `ysv` | `rsv` |
| :-------------------- | :---: | :---: | :---: | :---: | :---: | :---: |
| odd address on kstack | 0 | 1 | 0 | 0 | 0 | 1 |
| nxm abort on kstack   | 0 | 0 | 1 | 0 | 0 | 1 |
| ito abort on kstack   | 0 | 0 | 0 | 1 | 0 | 1 |
| MMU abort on kstack   | 0 | 0 | 0 | 0 | 0 | 1 |
| yellow zone  trap     | 0 | 0 | 0 | 0 | 1 | 0 |
| red zone abort        | 0 | 0 | 0 | 0 | 0 | 1 |

The key differences are:
- on an 11/70, an escalated MMU kernel stack abort will not set any
  `CPUERR` bits.
- on a J11, every stack error that causes an emergency stack will set the
  `rsv` bit.

### Symptom summary
The w11 implementation followed the SimH implementation that implements the
J11 behavior. This was discovered in a code review, no xxdp tests verify
`CPUERR` response in these cases.

### Analysis
None.

### Fixes
- add an additional return flag `err_ser` to `vm_stat_type`
- set `err_ser` in `pdp11_vmbox` for all fatal stack error conditions
- use `err_ser` in `pdp11_sequencer` to detect vector 4 and emergency stack
- use `err_rsv` in `pdp11_sequencer` to set the corresponding `CPUERR` flag.

### Hindsight
None.
