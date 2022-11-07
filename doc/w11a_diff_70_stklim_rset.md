## Known differences between w11a and KB11-C (11/70)

### Stack limit checks done independent of register set

The 11/70 does a stack limit check (yellow or red zone) when
- in kernel mode
- register set 0 active
- a write via SP with address modes 1, 2, 4, 6 is done,
  thus (sp), (sp)+, -(sp), nn(sp)

The fact that the check is only performed when register set 0 is active
is only mentioned as a marginal note in the Technical Manual and can easily
be checked in the Schematics.

The w11 does stack limit checks independent of the register set selection
in `PSW` bit 11.
