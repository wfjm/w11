# Summary of known differences and limitations for w11a CPU and systems

General issues are listed on a separate document
[README_known_issues.md](README_known_issues.md).

This file descibes differences and limitations of the w11 CPU and systems.

### Table of content

- [Known differences between w11a and KB11-C (11/70)](#user-content-diff)
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

  In the w11a the `SPL` has 11/70 semantics in kernel mode, thus next no 
  traps or interrupts, but in supervisor and user mode `SPL` really acts as 
  `NOOP`, so traps and interrupts are taken as for all other instructions.   
  **--> The w11a isn't bug compatible with the 11/70.**
- A 'red stack violation' looses PSW, a 0 is pushed in stack.
- The 'instruction complete flag' in `SSR0` is not implemented, it is 
  permanently '0', `SSR2` will not record vector addresses in case of a
  vector fetch fault. Recovery of vector fetch faults is therefore not
  possible, but only 11/45 and 11/70 supported this, no OS used that, and
  it's even unclear whether it can be practically used.
- the 11/70 maps the 18 bit UNIBUS address space into the upper part of
  the 22bit extended mode address space. With UNIBUS mapping enabled, this
  allowed to access via 17000000:17757777 the memory exactly as a UNIBUS
  device would see it. The w11a doesn't implement this remapping, an access
  in the range 17000000:17757777 causes a NXM fault.

All four points relate to very 11/70 specific behaviour, no operating system
depends on them, therefore they are considered acceptable implementation
differences.

### <a id="lim">Known limitations</a>

- some programs use timing loops based on the execution speed of the
  original processors. This can lead to spurious timeouts, especially
  in old test programs.  
  **--> a 'CPU throttle mechanism' will be added in a future version to 
  circumvent this for some old test codes.**
- the emulated I/O can lead to apparently slow device reaction times,
  especially when the server runs as normal user process. This can lead
  to timeout, again mostly in test programs.  
  **--> a 'watch dog' mechanism will be added in a future version which
  suspends the CPU when the server doesn't respond fast enough.**
