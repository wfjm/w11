## Known differences between SimH, 11/70, and w11a

### SimH: MMU aborts have priority over NXM aborts

Let's assume a case where two address errors are present:
- the MMU rejects the access
- the MMU translated physical address is located in non-existent memory

In the KB11-C processor, the NXM condition is handled before the MMU condition.
This leads to the surprising situation that the access is aborted with a
vector 4 flow rather than a vector 250 flow.

SimH verifies the MMU abort condition first. xxdp `ekbee1` test 122 verifies
the 11/70 behavior and is patched.

w11 also doesn't support this behavior, this is documented as
[w11 known difference](w11a_diff_70_mmu_nxm_prio.md).
