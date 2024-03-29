## Known differences between SimH, 11/70, and w11a

### SimH: Red stack zone `PSW` protection

The 11/70 includes location 177776 in the red stack zone. This is not
documented in the Processor Handbooks, only mentioned in the Technical
Manual. It was added to protect the `PSW` in case a further stack push
is done after an emergency stack was set up, the vector flow of a fatal
stack errors had concluded, and the handler does a stack push when `SP`
is still 0.

SimH doesn't support this behavior.

w11 implements the `PSW` protection. This is verified in a
[tcode](../tools/tcode/README.md), the test is skipped when executed on SimH
(see [cpu_details.mac](../tools/tcode/cpu_details.mac) test A3.2).

Tested with SimH V3.12-3.
