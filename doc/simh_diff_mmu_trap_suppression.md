## Known differences between SimH, 11/70, and w11a

### SimH: MMU traps not suppressed when MMU register accessed

The 11/70 does not execute an MMU trap and doesn't set A or W bits in `PDR`
when an MMU register is accessed, thus `MMR0` to `MMR3` and any of the
`PDR` and `PAR` registers.

SimH doesn't support this behavior.
xxdp program `ekbee1` tests 061 and 063 verify this behavior and are skipped
(see [patch](../tools/xxdp/ekbee1_patch_1170.scmd)).

w11 also doesn't support this behavior, this is documented as
[w11 known difference](w11a_diff_70_mmu_trap_suppression.md).

Tested with SimH V3.12-3.
