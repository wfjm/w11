## Known differences between SimH, 11/70, and w11a

### SimH: The 'instruction completed flag' in `MMR0` is not implemented

All PDP-11 processors with a fully functional MMU (11/45, 11/70, 11/44, and J11)
support the re-execution of an instruction after an MMU abort.
`MMR2` holds the virtual address of aborted instruction and `MMR1` holds
information about register changes. This can be used by a handler to roll back
the register changes and restart the instruction. This can be used to
implement demand paging or dynamic extension of stack segments.

The 11/70 and 11/45 are the only PDP-11 processors that also support the
recovery of an MMU abort of a stack push during trap or interrupt processing.
To distinguish between an instruction and a trap processing abort the
`MMR1` has a bit called `instruction completed`. It is will be set to 0
whenever an instruction is aborted and is 1 after a trap service flow is
aborted. The `MMR2` contains the vector address in the latter case.

SimH does not support the `MMR0` `instruction completed` flag and the
associated `MMR2` behavior.
xxdp program `ekbee1` test 067 verifies this behavior and is skipped
(see [patch](../tools/xxdp/ekbee1_patch_1170.scmd)).

w11 supports `instruction completed` with some minor implementation differences,
see [w11 known difference](w11a_diff_70_instruction_complete.md).
This is verified in a [tcode](../tools/tcode/README.md), the tests are skipped
when executed on SimH
(see [cpu_mmu.mac](../tools/tcode/cpu_mmu.mac) test C2.6 and D2.1).
