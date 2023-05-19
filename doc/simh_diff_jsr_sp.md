## Known differences between SimH, 11/70, and w11a

### SimH: `JSR SP` pushes modified `SP` value

In the logic of the `JSR` instruction is the given register the
_linkage register_, meant to be used for parameter passing.
`JSR` pushes the _linkage register_ to the stack, and the matching `RTS`
will restore it. That works fine for `R0` to `R5` and for `PC`.
But in a `JSR SP` that interferes with the implicit use of `SP`
as the stack pointer, `SP` is saved on the stack which is defined by `SP`.
The question is whether the original `SP` value is saved, or the `SP`
value after it has been decremented to hold the address for the write
to stack. The specification simply says
```
  down(sp) := sp
```
and the question is whether the side effect of the left side happens before
the right side is evaluated.

The 11/70 implementation saves the value of the linkage register value in
an internal register in `JSR.00` before the `SP` is decremented in `JSR.20`
and write the saved valued to stack in `JSR.30`. See flow 11:
```
  JSR.00:   PCA := DR               ; save dst addr in PCA
            SR  := GS[SF] if -SF7   ; get modified source field reg to SR
            SR  := PCB    if  SF7   ; get modified source field reg to SR
  JSR.10:   DR  := GS[6]            ; get SP
            BR  := SR               ; get modified source field reg to BR
  JSR.20    DR,GR[6] := DR-2        ; step SP back for push
  JSR.30    write BR to DR          ; write old source field to stack
  JSR.40    GR[SF] := PCB           ; old PC goes to src field reg
            PCB := PCA              ; dst addr goes tp PC
```

Therefore, the 11/70 writes the original `SP` value.
SimH writes the modified `SP`
```c
  srcspec = srcspec & 07;
  dst = GeteaW (dstspec);
  SP = (SP - 2) & 0177777;
  WriteW (R[srcspec], SP | dsenable);
  R[srcspec] = PC;
  JMP_PC (dst & 0177777);
```

`JSR SP` is never used due to its bizarre behavior. The matching `RTS SP`
results in a useless `SP` too. Given that, this is considered an
acceptable deviation from 11/70 behavior.

The w11 correctly implements the 11/70 behavior.
This is verified in a [tcode](../tools/tcode/README.md), the test is
modified when executed on SimH
(see [cpu_basics](../tools/tcode/cpu_basics.mac) tests A4.4).

Tested with SimH V3.12-3.
