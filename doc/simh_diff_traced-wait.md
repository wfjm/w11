## Known differences between SimH, 11/70, and w11a

### SimH: traced `WAIT` has J11 behavior

On an 11/70 (and an 11/45) a traced `WAIT` will wait until an interrupt happens
and finish without raising a trace trap because the interrupt has higher
service precedence. The trace trap related to the `WAIT` will happen when the
interrupt driver exits with an `RTI`.
See also [trap and interrupt service order](simh_diff_service-order.md).

On a J11 and other PDP-11 models, a traced `WAIT` falls through and raises a
trace trap immediately. This is consistent with trace traps having higher
precedence in those models.

SimH uses the J11 service order with interrupts having the lowest priority for
all PDP-11 models, and consequently, a traced `WAIT` falls through and raises
a trace trap immediately.
xxdp program `ekbbf0` test 063 verifies the 11/70 behavior and is skipped
(see [patch](../tools/xxdp/ekbbf0_patch_1170.scmd)).

The w11 implements the 11/70 service order and `WAIT` behavior.
This is verified in a [tcode](../tools/tcode/README.md), the `WAIT` test is
skipped when executed on SimH
(see [cpu_details.mac](../tools/tcode/cpu_details.mac) test A4.4 part 4).
