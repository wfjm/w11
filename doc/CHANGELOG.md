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
### General Proviso
The HEAD version shows the current development. No guarantees that
software or firmware builds or that the documentation is consistent.
The full set of tests is only run for tagged releases.

### Special Provisos
- DEUNA still with very limited functionality and testing
  - no buffer chaining
  - no loopback
  - no memory access error checking
  - works with 211bsd, ping and telnet login tested
  - RSX11-M uses buffer chaining, will not work

### Summary
- cleanup 211bsd system images (oskits)
  - 211bsd_rp, the master, see [CHANGELOG](../tools/oskit/211bsd_rp/CHANGELOG.md)
  - 211bsd_rk, see [CHANGELOG](../tools/oskit/211bsd_rl/CHANGELOG.md)
  - 211bsd_rl, see [CHANGELOG](../tools/oskit/211bsd_rk/CHANGELOG.md)
- Rw11CntlPC11,Rw11CntlDL11: trace received chars
- Miscellaneous fixes and changes
  - Makefile: add all_tcl to all; use njobihtm
  - rlink_core: BUGFIX: correct re-transmit after nak aborts
  - tb_rlink_stim.dat: start section B (error aborts) and C (retransmit)
  - ticonv_rri: use 'rlc rawwblk' instead of 'rlc rawio -wblk'
  - rbmoni/test_regs.tcl: add data/addr logic tests
- tools for setting up ethernet bridge and tap
  - add ip_create_br: create bride and convert default ethernet interface
  - add ip_create_tap: create use-mode tap device
  - add ip_inspect: helper script
- re-arrange rawio commands for rlc and rlp
  - RtclRlink(Connect|Port): drop M_rawio; add M_rawread,M_rawrblk,M_rawwblk
  - RtclRlinkPort: LogFileName(): returns now const std::string&
- BUGFIXes for backend
  - RlinkPort: BUGFIX: RawRead(): proper irc for exactsize=false
  - Rexception: BUGFIX: add fErrtxt for proper what() return
- sys_w11a_n(2|3): use SWI(7:6) to allow fx2 debug via LEDs
- BUGFIX: resolve hangup of fx2 USB controller
  - was caused by inconsistent use of rx fifo thresholds
  - adding more lines to monitor output (fsm_* lines for state tracking)
- refurbish dmcmon
  - has now the sta,sto,sus,res logic as rbmon and ibmon
  - does not depend on full state number generation anymore
  - missed WAIT instructions so far, has been fixed
- dmcmon included in sys_w11a_n4 again
  - full snum generation code gives bad synthesis under vivado (fine in ISE)
  - the updated dmcmon can life with a simple, category based, snum
- integrate rbus monitor in w11 shell
  - ti_rri: setup rbus monitor if detected
  - rw11/shell.tcl: add .rme,.rmd,.rmf,.rml
  - ibd_ibmon/util.tcl: move out imap_reg2addr
  - rbmoni/util.tcl: add procs filter,rme,rmf
  - rlink/util.tcl: add amap_reg2addr
  - rw11/util.tcl: move in imap_reg2addr; add imap_range2addr
  - rw11/shell.tcl: integrate rbmon: add .rme,.rmd,.rmf,.rml
- make setup procs idempotent
  - RlinkConnect: add rbus monitor probe, add HasRbmon()
  - RtclRlinkConnect: M_amap: -testname opt addr check; add hasrbmon get
  - RtclRw11Cpu: M_(imap|rmap): -testname optional addr check
  - */util.tcl: setup: now idempotent
- w11 shell .bs now support ibus register names and ranges
  - rw11/dmhbpt.tcl: hb_set: use imap_range2addr, allow regnam and range
- add DEUNA (ethernet) support
  - add DEUNA device (xu) for ibus
  - add DEUNA to all sys_w11a systems
    - add ibdr_deuna to maxisys
    - setup sys_conf for all systems
  - backend support classes for networking
    - RethBuf: ethernet buffer
    - RethTools: some handy tools
    - Rw11VirtEth: new virt base for ethernet
    - Rw11VirtEthTap: concrete networking via tap devices
  - backend for DEUNA
    - Rw11CntlDEUNA: controller and almost all logic
    - Rw11UnitDEUNA: unit
  - tcl support for DEUNA
  - tbench support for DEUNA
  - some new preinit and preboot hooks
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
