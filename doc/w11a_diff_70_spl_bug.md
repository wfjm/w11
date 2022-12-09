## Known differences between w11a and KB11-C (11/70)

### Instruction fetch after `SPL`

The `SPL` instruction in the 11/70 always fetches the next instruction
regardless of current mode, pending device, or even console interrupts.
This is known as the infamous _SPL bug_, see
  - https://minnie.tuhs.org/pipermail/tuhs/2006-September/002692.html
  - https://minnie.tuhs.org/pipermail/tuhs/2006-October/002693.html
  - https://minnie.tuhs.org/pipermail/tuhs/2006-October/002694.html
  - https://minnie.tuhs.org/pipermail/tuhs/2006-October/002695.html
  - https://minnie.tuhs.org/pipermail/tuhs/2006-October/002701.html
  - https://minnie.tuhs.org/pipermail/tuhs/2006-October/002695.html
  - https://minnie.tuhs.org/pipermail/tuhs/2006-October/002702.html

In the w11a, the `SPL` has 11/70 behavior in kernel mode, thus no
traps or interrupts, the instruction after the `SPL` is unconditionally
executed.
But in supervisor and user mode `SPL` really acts as `NOOP`, so traps and
interrupts are taken as for all other instructions.   

**--> The w11a isn't bug compatible with the 11/70.**

Drivers most likely do not depend on this specific `SPL` behavior.
It is not mentioned in Processor or Architecture Handbooks, only in
the 11/70 Technical Manual.
But some `xxdp` tests either explicitly check this, like `ekbbf0` test 032,
or use it to set up an _instruction under test_, like `ekbbf0` tests 035, 047.
So getting the kernel mode `SPL` behavior right is important for
passing `ekbbf0`.
