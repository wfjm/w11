## Notes on w11 systems: w11a for Basys 3

- [Basics](#user-content-basics)
- [Usage](#user-content-usage)
- [Status & History](#user-content-status)

### <a id="basics">Basics</a>

The [sys_w11a_b3](sys_w11a_b3.vhd) system is a
[w11a](../../../w11a) implementation for the Digilent
[Basys 3](https://wfjm.github.io/home/w11/inst/boards.html#digi_basys3)
board. The w11 memory is based on BRAMs only because the board doesn't
feature any memory outside the FPGA.

For complete configuration, see [sys_conf.vhd](sys_conf.vhd).
The most important features are:

| Property | Value |
| -------- | ----- |
| CPU options | FPP: no; Cache: 8 kB |
| Memory   | 176 kB from BRAMs via [pdp11_bram_memctl](../../../w11a/pdp11_bram_memctl.vhd) |
| Devices | DL11:2; DZ11, PC11, LP11, DEUNA, RK11, RL11, RHRP, TM11, IIST, KW11P, M9312: yes |
| Diagnostics | rbmon: **no**; ibmon: **no**; dmpcnt: yes; dmhbpt: 2; dmcmon: **no** |
| Rlink | 12 Mbps via FT2232HQ based serial link |

### <a id="usage">Usage</a>

The board has 16 LEDs and allows a nice console light emulation.
The memory size of 176 kB allows starting a few
[oskits](../../../../tools/oskit).
u5ed works fine. XXDP, RT11 and RSX-11M should work. 211bsd will not boot,
neither most RSX-11M+ systems.

For complete instructions on how to run operating system images,
[see w11a_os_guide](../../../../doc/w11a_os_guide.md).
The default setup is:

```
  SWI = 00000000 00101000   (gives console light display on LEDS)
  ti_w11 -tuD,12M,break,xon  @<oskit-name>_boot.tcl
```

### <a id="status">Status & History</a>

The Basys 3 board is one of the w11 development platforms.
The sys_w11a_b3 design is regularly FPGA tested with
[ostest](../../../../tools/bin/ostest) against the
[oskits](../../../../tools/oskit) running with 176 kB memory.

- **2015-02-08**: initial version.
