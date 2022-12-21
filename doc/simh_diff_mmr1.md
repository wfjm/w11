## Known differences between SimH, 11/70, and w11a

### SimH: `MMR1` recording has J11 behavior

The register `MMR1` records register modifications and can be used in the event
of an MMU abort to rollback the register state and re-execute the instruction.
Explicit `PC` modifications from addressing mode 2 or 3 accesses can be
recorded, but are ignored in MMU abort handling because the `PC` roll back
is done with `MMR2`. Implicit `PC` modifications from instruction fetch or
index word reads are never recorded in `MMR1`.
Essential is, that the content of `MMR1` reflects the register modifications
_at the time of the instruction abort_.

The 11/70 and the J11 `MMR1` recording behavior differs in several respects:
- for instructions with implicit stack pops (`RTS`, `MTPI`, `MTPD`) the
  11/70 updates the `SP` and records this in `MMR1` before accessing the stack
  value and detecting an MMU abort. The J11 increments `SP` after the stack
  access.
- the 11/70 records `PC` changes from immediate value are absolute
  addressing modes. The J11, with a much more sophisticated instruction
  stream prefetch, doesn't.

SimH uses the J11 `MMR1` behavior for all models.

w11 implements the 11/70 behavior. This is verified in a
[tcode](../tools/tcode/README.md), the tests are skipped when executed on SimH
(see [cpu_mmu.mac](../tools/tcode/cpu_mmu.mac) test C1.1 and C2.3).
