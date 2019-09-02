## Notes on w11 systems: w11a for Nexys A7-100 and Nexys 4 DDR

- [Basics](#user-content-basics)
- [Usage](#user-content-usage)
- [Status & History](#user-content-status)

### <a id="basics">Basics</a>

The [sys_w11a_n4d](sys_w11a_n4d.vhd) system is a
[w11a](../../../w11a) implementation for the Digilent
[Nexys A7-100](https://wfjm.github.io/home/w11/inst/boards.html#digi_nexysa7)
board with DDR2 SDRAM support via a Vivado MIG core.
The design is also compatible with the
[Nexys 4 DDR](https://wfjm.github.io/home/w11/inst/boards.html#digi_nexys4d)
board.
For complete configuration, see [sys_conf.vhd](sys_conf.vhd).
The most important features are:

| Property | Value |
| -------- | ----- |
| CPU options | FPP: no; Cache: 32 kB |
| Memory   | 3840 kB from DDR2 SDRAM via [miglib_nexys4d](../../../bplib/nexys4d/miglib_nexys4d.vhd) |
| Devices | DL11:2; DZ11, PC11, LP11, DEUNA, RK11, RL11, RHRP, TM11, IIST, KW11P, M9312: yes |
| Diagnostics | rbmon: yes; ibmon: yes; dmpcnt: yes; dmhbpt: 2; dmcmon: yes |
| Rlink | 12 Mbps via FT2232HQ based serial link |

An alternative design that uses only BRAM is available as
[sys_w11a_br_n4d](../nexys4d_bram).

### <a id="usage">Usage</a>
The board has 16 LEDs and allows a nice console light emulation.
The memory size of 3840 kB allows starting all [oskits](../../../../tools/oskit).

For complete instructions on how to run operating system images,
[see w11a_os_guide](../../../../doc/w11a_os_guide.md).
The default setup is:

```
  SWI = 00000000 00101000   (gives console light display on LEDs)
  ti_w11 -tuD,12M,break,cts  @<oskit-name>_boot.tcl
```

### <a id="status">Status & History</a>

The Nexys A7-100 board is one of the main w11 development platforms.
The sys_w11a_n4d design is often FPGA tested with
[ostest](../../../../tools/bin/ostest) against all
[oskits](../../../../tools/oskit).

- **2019-08-10**: procured Nexys A7-100 board. BUGFIX in MIG configuration.
  Now fully [FPGA tested and verified](https://github.com/wfjm/w11/issues/16).
- **2019-01-02**: initial version, only simulation tested (no board available
  for FPGA testing)


