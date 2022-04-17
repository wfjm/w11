# w11: PDP 11/70 CPU and SoC

[![ci](https://github.com/wfjm/w11/workflows/ci/badge.svg)](https://github.com/wfjm/w11/actions/workflows/ci.yml)
[![Coverity Status](https://scan.coverity.com/projects/16546/badge.svg?flat=1)](https://scan.coverity.com/projects/wfjm-w11)
[![Commits since latest release](https://img.shields.io/github/commits-since/wfjm/w11/latest.svg?longCache=true)](https://github.com/wfjm/w11/releases)


### Overview
The project contains the VHDL code for a **complete DEC PDP-11 system**:
a
[PDP-11/70](http://www.bitsavers.org/pdf/dec/pdp11/1170/EK-KB11C-TM-001_1170procMan.pdf)
CPU with memory management unit, but without floating point unit,
a complete set of mass storage peripherals
([RK11/RK05](http://www.bitsavers.org/pdf/dec/unibus/RK11-C_manual1971.pdf),
[RL11/RL02](http://www.bitsavers.org/pdf/dec/disc/rl01_rl02/EK-RL122-TM-001_techAug82.pdf),
[RH70](http://www.bitsavers.org/pdf/dec/unibus/CSS-MO-F-5.2-27_RH70_Option_Description_Feb77.pdf)/[RP06](http://www.bitsavers.org/pdf/dec/disc/rp04_rp05_rp06/EK-RP056-MM-01_maint_Dec75.pdf),
[TM11/TU10](http://www.bitsavers.org/pdf/dec/magtape/tm11/TM11_Manual.pdf))
and a rather complete set of UNIBUS peripherals
([DL11](http://www.bitsavers.org/pdf/dec/unibus/EK-DL11-TM-003_DL11_Asynchronous_Line_Interface_Manual_Sep75.pdf),
[LP11](http://www.bitsavers.org/pdf/dec/unibus/LP11_UsersMan.pdf),
[PC11](http://www.bitsavers.org/pdf/dec/unibus/PC11_Reader-Punch_Manual.pdf),
[DZ11](http://www.bitsavers.org/pdf/dec/unibus/EK-DZ110-TM-002_DZ11_Asynchronous_Multiplexer_Technical_Manual_Oct78.pdf), and
[DEUNA](http://www.bitsavers.org/pdf/dec/unibus/EK-DEUNA-TM-PRE_TechMan_Dec82.pdf)),
and last but not least a cache and memory controllers for SRAM, PSRAM and
SDRAM (via Xilinx MIG core).
The design is **FPGA proven**, runs currently on Digilent
[Arty A7](rtl/sys_gen/w11a/arty),
[Basys3](rtl/sys_gen/w11a/basys3),
[Cmod A7](rtl/sys_gen/w11a/cmoda7),
[Nexys A7](rtl/sys_gen/w11a/nexys4d),
[Nexys4](rtl/sys_gen/w11a/nexys4),
[Nexys3](rtl/sys_gen/w11a/nexys3),
[Nexys2](rtl/sys_gen/w11a/nexys2) and
[S3board](rtl/sys_gen/w11a/s3board)
boards and boots 5th Edition UNIX and 2.11BSD UNIX. 

For more information look into:
- w11 project [home page](https://wfjm.github.io/home/w11/)
  and [blog](https://wfjm.github.io/blogs/w11/)
- [change log](doc/CHANGELOG.md)
  and [installation notes](doc/INSTALL.md)
- guides to build bit files and test benches
  with [Xilinx Vivado](doc/README_buildsystem_Vivado.md)
  and [Xilinx ISE](doc/README_buildsystem_ISE.md)
- guides to [run test benches](doc/w11a_tb_guide.md)
  and to [boot operating systems](doc/w11a_os_guide.md)
- known [issues](doc/README_known_issues.md)
- known [differences](doc/w11a_known_differences.md)
- the impatient readers can try their luck with the
  [quick start guide](doc/INSTALL_quickstart.md)

A short description of the directory layout
[is provided separately](https://wfjm.github.io/home/w11/impl/dirlayout.html),
the top level directories are

| Directory | Content |
| --------- | ------- |
| [doc](doc)     | documentation |
| [rtl](rtl)     | HDL sources (mostly vhdl) |
| [tools](tools) | many tools |

### Note on freecores/w11
The [freecores team](http://freecores.github.io/) created in 2014 a
copy of almost all OpenCores cores in Github under
[freecores](https://github.com/freecores). This created
[freecores/w11](https://github.com/freecores/w11)
which is 
[*outdated* and *not maintained*](https://github.com/freecores/w11/issues/1).
***Only [wfjm/w11](https://github.com/wfjm/w11) is maintained***.

### License
This project is released under the 
[GPL V3 license](https://www.gnu.org/licenses/gpl-3.0.html),
all files contain a [SPDX](https://spdx.org/)-style disclaimer:

    SPDX-License-Identifier: GPL-3.0-or-later

The full text of the GPL license is in this directory as
[License.txt](License.txt).
