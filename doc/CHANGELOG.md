# Changelog: w11a_V0.74 -> HEAD

### Table of contents
- Current [HEAD](#user-content-head)
- Release [w11a_V0.742](#user-content-w11a_V0.742)
- Release [w11a_V0.741](#user-content-w11a_V0.741)
- [CHANGELOG for w11a_V.70 to w11a_V0.74](CHANGELOG-w11a_V0.70-w11a_V0.74.md)
- [CHANGELOG for w11a_V.60 to w11a_V0.70](CHANGELOG-w11a_V0.60-w11a_V0.70.md)
- [CHANGELOG for w11a_V.50 to w11a_V0.60](CHANGELOG-w11a_V0.50-w11a_V0.60.md)

<!-- --------------------------------------------------------------------- -->
---
## HEAD <a name="head"></a>
### Proviso
_The HEAD version shows the current development. No guarantees that
software or firmware builds or that the documentation is consistent.
The full set of tests is only run for tagged releases.

### Summary
- factor out controller class specifics; add useful M_default output
  - RtclRw11Cntl*Base: add classes with Rdma,Disk,Stream.Tape,Term specifics
  - RtclRw11Cntl*: add class in ctor; derive from RtclRw11Cntl*Base
- make list cpus,cntls,units command gettable; make controller class gettable
  - RtclRw11: add CpuCommands() and cpus getter
  - RtclRw11Cntl: add UnitCommands() and uints and class getter
  - RtclRw11Cpu: add ControllerCommands() and cntls getter
  - RtclGet: add Tcl_Obj* getter
- make attach status and attach url gettable for units
  - Rw11Cntl,Rw11CntlBase: NUnit() now pure; add UnitBase()
  - Rw11Unit: add IsAttached(), AttachUrl()
  - Rw11UnitVirt: add VirtBase()
  - Rw11Virt: add Url() const getter
  - RtclRw11UnitBase: add attached,attachutl getters
- ensure that defaulted scheme visible in displayed open urls
  - pass default scheme to RparseUrl in Open()
  - add Open() overloads for Rw11VirtDiskFile and Rw11VirtDiskOver
  -  RparseUrl: add Set() with default scheme handling
- revise interface for ibd_ibmon and rbd_rbmon
  - use start,stop,suspend,resume functions; improved stop on wrap handling
  - add 'repeat collapse' logic (store only first and last of a sequence)
- BUGFIX: `rlc get logfile` or `rlc get *` crashed with segfault
  - error was a type mismatch in the getter declaration in RtclRlinkConnect
  - fixed by changing the return type in RlinkConnect
- remove double inheritance in RtclRw11Unit* stack
  - RtclRw11Unit: drop fpCpu, use added Cpu()=0 instead
  - RtclRw11UnitBase: add TUV,TB; add TUV* ObjUV(); inherit from TB
  - RtclRw11Unit(Disk|Stream|Tape|Term): define ObjUV();inherit from RtclRw11Unit
  - RtclRw11Unit(dev): inherit from RtclRw11UnitBase
- trace output with controller name
  - Rw11Cntl*: use controller name as message prefix
- more compact dumps, add Dump(..,detail)
  - RlinkCommand: add CommandInfo()
  - RtclCmdBase: add GetArgsDump()
  - RlinkCommandList: Dump(): add detail arg
  - Rstats: add NameMaxLength(); Print(): add counter name
  - Rw11Cntl: use Dump(detail) for PrimClist ect
  - Rw11(Cntl|Unit|Virt)*,: Dump(): add detail arg
  - many other classes: Dump(): add detail arg
  - RtclRw11(Cntl|Unit|*): M_dump: use GetArgsDump and Dump detail
- RtimerFd: first practical version
- use clock_gettime instead of gettimeofday
- add Rw11VirtDiskOver (simple overlay file container)
  - Rw11VirtDiskBuffer: added, disk buffer representation
  - Rw11VirtDiskOver: added, a 'keep changes in memory' overlay file container
  - Rw11Virt: add fWProt,WProt()
  - Rw11VirtDiskFile: adopt WProt handling
  - RtclRw11Unit: add fpVirt,DetachCleanup(),AttachDone(),M_virt()
  - RtclRw11UnitBase: add AttachDone()
- tcl command handling update
  - support now sub-command handling
  - support dynamically created commands (like 'virt')
  - support command info (via '?' option)
- move to Ubuntu 16.04 as development platform
  - document urjtag build (jtag in Ubuntu 16.04 is broken)
  - add environment sanity wrappers for acroread,awk,firefox to ensure
    proper operation of vivado under Ubuntu 16.04
- use Rtime; drop Rtools::TimeOfDayAsDouble()
- probe/setup auxilliary devices: kw11l,kw11p,iist
- librw11/Rw11Cpu: add ModLalh()
- librtools/Rstats: add IncLogHist() and fix + and * operator definition
- add Rtime support in RtclGet/RtclSet
- add librtools/Rtime: class for absolute and delta times
- use -std=c++11 (gcc 4.7 or later)
- update probe handling: add probe data, make it tcl getable
- 23 line interrupt mapper for full system configuration
- man pages now [available online](http://www.retro11.de/manp/w11/man/cat1/).
- add `sysmon_rbus` in `sys_tst_sram_n4`
- Auto-dection of Digilent boards with `FT2232HQ` interface for
  [ti_rri](http://www.retro11.de/manp/w11/man/cat1/ti_rri.0.html) and
  [ti_w11](http://www.retro11.de/manp/w11/man/cat1/ti_w11.0.html).

<!-- --------------------------------------------------------------------- -->
---
## 2017-01-07: [w11a_V0.742](https://github.com/wfjm/w11/releases/tag/w11a_V0.742) - rev 841(wfjm) <a name="w11a_V0.742"></a>

### Summary
- fixes for Vivado 2016.4; all designs build under vivado 2016.4
- added **preliminary** support for Nexys4 DDR board (thanks to [Michael Lyle](https://github.com/mlyle) for testing!)
- [w11 shell](../tools/tcl/rw11/shell.tcl) re-organized and expanded,
  now default in [ti_w11](../tools/bin/ti_w11)
- `CPUERR` cleared with cpu reset (see [ECO-029](ECO-029-cpuerr_creset.md))
- `PS` initialized now with `000000` (see [ECO-028](ECO-028-ps_init.md))

<!-- --------------------------------------------------------------------- -->
---
## 2016-12-23: [w11a_V0.741](https://github.com/wfjm/w11/releases/tag/w11a_V0.741) - rev 826(wfjm) <a name="w11a_V0.741"></a>
### Summary
- moved w11 repository from OpenCores to GitHub
  [wfjm/w11](https://github.com/wfjm/w11/)
- moved w11 project pages from OpenCores to GitHub-Pages
  [wfjm.github.io/home/w11](https://wfjm.github.io/home/w11/)
- converted existing documentation from plain text to markdown
- added README.md files in sub-directories
