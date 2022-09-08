## Known differences between w11a and KB11-C (11/70)

### MMU traps not suppressed when MMU register accessed

The 11/70 does not execute an MMU trap when an MMU register is accessed,
thus `MMR0` to `MMR3` and any of the `PDR` and `PAR` registers.

This causes test 061 of `ekbee1` to fail.

The w11 doesn't implement this trap suppression (neither does SimH).

Since MMU traps are a 11/70,11/45 only feature no OS uses them.
Given that, this is considered an acceptable deviation from 11/70 behavior.
