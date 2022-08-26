## Known differences between w11a and KB11-C (11/70)

### 18-bit UNIBUS address space not mapped into 22-bit address space

The 11/70 maps the 18 bit UNIBUS address space into the upper part of
the 22-bit extended mode address space. With UNIBUS mapping enabled, this
allows to access via 17000000:17757777 the memory exactly as a UNIBUS
device would see it.

The w11a doesn't implement this remapping, an access in the range
17000000:17757777 causes an NXM fault.
