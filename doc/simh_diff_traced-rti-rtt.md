## Known differences between SimH, 11/70, and w11a

### SimH: traced `RTI`/`RTT` that clears tbit does trap

On an 11/70 and on a J11, a traced `RTI` or `RTT` loading a new `PS` with
tbit=0 does not cause a tbit trap. More precisely:
- an `RTT` will never end with a tbit trap
- an `RTI` ends with a tbit trap only when the new `PS` has tbit=0.

The Processor Handbook documentation is misleading and at one point simply wrong.

On SimH, a traced `RTI` or `RTT` does trap.
Confirmed deficiency, will be fixed.

The w11 implements traced `RTI` or `RTT` correctly, the corresponding test
is skipped when executed on SimH
(see [cpu_details.mac](../tools/tcode/cpu_details.mac) test A4.4 part 8).

Tested with SimH V3.12-3.
