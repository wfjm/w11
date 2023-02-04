# Summary of known differences and limitations for w11a CPU and systems

This file lists the differences and limitations of the w11 CPU and systems.
The issues of the w11 CPU and systems are listed in a separate document
[README_known_issues.md](README_known_issues.md).

### Known differences between w11a and KB11-C (11/70)
- instruction behavior
  - [Instruction fetch after `SPL`](w11a_diff_70_spl_bug.md)
  - [`CLR` and `SXT` do a write](w11a_diff_70_clr_sxt_write.md)
  - [State of N and Z and registers after a `DIV` abort with `V=1`](w11a_diff_70_div_after_v1.md)
- stack limit and stack error behavior
  - [Stack limit checks done independent of register set](w11a_diff_70_stklim_rset.md)
  - [No unconditional instruction fetch after stack error abort](w11a_diff_70_ser_forced_fetch.md)
- instruction abort handling
  - [`PC` is incremented before an instruction fetch abort](w11a_diff_70_fetch_abort.md)
- memory management behavior
  - [`MMR0` instruction complete implementation differences](w11a_diff_70_instruction_complete.md)
  - [MMU traps not suppressed when MMU register accessed](w11a_diff_70_mmu_trap_suppression.md)
  - [MMU aborts have priority over NXM aborts](w11a_diff_70_mmu_nxm_prio.md)
  - [`MMR0` abort flags are set when stack limit abort done](w11a_diff_70_mmu_stklim_prio.md)
- not implemented 11/70 features
  - [18-bit UNIBUS address space not mapped](w11a_diff_70_unibus_mapping.md)
  - [MMU maintenance mode not implemented](w11a_diff_70_mmu_no_maint.md)
  - [no cache parity and minimal subset of memory system controls](w11a_diff_70_cache_memory.md)
- other differences
  - [Usage of 11/70 `SYSID` register](w11a_diff_70_sysid_usage.md)

All points relate to very 11/70 specific behavior, no operating system
depends on them, therefore they are considered acceptable implementation
differences.

For a comprehensive list of differences between all PDP-11 models consult
the _PDP-11 Family Differences Table_ in
- [PDP-11 Architecture Handbook (1983)](http://wwcm.synology.me/pdf/EB-23657-18%20PDP-11%20Architecture%20Handbook.pdf) Appendix B p303
- [PDP-11 MICRO/PDP-11 Handbook 1983-84](http://www.bitsavers.org/pdf/dec/pdp11/handbooks/EB-24944-18_Micro_PDP-11_Handbook_1983-84.pdf) Appendix G p387
- and also [PDP-11 family differences appendix](https://gunkies.org/wiki/PDP-11_family_differences_appendix)

Also helpful are the differences sections in the manuals of for processors
- [T-11 User's Guide 1982](http://www.bitsavers.org/pdf/dec/pdp11/t11/T11_UsersMan.pdf) Appendix B p221
- [J-11 Programmer's Reference Rev 2.04 1982](http://www.bitsavers.org/pdf/dec/pdp11/j11/J-11_Programmers_Reference_Jan82.pdf) Section 11.0 p37 (focus on registers and instructions)
- [KD11-E (11/34) Central Processor Manual](http://www.bitsavers.org/pdf/dec/pdp11/1134/EK-KD11E-TM-001_KD11-E_Central_Processor_Maintenance_Manual_Dec76.pdf) Table 2-8 p41

### <a id="lim">Known limitations</a>

- some programs use timing loops based on the execution speed of the
  original processors. This can lead to spurious timeouts, especially
  in old test programs.  
  A 'CPU throttle mechanism' will be added in a future version to
  circumvent this for some old test codes.
- the emulated I/O can lead to apparently slow device reaction times,
  especially when the server runs as a normal user process. This can lead
  to a timeout, again mostly in test programs.  
  A 'watch dog' mechanism will be added in a future version which
  suspends the CPU when the server doesn't respond fast enough.

### Known differences between Simh, E11, a real 11/70, and w11a
The Simh and E11 simulators do not model some 11/70 details that have no
effect on normal operation for performance reasons. Test codes, like
[xxdp](../tools/xxdp/README.md) diagostic programs or the
[tcodes](../tools/tcode/README.md) of the w11 verification suite are
sometimes sensitive to those details, so the most relevant ones are
listed under
- [Known differences between SimH, 11/70, and w11a](simh_diff_summary.md)
- [Known differences between E11, 11/70, and w11a](e11_diff_summary.md)
