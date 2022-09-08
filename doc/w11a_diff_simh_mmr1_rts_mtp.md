## Known differences between w11a and a SimH 11/70

### SimH: implicit stack pops not recorded in MMR1

The MMU abort behavior for instructions with implicit stack pops
(`RTS`, `MTPI`, `MTPD`) differs on SimH from w11 and a real 11/70.
SimH updates the stack pointer _after_ the stack value has been
read. If this read is aborted by the MMU, the state is `SP` unchanged
and `MMR1` zero. w11 and a real 11/70 update `SP` and record that in
`MMR1` before the stack value is accessed and an MMU abort detected.
In both cases the register change state and the `MMR1` state
are consistent, so MMU vector 250 handlers will work correctly.

This difference is only detected in test codes.
