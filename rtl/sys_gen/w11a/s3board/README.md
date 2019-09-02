## Notes on w11 systems: w11a for and S3BOARD

- [Basics](#user-content-basics)
- [Usage](#user-content-usage)
- [Status & History](#user-content-status)

### <a id="basics">Basics</a>

The [sys_w11a_s3](sys_w11a_s3.vhd) system is a
[w11a](../../../w11a) implementation for the Digilent
[S3BOARD](https://wfjm.github.io/home/w11/inst/boards.html#digi_s3board)
board.
For complete configuration, see [sys_conf.vhd](sys_conf.vhd).
The most important features are:

| Property | Value |
| -------- | ----- |
| CPU options | FPP: no; Cache: 8 kB |
| Memory   | 1024 kB from SRAM via [s3_sram_memctl](../../../bplib/s3board/s3_sram_memctl.vhd) |
| Devices | DL11:2; DZ11, PC11, LP11, DEUNA, RK11, RL11, RHRP, TM11, IIST, KW11P, M9312: yes |
| Diagnostics | rbmon: yes; ibmon: yes; dmpcnt: yes; dmhbpt: 2; dmcmon: yes |
| Rlink | 460 kbps via USB-RS232 cable connected to the RS232 port |

### <a id="usage">Usage</a>
The board has 8 LEDs and offers only a compactified console light emulation.
The memory size of 1024 kB allows starting all [oskits](../../../../tools/oskit).

For complete instructions on how to run operating system images,
[see w11a_os_guide](../../../../doc/w11a_os_guide.md).
The default setup is:

```
  SWI = 00101010
  ti_w11 -tu<dn>,460k,break,xon @<oskit-name>_boot.tcl
```

### <a id="status">Status & History</a>

The S3BOARD was the first w11 development platform. All inital w11
developments were done with this board. In 2011, the developemt switched
to the Nexys 2 board, as this board offered full 4 MB memory, and
more importantly, a high speed rlink connection.
The S3BOARD is still available, but is no longer actively used.
The design is retained for historical and nostalgic reasons.

- **2007-09-23**: initial version
