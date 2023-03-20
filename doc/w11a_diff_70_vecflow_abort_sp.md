## Known differences between w11a and KB11-C (11/70)

### `SP` decremented only once after 1st vector push abort

The 11/70 calculates in a vector flow the target addresses for 1st and 2nd
vector push before the 1st memory access is done. State `SVC.50` decrements
`SP` by two. State `SVC.60` decrements `SP` again by two, starts the 1st
push, and checks for check limit. Therefore, the `SP` is decremented twice
when a 1st stack push fails. `MMR1` consequently shows two `SP` decrements
in that case.

The w11 handles the two vector push separately, `SP` is decremented and the
stack limit is checked before each push. Therefore, the `SP` is decremented
only once when the 1st push fails, and `MMR1` consequently shows one `SP`
decrement.

However, test and verification codes might be sensitive to this behavior.
A [tcode](../tools/tcode/README.md) verifies `MMR1` after a vector push
abort and distinguishes between w11 and SimH and e11
(see [cpu_mmu](../tools/tcode/cpu_mmu.mac) tests C2.6).
