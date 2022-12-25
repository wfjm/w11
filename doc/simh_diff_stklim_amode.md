## Known differences between SimH, 11/70, and w11a

### SimH: stack limit check and addressing modes

The stack limit check is implemented slightly differenly on all models that
support it. All models check the stack limit only in kernel mode for specifiers
with `SP` as register and compare the effective address with the stack limit.
Beyond that, the 11/70 and the J11 logic are very different
- the 11/70 checks for writes with specifiers with mode 1, 2, 4, or 6, thus for
  - `clr  (sp)`
  - `mov  #77,(sp)+`
  - `mov  #77,-(sp)`
  - `mov  #77,2(sp)`
- the J11 checks for all accesses with specifiers with mode 4 and 5, thus for
  - `mov  #77,-(sp)`
  - `clr @-(sp)`
  - `tst -(sp)`

The 11/70 logic focuses on that a write was done, while the J11 logic focuses
on that the `SP` was decremented.

SimH uses the J11 behavior for all models, thus also for an 11/70 simulation.  
xxdp program `ekbbf0` tests 036, 040 and 042,
`ekbee1` tests 122 and 123, and
`eqkce1` tests 041 and 065
depend on the 11/70 behavior and are patched or skipped
(see patch for [ekbbf0](../tools/xxdp/ekbbf0_patch_1170.scmd),
[ekbee1](../tools/xxdp/ekbee1_patch_1170.scmd), and
[eqkce1](../tools/xxdp/eqkce1_patch_1170.scmd)).

The w11 correctly implements the 11/70 behavior. This is verified in a
[tcode](../tools/tcode/README.md), the test is skipped when executed on SimH
(see [cpu_details.mac](../tools/tcode/cpu_details.mac) test A3.3).

Tested with SimH V3.12-3.
