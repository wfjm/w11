## Known differences between SimH, 11/70, and w11a

### SimH: vector flow that sets tbit does not trap

On an 11/70 and on a J11, a vector flow loading a new `PS` with tbit=1 ends
with a tbit trap.

On SimH, a vector flow loading a new `PS` with tbit=1 does not tbit trap.
Confirmed deficiency, will be fixed.

The w11 implements the 11/70 behavior, the corresponding tests
are skipped when executed on SimH
(see [cpu_details.mac](../tools/tcode/cpu_details.mac) test A4.4 part 9,10).

Tested with SimH V3.12-3.
