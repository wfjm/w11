# Summary of known differences and limitations for w11a CPU and systems

This file describes the differences and limitations of the w11 CPU and systems.
The issues of the w11 CPU and systems are listed in a separate document
[README_known_issues.md](README_known_issues.md).

### Table of content

- [Known differences between w11a and KB11-C (11/70)](#user-content-diff)
- [Differences in unspecified behavior cases between w11a and
  KB11-C (11/70)](#user-content-unspec)
- [Known limitations](#user-content-lim)

### <a id="diff">Known differences between w11a and KB11-C (11/70)</a>

- the `SPL` instruction in the 11/70 always fetched the next instruction
  regardless of pending device or even console interrupts. This is known
  as the infamous _spl bug_, see
  - https://minnie.tuhs.org/pipermail/tuhs/2006-September/002692.html
  - https://minnie.tuhs.org/pipermail/tuhs/2006-October/002693.html
  - https://minnie.tuhs.org/pipermail/tuhs/2006-October/002694.html
  - https://minnie.tuhs.org/pipermail/tuhs/2006-October/002695.html
  - https://minnie.tuhs.org/pipermail/tuhs/2006-October/002701.html
  - https://minnie.tuhs.org/pipermail/tuhs/2006-October/002695.html
  - https://minnie.tuhs.org/pipermail/tuhs/2006-October/002702.html

  In the w11a the `SPL` has 11/70 semantics in kernel mode, thus no 
  traps or interrupts, but in supervisor and user mode `SPL` really acts as 
  `NOOP`, so traps and interrupts are taken as for all other instructions.   
  **--> The w11a isn't bug compatible with the 11/70.**
- A 'red stack violation' loses PSW, a 0 is pushed onto the stack.
- The 'instruction complete flag' in `MMR0` is not implemented, it is
  permanently '0', `MMR2` will not record vector addresses in case of a
  vector fetch fault. Recovery of vector fetch faults is therefore not
  possible, but only 11/45 and 11/70 supported this, no OS used that, and
  it's even unclear whether it can be practically used.
- the 11/70 maps the 18 bit UNIBUS address space into the upper part of
  the 22bit extended mode address space. With UNIBUS mapping enabled, this
  allowed to access via 17000000:17757777 the memory exactly as a UNIBUS
  device would see it. The w11a doesn't implement this remapping, an access
  in the range 17000000:17757777 causes an NXM fault.

All four points relate to very 11/70 specific behavior, no operating system
depends on them, therefore they are considered acceptable implementation
differences.

### <a id="unspec">Differences in unspecified behavior cases between w11a and KB11-C (11/70)</a>

- The state of the N and Z condition codes is different after a DIV overflow.
  The [1979 processor handbook](http://www.bitsavers.org/pdf/dec/pdp11/handbooks/PDP11_Handbook1979.pdf)
  states on page 75 that the state of the N and Z condition codes is unspecified
  when V=1 is set after a zero divide or an overflow condition.
  After a DIV overflow, the w11 returns Z=0 and N based on the sign of the
  full 32-bit result, as can be easily determined by xor'ing of the sign
  bits of dividend and divisor.
  This is also the most natural result, an overflow is certainly
  not zero, and the sign is unambiguously determined by the inputs.
  The SimH simulator also behaves like this. A real J11 and a real 11/70
  can have N=0 even when dividend and divisor have opposite signs. And a
  real 11/70 can have Z=1. Bottom line is, that the w11 differs from the
  behavior of both the real 11/70 and the real J11 behavior.
- the state of the result registers is also unspecified after a DIV with V=1.
  SimH and a real J11 never modify a register when V=1 is set. A real 11/70
  and the w11 do, but under different conditions, and leave different values
  in the registers.
- for gory details consult the [divtst](../tools/tests/divtst/README.md) code
  and the log files for different systems in the
  [data](../tools/tests/divtst/data/README.md) directory.

No software should depend on unspecified behavior of the CPU, therefore
this is considered as acceptable implementation difference.

### <a id="lim">Known limitations</a>

- some programs use timing loops based on the execution speed of the
  original processors. This can lead to spurious timeouts, especially
  in old test programs.  
  **--> a 'CPU throttle mechanism' will be added in a future version to 
  circumvent this for some old test codes.**
- the emulated I/O can lead to apparently slow device reaction times,
  especially when the server runs as a normal user process. This can lead
  to a timeout, again mostly in test programs.  
  **--> a 'watch dog' mechanism will be added in a future version which
  suspends the CPU when the server doesn't respond fast enough.**
