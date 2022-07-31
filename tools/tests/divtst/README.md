## divtst: a test program testing DIV instruction response

The `divtst` program tests the `DIV` instruction with a set of test
cases and checks whether the response agrees with the expected values.
The program is available in two versions
- for BSD Unix systems, written in C and assembler, see directory [bsd](bsd)
- for RSX systems, written in MACRO-11 assembler, see directory [rsx](rsx)

Some results for different systems is available in directory [data](data).

The `divtst` program read the test cases from a file with the high and low part
of dividend and the divisor followed by _expected_ condition codes, quotient,
and remainder. All in octal like
```
;  ddh    ddl     dr : nzvc      q      r # comments
000000 000000 000003 : 0100 000000 000000 #           0/     3:     0,     0
000000 000004 000003 : 0000 000001 000001 #           4/     3:     1,     1
025253 052525 125252 : 1000 100000 052525 #   715871573/-21846:-32768, 21845
000000 000000 000000 : 0111 000000 000000 #           0/     0:     0,     0
025253 052527 125252 : 1010 025253 052527 #   715871575/-21846: 10923, 21847
```
The comment gives dividend, divisor, quotient, and remainder in decimal for
easier understanding, but is not interpreted by the program.

The output has the same format and contains _found_ condition codes quotient
and remainder. If the found response differs from the expected values
error indicators are added
```
CBAD for C mismatch
VBAD for V mismatch
ZBAD for Z mismatch (only checked if V=0)
NBAD for N mismatch (only checked if V=0)
QBAD for quotient mismatch (only checked if V=0)
RBAD for remainder mismatch (only checked if V=0)
```
Note that the N and Z condition codes are _unspecified_ for the `DIV`
instruction after a zero divide or overflow abort, which both set V=1.
The `w11` sets N=0 Z=1 for zero divide and Z=0 and N to the expected sign
of the result for an overflow. Same does SimH. The expected condition codes
in the file [tstall.dat](tstall.dat) are set like this for V=1 cases,
but not checked.

The state of the two result registers is also not specified when V=1 is set.
In some CPUs and some cases the registers preserve the original state, in other
cases, they are written. This is flagged with two markers
```
R0MOD for R0 changed when V=1 seen
R1MOD for R1 changed when V=1 seen
```
These markers do not indicate an error, they just flag how `DIV` behaves in
these unspecified cases.
