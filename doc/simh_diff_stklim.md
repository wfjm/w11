## Known differences between SimH, 11/70, and w11a

### SimH: stack limit check uses J11 behavior

The stack limit check is implemented slightly differenly on all models that
support it. All models check the stack limit only in kernel mode for specifiers
with `SP` as register and compare the effective address with the stack limit.
Beyond that, the 11/70 and the J11 logic are very different
- the 11/70 checks for writes with specifiers with mode 1, 2, 4, or 6, thus for
  - `clr  (sp)`
  - `mov  #77,(sp)+`
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
xxdp `ekbbf0` tests 36,40 and 42,
`ekbee1` tests 122 and 123,
`eqkce1` tests 41 and 65,
depend on the 11/70 behavior and are patched or skipped.

The w11 correctly implements the 11/70 behavior.
