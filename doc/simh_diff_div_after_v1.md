## Known differences between SimH, 11/70, and w11a

### SimH: State of N and Z and registers after a `DIV` abort with `V=1`

The state of the N and Z condition codes is specified as unspecified for
the `DIV` instruction when V=1 is set after a zero divide or an overflow
condition.
See [1979 processor handbook](http://www.bitsavers.org/pdf/dec/pdp11/handbooks/PDP11_Handbook1979.pdf) on page 75.

The 11/70 leaves the N and Z condition codes and the result registers in a
state depending on the abort point in the microcode state flow. That results
in sometimes surprising settings.

SimH returns Z=0 and N based on the sign of the full 32-bit result, as can be
easily determined by xor'ing of the sign bits of dividend and divisor.

xxdp program `ekbbf0` test 014 checks the exact 11/70 behavior to verify the
divide logic and is modified (see [patch](../tools/xxdp/ekbbf0_patch_1170.scmd)).

w11 also returns Z=0 and N based on the sign of the full 32-bit result, this
is documented as [w11 known difference](w11a_diff_70_div_after_v1.md).

Tested with SimH V3.12-3.
