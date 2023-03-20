## Known differences between w11a and KB11-C (11/70)

### `PC` is incremented before an instruction fetch abort

The 11/70 starts an instruction fetch in `FET.00` and increments the `PC`
in `FET.10` when the fetch succeeded. The `PC` is therefore unchanged in
case of a fetch abort and points to the location of the failed opcode
fetch.

The w11 increments the `PC` in the states that start an instruction fetch.
The `PC` is therefore incremented in case of a fetch abort and points to
the location _after_ the failed opcode fetch.

This is not relevant to normal operation and is therefore considered an
acceptable implementation difference. An instruction re-execution after
an MMU abort relies always on `MMR2`. Only error messages that give a _"PC at
abort"_ might differ.

SimH and E11 implement the 11/70 behavior, the `PC` is incremented after the
successful load of the instruction register.

However, test and verification codes might be sensitive to this behavior.
A [tcode](../tools/tcode/README.md) verifies this saved `PS` and
distinguishes between w11, SimH, and E11.
(see [cpu_mmu](../tools/tcode/cpu_mmu.mac) tests B4.1 and D2.1).
