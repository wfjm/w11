## Notes on w11 systems: w11a for and Nexys 4

- [Basics](#user-content-basics)
- [Usage](#user-content-usage)
- [Status & History](#user-content-status)

### <a id="basics">Basics</a>

The [sys_w11a_n4](sys_w11a_n4.vhd) system is a
[w11a](../../../w11a) implementation for the Digilent
[Nexys 4](https://wfjm.github.io/home/w11/inst/boards.html#digi_nexys4)
board.
For complete configuration, see [sys_conf.vhd](sys_conf.vhd).
The most important features are:

| Property | Value |
| -------- | ----- |
| CPU options | FPP: no; Cache: 32 kB |
| Memory   | 3840 kB from PSRAM via [nx_cram_memctl_as](../../../bplib/nxcramlib/nx_cram_memctl_as.vhd) |
| Devices | DL11:2; DZ11, PC11, LP11, DEUNA, RK11, RL11, RHRP, TM11, IIST, KW11P, M9312: yes |
| Diagnostics | rbmon: yes; ibmon: yes; dmpcnt: yes; dmhbpt: 2; dmcmon: yes |
| Rlink | 12 Mbps via FT2232HQ based serial link |

### <a id="usage">Usage</a>
The board has 16 LEDs and allows a nice console light emulation.
The memory size of 3840 kB allows starting all [oskits](../../../../tools/oskit).

For complete instructions on how to run operating system images,
[see w11a_os_guide](../../../../doc/w11a_os_guide.md).
The default setup is:

```
  SWI = 00000000 00101000   (gives console light display on LEDS)
  ti_w11 -tuD,12M,break,cts  @<oskit-name>_boot.tcl
```

### <a id="status">Status & History</a>

The Nexys 4 board was the main w11 development platforms until it
[failed in July 2019](https://wfjm.github.io/blogs/w11/2019-07-27-nexys4-obituary.html). Until July 2019 the sys_w11a_n4 design was often FPGA tested with
[ostest](../../../../tools/bin/ostest) against all
[oskits](../../../../tools/oskit). Since July 2019 this design is
only simulation tested.

- **2019-07-20**: board failed, from now on the design only simulation tested
- **2013-09-22**: initial version


