## Known differences between SimH, 11/70, and w11a

### SimH: `SPL` doesn't have 11/70 behavior

On an 11/70, the `SPL` instruction in the 11/70 always fetches the next
instruction regardless of current mode, pending device, or even console
interrupts. This behavior is used in some xxdp diagnostic codes to prepare
a situation suitable for interrupt response testing.

SimH does not implement this behavior, `SPL` behaves like all other
instructions, and interrupts or traps are honored after it completes.
xxdp `ekbbf0` test 32 depends on the 11/70 behavior and is skipped.

The w11 implements 11/70 behavior for `SPL` in kernel mode only. In supervisor
or user mode `SPL` is a nop and honors traps and interrupts, see
[`SPL` on w11](w11a_diff_70_spl_bug.md).
