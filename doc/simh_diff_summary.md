# Known differences between SimH, 11/70, and w11a

The SimH simulator focuses on the behavior that is relevant to the normal
operation of operating systems and user code. Model differences that are
operation relevant, e.g. in probe routines or model-dependent kernel routines,
are handled correctly epending on the `set cpu` configuration.
However, many model variations that do not effect normal operation are not
modeled for performance reasons. In these cases, the J11 behavior is often used
for all PDP-11 models, and also when `set cpu 11/70` is configured.

Test codes are sometimes sensitive to those details, so the most relevant
ones are listed here:
- instruction behavior
  - [SimH: `SPL` doesn't have 11/70 behavior](simh_diff_spl.md)
  - [SimH: State of N and Z and registers after a `DIV` abort with `V=1`](simh_diff_div_after_v1.md)
  - [SimH: `JSR SP` pushes modified `SP` value](simh_diff_jsr_sp.md)
- stack limit and stack error behavior
  - [SimH: stack limit check and addressing modes](simh_diff_stklim_amode.md)
  - [SimH: stack limit check and vector push aborts](simh_diff_stklim_vpush.md)
  - [SimH: Red stack zone PSW protection](simh_diff_red_psw.md)
  - [SimH: `CPUERR.rsv` has J11 behavior](simh_diff_cpuerr_rsv.md)
  - [SimH: No unconditional instruction fetch after stack error abort](simh_diff_ser_forced_fetch.md)
- instruction abort handling
  - [SimH: condition codes are not always unchanged after an abort](simh_diff_cc_and_aborts.md)
- service order and trap handling
  - [SimH: trap and interrupt service order has J11 behavior](simh_diff_service-order.md)
  - [SimH: traced `WAIT` has J11 behavior](simh_diff_traced-wait.md)
  - [SimH: traced `RTI`/`RTT` that clears tbit does trap](simh_diff_traced-rti-rtt.md)
  - [SimH: vector flow that sets tbit does not trap](simh_diff_traced-vector.md)
- memory management behavior
  - [SimH: `MMR1` recording has J11 behavior](simh_diff_mmr1.md)
  - [SimH: MMU traps not suppressed when MMU register accessed](simh_diff_mmu_trap_suppression.md)
  - [SimH: The 'instruction completed flag' in `MMR0` is not implemented](simh_diff_instruction_complete.md)
  - [SimH: MMU aborts have priority over NXM aborts](simh_diff_mmu_nxm_prio.md)
- not implemented 11/70 features
  - [SimH: 18-bit UNIBUS address space not mapped](simh_diff_unibus_mapping.md)
  - [SimH: MMU maintenance mode not implemented](simh_diff_mmu_no_maint.md)
