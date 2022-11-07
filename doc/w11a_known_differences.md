# Summary of known differences and limitations for w11a CPU and systems

This file lists the differences and limitations of the w11 CPU and systems.
The issues of the w11 CPU and systems are listed in a separate document
[README_known_issues.md](README_known_issues.md).

### Known differences between w11a and KB11-C (11/70)
- [Instruction fetch after `SPL`](w11a_diff_70_spl_bug.md)
- ['fatal stack errors' lose PSW](w11a_diff_70_red_stack_abort.md)
- [Stack limit checks done independent of register set](w11a_diff_70_stklim_rset.md)
- ['instruction completed flag' in `MMR0` is not implemented](w11a_diff_70_instruction_complete.md)
- [`CLR` and `SXT` do a write](w11a_diff_70_clr_sxt_write.md)
- [`jsr sp` pushes original `sp` value](w11a_diff_70_jsr_sp.md)
- [18-bit UNIBUS address space not mapped](w11a_diff_70_unibus_mapping.md)
- [MMU traps not suppressed when MMU register accessed](w11a_diff_70_mmu_trap_suppression.md)

All points relate to very 11/70 specific behavior, no operating system
depends on them, therefore they are considered acceptable implementation
differences.

For a comprehensive list of differences between all PDP-11 models consult
the _PDP-11 Family Differences Table_ in
- [PDP-11 Architecture Handbook (1983)](http://wwcm.synology.me/pdf/EB-23657-18%20PDP-11%20Architecture%20Handbook.pdf) Appendix B p303
- [PDP-11 MICRO/PDP-11 Handbook 1983-84](http://www.bitsavers.org/pdf/dec/pdp11/handbooks/EB-24944-18_Micro_PDP-11_Handbook_1983-84.pdf) Appendix G p387
- and also [PDP-11 family differences appendix](https://gunkies.org/wiki/PDP-11_family_differences_appendix)

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

### Known differences between w11a and a SimH 11/70
The SimH emulator models only behavior what is relevant for the normal
operation of operating systems and user code. Many details which do not
have impact on normal operation are not modeled for performance reasons.
Test codes are sometimes sensitive to those details, that's why the most
relevant are listed here.
- [SimH: implicit stack pops not recorded in MMR1](w11a_diff_simh_mmr1_rts_mtp.md)
