# ECO-032:  `MMR1` write logic fix (2022-09-02)

### Scope
- was in w11a since 2009
- affects: all w11a systems

### Symptom summary
Test 12 @ 042056 of ekbee1 expects after a
```
  mov    #100000,@#mmr0
```
which sets an error bit in `MMR0` and thus freezes `MMR1`.  
`MMR1` contains 013427 (00010 111 00010 111) (+2,r7;+2,r7).  
w11a has 000047 (00000 000 00100 111) (--,--;+4,r7).

### Background
`MMM1` holds the information to roll back changed registers in case of an
MMU abort. For this purpose, it doesn't matter whether the changes for a
register are lumped up or stored separately. Both possibilities fulfill
the requirements.

### Analysis
The 11/70 Technical manual clearly states that there is an additional state
that counts the write accesses to `MMR1`. This ensures that each of the two
logged accesses end up in separate bytes (byte 0 filled first).

The w11a added changes and only used byte 1 when the register number
differed. SimH doesn't use a state bit, it writes to the upper byte
when the lower byte is non-zero
```
  #define calc_MMR1(val)  ((reg_mods)? (((val) << 8) | reg_mods): (val))
```

### Fixes
- remove adder logic in pdp11_mmu_mmr1
- use SimH logic, write to upper half if lower != 0
- that's functionally equivalent to the 11/70 logic but saves a state bit

### Hindsight
Took 13 years to fix. No OS depends on this detail, only test codes
will probe the difference.
