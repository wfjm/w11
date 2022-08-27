## Known differences between w11a and KB11-C (11/70)

### `jsr sp` pushes original `sp` value

In the logic of the `jsr` instruction is the given register the
_linkage register_, meant to be used for parameter passing.
`jsr` pushes the _linkage register_ to the stack, and the matching `rts`
will restore it. That works fine for `r0` to `r5` and for `pc`.
But in a `jsr sp` that interferes with the implicit use of `sp`
as the stack pointer, `sp` is saved on the stack which is defined by `sp`.
The question is whether the original `sp` value is saved, or the `sp`
value after it has been decremented to hold the address for the write
to stack. The specification simply says
```
  down(sp) := sp
```
and the question is whether the side effect of the left side happens before
the right side is evaluated.

The 11/70 implementation of `jsr` first decrements the `sp` in
microstate `jsr.20` and then starts a write of `sp` in `jsr.30`.
So the modified `sp` is stored.

The w11 implement ion first reads `sp` into a register, then decrements
`sp` and writes. So the original `sp` is stored.

`jsr sp` is never used due to its bizarre semantics. The matching `rts sp`
results in a useless `sp` too. Given that, this is considered an
acceptable deviation from 11/70 behavior.
