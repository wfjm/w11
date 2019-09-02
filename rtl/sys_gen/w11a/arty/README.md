## Notes on w11 systems: w11a for Arty A7-35

- [Basics](#user-content-basics)
- [Usage](#user-content-usage)
- [Status & History](#user-content-status)

### <a id="basics">Basics</a>

The [sys_w11a_arty](sys_w11a_arty.vhd) system is a
[w11a](../../../w11a) implementation for the Digilent
[Arty A7-35](https://wfjm.github.io/home/w11/inst/boards.html#digi_arty) board
with DDR3 SDRAM support via a Vivado MIG core.
For complete configuration, see [sys_conf.vhd](sys_conf.vhd).
The most important features are:

| Property | Value |
| -------- | ----- |
| CPU options | FPP: no; Cache: 32 kB |
| Memory   | 3840 kB from DDR3 SDRAM via [miglib_arty](../../../bplib/arty/miglib_arty.vhd) |
| Devices | DL11:2; DZ11, PC11, LP11, DEUNA, RK11, RL11, RHRP, TM11, IIST, KW11P, M9312: yes |
| Diagnostics | rbmon: yes; ibmon: yes; dmpcnt: yes; dmhbpt: 2; dmcmon: yes |
| Rlink | 12 Mbps via FT2232HQ based serial link |

An alternative design that uses only BRAM is available as
[sys_w11a_br_arty](../arty_bram).

### <a id="usage">Usage</a>

The board has only 4 LEDs plus 4 RGB-LEDS and offers only a compactified
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

The Arty A7-35 board is one of the main w11 development platforms.
The sys_w11a_arty design is often FPGA tested with
[ostest](../../../../tools/bin/ostest) against all
[oskits](../../../../tools/oskit).

- **2019-06-05**: reduce clock to 72 MHz, Vivado 2919.1 fails with 75 MHz 
- **2019-01-27**: reduce clock to 75 MHz, Vivado 2918.3 fails with 80 MHz 
- **2018-11-18**: initial version, runs with 80 MHz using Vivado 2017.4



