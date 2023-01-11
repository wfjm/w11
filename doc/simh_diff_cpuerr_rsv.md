## Known differences between SimH, 11/70, and w11a

### SimH: `CPUERR.rsv` has J11 behavior

The `CPUERR` register in an 11/70 and the J11 has 6 flags that allow the cause
of vector 4 abort to be determined.
For an 11/70, the bit 2 is referred to as _'Red Zone Stack Limit'_ in the
documentation. It is set when a stack limit error is detected.
Other address errors that escalate to a fatal stack error do not set this bit.

For a J11, bit 2 has the very similar name _'Red Stack Trap'_, and is set
whenever a fatal stack error is detected, and thus also when other address
errors escalate to a fatal stack error.

The key differences are:
- on an 11/70, an escalated MMU kernel stack abort will not set any
  `CPUERR` bits.
- on a J11, every stack error that causes an emergency stack will set the
  `rsv` bit.

SimH implements the J11 behavior also in 11/70 mode.

w11 implements the 11/70 behavior. This is verified in a
[tcode](../tools/tcode/README.md), the test is modified when executed on SimH
(see [cpu_details.mac](../tools/tcode/cpu_details.mac) test A2.7-10).

Tested with SimH V3.12-3.
