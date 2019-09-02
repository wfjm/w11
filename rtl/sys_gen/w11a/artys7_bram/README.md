## Notes on w11 systems: w11a for Arty S7-50 (BRAM only)

- [Basics](#user-content-basics)
- [Usage](#user-content-usage)
- [Status & History](#user-content-status)

### <a id="basics">Basics</a>

The [sys_w11a_br_as7](sys_w11a_br_as7.vhd) system is a
[w11a](../../../w11a) implementation for the Digilent
[Arty S7-50](https://wfjm.github.io/home/w11/inst/boards.html#digi_artys7)
board , where the w11 memory is based only on BRAMs.
For complete configuration, see [sys_conf.vhd](sys_conf.vhd).
The most important features are:

| Property | Value |
| -------- | ----- |
| CPU options | FPP: no; Cache: 8 kB |
| Memory   | 256 kB from BRAMs via [pdp11_bram_memctl](../../../w11a/pdp11_bram_memctl.vhd) |
| Devices | DL11:2; DZ11, PC11, LP11, DEUNA, RK11, RL11, RHRP, TM11, IIST, KW11P, M9312: yes |
| Diagnostics | rbmon: **no**; ibmon: **no**; dmpcnt: yes; dmhbpt: 2; dmcmon: **no**|
| Rlink | 12 Mbps via FT2232HQ based serial link |

A design with full SDRAM memory support is available as
[sys_w11a_artys7](../artys7).

### <a id="usage">Usage</a>

The board has only 4 LEDs plus 2 RGB-LEDS and offers only a very rudimentary
console light emulation.
The memory size of 256 kB allows starting a few
[oskits](../../../../tools/oskit).
u5ed works fine. XXDP, RT11 and RSX-11M should work. 211bsd will not boot,
neither most RSX-11M+ systems.

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

- **2018-08-11**: initial version
