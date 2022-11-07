## Known differences between w11a and KB11-C (11/70)

### `CLR` and `SXT` do a write

In most instructions the destination is modified, only in `MOV(B)`, `CLR(B)`,
and `SXT` the destination value is overwritten regardless of its previous
content.

The 11/70 microcode implements `MOV(B)` such that it ends with a `DATO`.
However, `CLR(B)` and `SXT` use a specifier flow like other updating
instructions and perform a `DATIP`, without using the value, and `DATO`.
The J11 does only a `DATO` in all three cases. See point 36 in the
PDP-11 differences table.

The w11a uses the `dstw` flow for all three instructions, and in this
case behaves like a J11 and rather than an 11/70.

This subtle difference might cause observable effects when reading a
device register changes the state of a device.
But for those registers it is unlikely to use `MOV` or `CLR`.
Also, drivers are usually written to run on  11/70 and J11 systems.

Therefore, this is considered an acceptable implementation difference.
