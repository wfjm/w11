# ECO-037: implement MMR0,MMR2 instruction complete (2022-12-16)

### Scope
- was in w11a since 2008
- affects: all w11a systems

### Symptom summary
Test 067 of `ekbee1` ends in an infinite loop.

### Analysis
The 11/70 supports the recovery of MMU aborts in the push phase of a vector
flow. The documentation of this feature is scarce and in some places
misleading or just plain wrong. What is actually done is quite simple:
- an MMU abort during a push to a non-kernel stack during a vector flow
  sets bit `MMR0(7)` to '1' and `MMR2` to the vector address.
- a vector push abort to the kernel stack is converted into a fatal stack error.
- all other MMU aborts set `MMR0(7)` to '0' and `MMR2` to the address of the
  aborted instruction.

The bit `MMR0(7)` is named `instruction complete` in the DEC documentation.
That's technically correct but highly misleading.
A much better name would have been `vector push abort`, because that's what
this flag signifies.

The 11/70 sets `MMR0(7)` only for aborts, traps and interrupt flows, but not
in vector flows started via the trap instructions `BPT`, `IOT`, `EMT` and
`TRAP`.

### Changes
To simplify things, the w11 handles all vector flows uniformly, trap
instructions have no special treatment as in the 11/70. With this,
the implementation of the `instruction complete` feature is quite simple.

The `MMR0(7)` bit is loaded in each cycle from the `cpu_status` state flag
`in_vecfow` if the `MMR0` abort status bits are not locked. This ensures that
the bit is '1' after a vector push abort and '0' in all other cases.

The `MMR2` register is loaded from the virtual address
- at the beginning of vector flow in state `s_vec_getpc` (VA = vector address)
- at the beginning of an instruction fetch (VA = instruction address)

### Hindsight
This is the most mysterious feature of an 11/70. It was only exercised in one
xxdp test and never used. Because of poor documentation, it took a long time to
understand what it really does and what it can be used for. Nevertheless,
the goal of the w11 is to be an as precise as feasible replica of the 11/70,
and it was time to finally implement this esoteric feature.
