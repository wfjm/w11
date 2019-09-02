## Notes on w11 systems: w11a for and Nexys 3

- [Basics](#user-content-basics)
- [Usage](#user-content-usage)
- [Status & History](#user-content-status)

### <a id="basics">Basics</a>

The [sys_w11a_n3](sys_w11a_n3.vhd) system is a
[w11a](../../../w11a) implementation for the Digilent
[Nexys 3](https://wfjm.github.io/home/w11/inst/boards.html#digi_nexys3)
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

The Nexys 3 board was the main w11 development platforms until the
Nexys 4 board arrived and development moved from ISE to Vivado.
Together with the Nexys 2 board, it still has the best I/O performance
thanks to the USB 2 speed and low-latency rlink connection.
The sys_w11a_n3 design is occasionally FPGA tested with
[ostest](../../../../tools/bin/ostest) against all
[oskits](../../../../tools/oskit). 

- **2011-11-20**: initial version
