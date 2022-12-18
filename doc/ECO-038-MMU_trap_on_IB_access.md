# ECO-038: fix MMU trap after IB access; MMU logic cleanup (2022-12-18)

### Scope
- was in w11a since 2008
- affects: all w11a systems

### Symptom summary
When the IO page, in kernel mode by convention page 7, was mapped with MMU traps
enabled in `PDR` and `MMR0`, the AI bits on the `PDR` and the `trap_mmu` bit
in `MMR0` were set, but no MMU trap was taken.

### Analysis
The error was in `pdp11_vmbox`, the `VM_STAT` flag `trap_mmu` was only set in
the state that handles memory access, but not in the states that handle ibus
access.
Further code inspection revealed that the `pdp11_mmu` code handling traps was
functionally correct but not well structured.

### Changes
The `trap_mmu` flag is only inspected in `pdp11_sequencer` when `ack` is set.
It is therefore safe to set `trap_mmu` in all states of the `pdp11_vmbox` FSM.
Some logic in `pdp11_mmu` was restructured and is now more compact, but
stayed functionally equivalent.

### Hindsight
The MMU traps are not used by any OS, and therefore were not tested very
thoroughly.
This bug was only discovered a few months ago and resurfaced when the 'vector
push abort recovery' demonstrator was written.
