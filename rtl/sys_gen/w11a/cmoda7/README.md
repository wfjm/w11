## Notes on w11 systems: w11a for Cmod A7-35

- [Basics](#user-content-basics)
- [Usage](#user-content-usage)
- [Status & History](#user-content-status)

### <a id="basics">Basics</a>

The [sys_w11a_c7](sys_w11a_c7.vhd) system is a
[w11a](../../../w11a) implementation for the Digilent
[Cmod A7-35](https://wfjm.github.io/home/w11/inst/boards.html#digi_cmoda7)
board. 

For complete configuration, see [sys_conf.vhd](sys_conf.vhd).
The most important features are:

| Property | Value |
| -------- | ----- |
| CPU options | FPP: no; Cache: 16 kB |
| Memory   | 672 kB combined from 512 kB SRAM via [c7_sram_memctl](../../../bplib/cmoda7/c7_sram_memctl.vhd) and 160 kB BRAMs via [pdp11_bram_memctl](../../../w11a/pdp11_bram_memctl.vhd) |
| Devices | DL11:2; DZ11, PC11, LP11, DEUNA, RK11, RL11, RHRP, TM11, IIST, KW11P, M9312: yes |
| Diagnostics | rbmon: yes; ibmon: yes; dmpcnt: yes; dmhbpt: 2; dmcmon: yes |
| Rlink | 12 Mbps via FT2232HQ based serial link |

### <a id="usage">Usage</a>

The board has no LEDs and thus no console light emulation.
The memory size of 672 kB allows starting only a subset of the available
[oskits](../../../../tools/oskit).
u5ed, u7ed, XXDP, RT11, RSX-11M and most most RSX-11M+ systems should work.
211bsd works only in the 'non-networking' configuration
[211bsd_rpmin](../../../../tools/oskit/211bsd_rpmin).

For complete instructions on how to run operating system images,
[see w11a_os_guide](../../../../doc/w11a_os_guide.md).
The default setup is:

```
  ti_w11 -tuD,12M,break,xon  @<oskit-name>_boot.tcl
```

### <a id="status">Status & History</a>

The Cmod A7-35 board is one of the w11 development platforms.
The sys_w11a_c7 design is regularly FPGA tested with
[ostest](../../../../tools/bin/ostest) against the
[oskits](../../../../tools/oskit) running with 672 kB memory.

- **2017-06-24**: initial version.
