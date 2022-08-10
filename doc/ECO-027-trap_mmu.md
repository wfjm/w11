# ECO-027:  trap_mmu fix (2015-12-30)

### Scope
- Introduced in release w11a_V0.71
- Affects: all w11a systems

### Symptom summary
  A mmu trap could be lost or vectored through 014 (bpt) rather 250 (mmu).

### Background
The PDP-11/70 and 11/45 MMU offers a 'mmu trap' feature, which can cause
a trap when a memory location is read or written. This can be enabled with
special `ACF` values in the page descriptor registers for each segment end
globally enabled with an enable bit in `MMR0`.

Since only 11/70 and 11/45 offer this (and J11 does not) this feature is
in general not used by operations systems.

Summary of issues:
When an instruction does more than one memory access and the mmu trap
condition occurs not on the last access
- an mmu trap could be missed
- an mmu trap might be vectored through 014 (the bpt vector)
The later happens for all read-modify-write accesses.

### Analysis
The `VM_STAT.trap_mmu` flag was copied into the `R_STATUS.trap_mmu` state bit
in `do_memcheck`, which is called for each memory wait. In case of a
read-modify-write the initial read will signal `trap_mmu`, while the
rmw completion will not (the mmu doesn't check on rmw completions).
This leads to
- lost mmu traps  (e.g. when mmu trap comes on 1st of 2 access)
- mmu traps vectored through 014 (the bpt vector)

The later happens due to the logic of state `s_opg_gen_rmw_w`:
- `do_memcheck` can clear `R_STATUS.trap_mmu`
- `do_fork_next` still branches to `s_trap_disp` because `R_STATUS.trap_mmu='1'`
- `s_trap_disp` sees `R_STATUS.trap_mmu='0'` and miscalculates the vector

### Fixes
`pdp11_sequencer` was modified to ensure that `R_STATUS.trap_mmu` is only set 
in `do_memcheck`. Same for `trap_ysv` (which had the same potential bug)

### Provisos
The issue was found by systematic testing of mmu fault and trap behavior.
Because known OS don't use mmu traps the issue should not have any impact
on practical usage with OS like rsx or 211bsd.
