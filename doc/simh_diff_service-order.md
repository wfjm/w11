## Known differences between SimH, 11/70, and w11a

### SimH: trap and interrupt service order has J11 behavior

The 11/70 (and the 11/45) differ from all other PDP-11 models in the order in
which interrupts and traps are honored after the successful completion of an
instruction. On the 11/70, interrupts have precedence over T-bit trace traps,
on all other models interrupts have the lowest priority.

As consequence, `RTI` _can_ be used on an 11/70 to exit from an interrupt driver,
and exactly one trace trap will happen when an interrupt is honored after
a traced instruction. On all other models, `RTT` _should_ be used to exit from
an interrupt driver to prevent a double trace trap, one before the interrupt
and one after the hander exit.

SimH uses the J11 service order with interrupts having the lowest priority for
all PDP-11 models.

The w11 implements the 11/70 service order.
This is verified in a [tcode](../tools/tcode/README.md), the test is
skipped when executed on SimH
(see [cpu_details.mac](../tools/tcode/cpu_details.mac) test A4.4 part 3).

See also [traced `WAIT`](simh_diff_traced-wait.md).
