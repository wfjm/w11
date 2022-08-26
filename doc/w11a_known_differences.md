# Summary of known differences and limitations for w11a CPU and systems

This file lists the differences and limitations of the w11 CPU and systems.
The issues of the w11 CPU and systems are listed in a separate document
[README_known_issues.md](README_known_issues.md).

### Known differences between w11a and KB11-C (11/70)
- [Instruction fetch after `SPL`](w11a_diff_70_spl_bug.md)
- ['red stack violation' loses PSW](w11a_diff_70_red_stack_abort.md)
- ['instruction completed flag' in `MMR0` is not implemented](w11a_diff_70_instruction_complete.md)
- [18-bit UNIBUS address space not mapped](w11a_diff_70_unibus_mapping.md)

All points relate to very 11/70 specific behavior, no operating system
depends on them, therefore they are considered acceptable implementation
differences.

### Differences in unspecified behavior between w11a and KB11-C (11/70)
- [State of N and Z and registers after a `DIV` abort with `V=1`](w11a_diff_70_div_after_v1.md)

No software should depend on the unspecified behavior of the CPU, therefore
this is considered as an acceptable implementation difference.

### Other differences between w11a and KB11-C (11/70)
- [Usage of 11/70 `SYSID` register](w11a_diff_70_sysid_usage.md)

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
