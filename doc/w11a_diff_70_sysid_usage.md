## Other differences between w11a and KB11-C (11/70)

### Usage of 11/70 `SYSID` register

In real 11/70's, the `SYSID` register contained an individual serial number.
The content of this register may be printed in some reports, but it certainly
has no effect on the logic of the code running on the system.

The w11 project uses the `SYSID` to encode the execution environment.
This allows distinguishing between operation on a real w11 and operation
in a software emulation under SimH or E11.
It can be used on test and verification codes to reconcile implementation
differences.

 Usage of the w11 `SYSID` register
- the SYSID is divided into fields
  - bit 15: emulator flag (0=w11,1=emulator)
  - bit 14:12: type, encodes w11 or emulator type
  - bit 11:09: cpu number on 11/70mP systems
  - bit 8:0: serial number
- current assignments are
  - w11a:  010123
  - SimH:  110234
  - E11:   120345
