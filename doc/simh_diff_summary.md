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
- [SimH: State of N and Z and registers after a `DIV` abort with `V=1`](simh_diff_div_after_v1.md)
- [SimH: stack limit check uses J11 behavior](simh_diff_stklim.md)
- [SimH: Red stack zone PSW protection](simh_diff_red_psw.md)
- [SimH: trap and interrupt service order has J11 behavior](simh_diff_service-order.md)
- [SimH: traced `WAIT` has J11 behavior](simh_diff_traced-wait.md)
- [SimH: `SPL` doesn't have 11/70 behavior](simh_diff_spl.md)
- [SimH: MMU traps not suppressed when MMU register accessed](simh_diff_mmu_trap_suppression.md)
- [SimH: implicit stack pops not recorded in `MMR1`](simh_diff_mmr1_rts_mtp.md)
- [SimH: The 'instruction completed flag' in `MMR0` is not implemented](simh_diff_instruction_complete.md)
- [SimH: MMU aborts have priority over NXM aborts](simh_diff_mmu_nxm_prio.md)
