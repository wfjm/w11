## Notes on w11 systems: w11a for Nexys A7-100  and Nexys 4 DDR (BRAM only)

- [Basics](#user-content-basics)
- [Usage](#user-content-usage)
- [Status & History](#user-content-status)

### <a id="basics">Basics</a>

The [sys_w11a_br_n4d](sys_w11a_br_n4d.vhd) system is a
[w11a](../../../w11a) implementation for the Digilent
[Nexys A7-100](https://wfjm.github.io/home/w11/inst/boards.html#digi_nexysa7)
board, where the w11 memory is based only on BRAMs.
The design is also compatible with the
[Nexys 4 DDR](https://wfjm.github.io/home/w11/inst/boards.html#digi_nexys4d)
board.
It was created before MIG support was completed, has reduced diagnostics
(to save BRAMs), and is mainly useful for debugging and testing the memory.
For complete configuration, see [sys_conf.vhd](sys_conf.vhd).
The most important features are:

| Property | Value |
| -------- | ----- |
| CPU options | FPP: no; Cache: 8 kB |
| Memory   | 512 kB from BRAMs via [pdp11_bram_memctl](../../../w11a/pdp11_bram_memctl.vhd) |
| Devices | DL11:2; DZ11, PC11, LP11, DEUNA, RK11, RL11, RHRP, TM11, IIST, KW11P, M9312: yes |
| Diagnostics | rbmon: **no**; ibmon: **no**; dmpcnt: yes; dmhbpt: 2; dmcmon: **no** |
| Rlink | 12 Mbps via FT2232HQ based serial link |

A design with full SDRAM memory support is available as
[sys_w11a_n4d](../nexys4d).

### <a id="usage">Usage</a>

The board has 16 LEDs and allows a nice console light emulation.
The memory size of 512 kB  allows starting only a subset of the available
[oskits](../../../../tools/oskit).
u5ed, u7ed, XXDP, RT11, RSX-11M and most most RSX-11M+ systems should work.
211bsd works only in the 'non-networking' configuration
[211bsd_rpmin](../../../../tools/oskit/211bsd_rpmin).

For complete instructions on how to run operating system images,
[see w11a_os_guide](../../../../doc/w11a_os_guide.md).
The default setup is:

```
  SWI = 00000000 00101000   (gives console light display on LEDs)
  ti_w11 -tuD,12M,break,cts  @<oskit-name>_boot.tcl
```

### <a id="status">Status & History</a>

The Nexys A7-100 board is one of the main w11 development platforms.
The sys_w11a_br_n4d design is occasionally FPGA tested with
[ostest](../../../../tools/bin/ostest) against the
[oskits](../../../../tools/oskit) running with 512 kB memory.

- **2019-08-10**: procured Nexys A7-100 board. Design is now fully FPGA
  tested and verified.
- **2017-01-04**: initial version, only simulation tested (no board available
  for FPGA testing)


