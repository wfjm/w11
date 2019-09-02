## Notes on w11 systems: w11a for Arty S7-50

- [Basics](#user-content-basics)
- [Usage](#user-content-usage)
- [Status & History](#user-content-status)

### <a id="basics">Basics</a>

The [sys_w11a_as7](sys_w11a_as7.vhd) system is a
[w11a](../../../w11a) implementation for the Digilent
[Arty S7-50](https://wfjm.github.io/home/w11/inst/boards.html#digi_artys7)
board with DDR3 SDRAM support via a Vivado MIG core.
For complete configuration, see [sys_conf.vhd](sys_conf.vhd).
The most important features are:

| Property | Value |
| -------- | ----- |
| CPU options | FPP: no; Cache: 32 kB |
| Memory   | 3840 kB from DDR3 SDRAM via [miglib_artys7](../../../bplib/artys7/miglib_artys7.vhd) |
| Devices | DL11:2; DZ11, PC11, LP11, DEUNA, RK11, RL11, RHRP, TM11, IIST, KW11P, M9312: yes |
| Diagnostics | rbmon: yes; ibmon: yes; dmpcnt: yes; dmhbpt: 2; dmcmon: yes |
| Rlink | 12 Mbps via FT2232HQ based serial link |

An alternative design that uses only BRAM is available as
[sys_w11a_br_as7](../artys7_bram).

### <a id="usage">Usage</a>

The board has only 4 LEDs plus 2 RGB-LEDS and offers only a very rudimentary
console light emulation.
The memory size of 3840 kB allows starting all [oskits](../../../../tools/oskit).

For complete instructions on how to run operating system images,
[see w11a_os_guide](../../../../doc/w11a_os_guide.md).
The default setup is:

```
  SWI = 0110                (gives console light emulation...)
  ti_w11 -tuD,12M,break,xon  @<oskit-name>_boot.tcl
```

### <a id="status">Status & History</a>

The author doesn't have an Arty S7 board and doesn't plan to buy one.
The design was made to study differences between Artix-7 and Spartan-7.
The design is [only simulation tested](https://github.com/wfjm/w11/issues/17).

- **2019-01-12**: initial version
