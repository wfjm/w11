## Known differences between w11a and KB11-C (11/70)

### The 'instruction completed flag' in `MMR0` is not implemented

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

Only the 11/70 and the 11/45 support this. No OS uses this.
And it's very difficult to construct a practical use case.

The w11a doesn't support the 'instruction completed' bit in `MMR1`. It is
always 0. And `MMR2` holds always the virtual address of the last instruction.

