## Differences in unspecified behavior between w11a and KB11-C (11/70)

### State of N and Z and registers after a `DIV` abort with `V=1`

The state of the N and Z condition codes is specified as unspecified for
the `DIV` instruction when V=1 is set after a zero divide or an overflow
condition.
See [1979 processor handbook](http://www.bitsavers.org/pdf/dec/pdp11/handbooks/PDP11_Handbook1979.pdf) on page 75.

After a `DIV` overflow, the w11 returns Z=0 and N based on the sign of the
full 32-bit result, as can be easily determined by xor'ing of the sign
bits of dividend and divisor.
This is also the most natural result, an overflow is certainly
not zero, and the sign is unambiguously determined by the inputs.

The SimH simulator also behaves like this. A real J11 and a real 11/70
can have N=0 even when dividend and divisor have opposite signs. And a
real 11/70 can have Z=1. Bottom line is, that the w11 differs from the
behavior of both the real 11/70 and the real J11 behavior.

The state of the result registers is also unspecified after a DIV with V=1.
SimH and a real J11 never modify a register when V=1 is set. A real 11/70
and the w11 do, but under different conditions, and leave different values
in the registers.

For gory details consult the [divtst](../tools/tests/divtst/README.md) code
and the log files for different systems in the
[data](../tools/tests/divtst/data/README.md) directory.
  
No software should depend on the unspecified behavior of the CPU, therefore
this is considered as the acceptable implementation difference.
