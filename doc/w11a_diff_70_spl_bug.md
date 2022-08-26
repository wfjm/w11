## Known differences between w11a and KB11-C (11/70)

### Instruction fetch after `SPL`

The `SPL` instruction in the 11/70 always fetched the next instruction
regardless of current mode, pending device, or even console interrupts.
This is known as the infamous _SPL bug_, see
  - https://minnie.tuhs.org/pipermail/tuhs/2006-September/002692.html
  - https://minnie.tuhs.org/pipermail/tuhs/2006-October/002693.html
  - https://minnie.tuhs.org/pipermail/tuhs/2006-October/002694.html
  - https://minnie.tuhs.org/pipermail/tuhs/2006-October/002695.html
  - https://minnie.tuhs.org/pipermail/tuhs/2006-October/002701.html
  - https://minnie.tuhs.org/pipermail/tuhs/2006-October/002695.html
  - https://minnie.tuhs.org/pipermail/tuhs/2006-October/002702.html

In the w11a, the `SPL` has 11/70 semantics in kernel mode, thus no 
traps or interrupts, the instruction after the `SPL` is unconditionally
executed.
But in supervisor and user mode `SPL` really acts as `NOOP`, so traps and
interrupts are taken as for all other instructions.   

**--> The w11a isn't bug compatible with the 11/70.**
