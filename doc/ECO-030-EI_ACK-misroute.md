# ECO-030:  `EI_ACK` misrouted in rare cases (2019-04-23)

### Scope
- Was in w11a from the very beginning (2007)
- Affects: all w11a systems

### Symptom summary
Tests done with the `pc11copy.mac` code after the buffered version
`ibdr_pc11_buf.vhd` of the `PC11` taper tape reader/puncher had been
implemented showed that sometimes a reader interrupt is lost when
the interrupt rate limiter is enabled.

### Background
The original `UNIBUS` systems used daisy chains for the four priority levels
and special bus requests to determine vector address and PSW information.
The implementation of device interrupts in the w11 is very different.
Each interrupt source has an interrupt request `EI_REQ` output and an
acknowledge `EI_ACK` input port.
The `ib_intmap24` entity evaluates the `EI_REQ` status, determines the
highest priority source, and forwards the resulting priority and vector
information to `pdp11_core`.
When the CPU accepts an interrupt it sends an acknowledge signal `EI_ACKM`
which is send by `ib_intmap24` to the `EI_REQ` line of the winning
interrupt source.

### Analysis
The `EI_ACKM` signal is send in the cycle _after_ the `EI_REQ` pattern was
evaluated. The old implementation of `ib_intmap24` was plain combinatoric
logic, and routed `EI_ACKM` to the `EI_ACK` line based on the status of
the `EI_REQ` pattern of the current cycle. That fails when a higher
priority interrupt source appeared in this cycle. In such cases the
acknowledge is send to the new winner, where it most likely will clear
the interrupt request. The net effect is that the new winner might loose
and interrupt, while the old winner misses an `EI_ACK` and most likely
causes a double interrupt.

The obvious question is: _why did it apparently work the last 12 years ?_

Before the buffered versions of `LP11`, `PC11`, and `DL11` were introduced
all interrupts where caused by `ibus` transactions, the only exception was
the `KW11-L` line clock. So device interrupts were never created in the in
a cycle where a vector decision is taken. Only clock interrupts were
vulnerable, but loosing a clock interrupt in rare cases has little practical
consequences.

### Fixes
Simply ensure that `INT_ACK` is routed based on the status of the previous
clock cycle.
- `pdp11_irq`: add a state bit which ensures that `INT_ACK` is only
   forwarded to `EI_ACKM` when an external source won in last cycle
- `ib_intmap24`: add a state register which holds the number of the winning
   `EI_REQ` line from last cycle, and use this value to route `EI_ACKM` to the
   `EI_ACK` lines.

### Hindsight
That 12 year old code worked with no apparent problems doesn't prove that
it is free of fundamental bugs.
