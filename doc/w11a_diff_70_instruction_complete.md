## Known differences between w11a and KB11-C (11/70)

### `MMR0` instruction complete implementation differences

The 11/70 and 11/45 are the only PDP-11 processors that also support the
recovery of an MMU abort of a stack push during trap or interrupt processing.
To distinguish between an instruction and a trap processing abort, the
`MMR0` has a bit called `instruction completed`. It is set to 0
when an instruction is aborted and to 1 when a vector service flow is
aborted. The `MMR2` contains the vector address in the latter case.

w11 supports this feature, but has two implementation differences:
- the `instruction completed` flag is set and `MMR2` is loaded with the vector
  address for _all_ vector flows. The 11/70 does this only for traps,
  aborts and interrupts, but not for trap instructions (`BPT`, `IOT`,
  `TRAP`, `EMT`).
- the w11 decrements the `SP` before each vector push, while the 11/70
  decrements the `SP` twice before the 1st vector push. Therefore, after an
  MMU abort of the 1st vector push, `MMR1` has `000336` on the w11 and `173366`
  on the 11/70.
  `ekbee1` test 067 checks this `MMR1` response and has been modified
  (see [patch](../tools/xxdp/ekbee1_patch_w11a.tcl)).
