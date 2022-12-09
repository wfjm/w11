## Known differences between w11a and KB11-C (11/70)

### MMU traps not suppressed when MMU register accessed

The 11/70 does not execute an MMU trap and doesn't set A or W bits in `PDR`
when an MMU register is accessed, thus `MMR0` to `MMR3` and any of the
`PDR` and `PAR` registers.

This causes `ekbee1` tests 61 and 63 to fail.

The w11 doesn't implement this trap suppression (neither does SimH or e11).

Since MMU traps are a 11/70,11/45 only feature no OS uses them.
Given that, this is considered an acceptable deviation from 11/70 behavior.

Note: the decision whether to request a trap or to update the A and W bits
must be done in the clock cycle in which the MMU translates the virtual
address into a physical address. The w11 determines only in the following
clock cycle whether the physical address is a UNIBUS address and starts an
`ibus` transaction, and the UNIBUS address decoder decision is available in
the respective `IBSEL` registers in the next following cycle. With this
structure, it is not possible to use the available UNIBUS address decoding
information during the MMU decision whether to request a trap or not.
Implementing the 11/70 behavior would require a separate MMU register
detection, which would increase the logic depth at a point that is already
quite long.
