## Known differences between SimH, 11/70, and w11a

### 18-bit UNIBUS address space not mapped into 22-bit address space

The 11/70 maps the 18 bit UNIBUS address space into the upper part of
the 22-bit extended mode address space. With UNIBUS mapping enabled, this
allows to access via 17000000:17757777 the memory exactly as a UNIBUS
device would see it.
On an 11/70, an access to non-existing memory via the UNIBUS map will result
in a UNIBUS timeout and set the `ITO` bit `CPUERR`.

SimH doesn't implement the UNIBUS window, in a 4 MB memory configuration
the address range 17000000:17757777 will be normal memory.

Notes:
- The w11a doesn't implement this remapping, an access in the range
  17000000:17757777 causes an `NXM` fault and will set the `NXM` bit in `CPUERR`.
- E11 implements the UNIBUS window and from V7.4 on access to main memory
  via the UNIBUS map. This can be disabled via `set cpu nouwin`. When used
  with `set memory 3840` an E11 system will be behave like the w11.
