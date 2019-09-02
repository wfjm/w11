## Notes on w11 systems: w11a for and Nexys 2

- [Basics](#user-content-basics)
- [Usage](#user-content-usage)
- [Status & History](#user-content-status)

### <a id="basics">Basics</a>

The [sys_w11a_n2](sys_w11a_n2.vhd) system is a
[w11a](../../../w11a) implementation for the Digilent
[Nexys 2](https://wfjm.github.io/home/w11/inst/boards.html#digi_nexys2)
board.
For complete configuration, see [sys_conf.vhd](sys_conf.vhd).
The most important features are:

| Property | Value |
| -------- | ----- |
| CPU options | FPP: no; Cache: 8 kB |
| Memory   | 3840 kB from PSRAM via [nx_cram_memctl_as](../../../bplib/nxcramlib/nx_cram_memctl_as.vhd) |
| Devices | DL11:2; DZ11, PC11, LP11, DEUNA, RK11, RL11, RHRP, TM11, IIST, KW11P, M9312: yes |
| Diagnostics | rbmon: yes; ibmon: yes; dmpcnt: yes; dmhbpt: 2; dmcmon: yes |
| Rlink | USB 2 speed over Cypress FX2 |

### <a id="usage">Usage</a>
The board has 8 LEDs and offers only a compactified console light emulation.
The memory size of 3840 kB allows starting all [oskits](../../../../tools/oskit).

For complete instructions on how to run operating system images,
[see w11a_os_guide](../../../../doc/w11a_os_guide.md).
The default setup is:

```
  SWI = 00101100
  ti_w11 -u @<oskit-name>_boot.tcl
```

### <a id="status">Status & History</a>

The Nexys 2 board was, along with the Nexys 3 board, the main w11
development platforms until the Nexys 4 board arrived and development
moved from ISE to Vivado.
Together with the Nexys 3 board, it still has the best I/O performance
thanks to the USB 2 speed and low-latency rlink connection.
The sys_w11a_n2 design is occasionally FPGA tested with
[ostest](../../../../tools/bin/ostest) against all
[oskits](../../../../tools/oskit). 

- **2010-05-28**: initial version
