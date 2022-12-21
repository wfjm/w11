## Known differences between SimH, 11/70, and w11a

### SimH: `SPL` doesn't have 11/70 behavior

On an 11/70, the `SPL` instruction in the 11/70 always fetches the next
instruction regardless of current mode, pending device, or even console
interrupts. This behavior is used in some xxdp diagnostic codes to prepare
a situation suitable for interrupt response testing.

SimH does not implement this behavior, `SPL` behaves like all other
instructions, and interrupts or traps are honored after it completes.
xxdp program `ekbbf0` test 032 depends on the 11/70 behavior and is skipped
(see [patch](../tools/xxdp/ekbbf0_patch_1170.scmd)).

The w11 implements 11/70 behavior for `SPL` in kernel mode only. In supervisor
or user mode `SPL` is a nop and honors traps and interrupts, see
[`SPL` on w11](w11a_diff_70_spl_bug.md).
Several [tcodes](../tools/tcode/README.md) utilize the `SPL` behavior and
are skipped when executed on SimH
(see [cpu_basics.mac](../tools/tcode/cpu_basics.mac) test F2.3).