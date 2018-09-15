# Changelog: w11a_V0.74 -> HEAD

### Table of contents
- Current [HEAD](#user-content-head)
- Release [w11a_V0.752](#user-content-w11a_V0.752)
- Release [w11a_V0.751](#user-content-w11a_V0.751)
- Release [w11a_V0.75](#user-content-w11a_V0.75)
- Release [w11a_V0.742](#user-content-w11a_V0.742)
- Release [w11a_V0.741](#user-content-w11a_V0.741)
- [CHANGELOG for w11a_V.70 to w11a_V0.74](CHANGELOG-w11a_V0.70-w11a_V0.74.md)
- [CHANGELOG for w11a_V.60 to w11a_V0.70](CHANGELOG-w11a_V0.60-w11a_V0.70.md)
- [CHANGELOG for w11a_V.50 to w11a_V0.60](CHANGELOG-w11a_V0.50-w11a_V0.60.md)

<!-- --------------------------------------------------------------------- -->
---
## <a id="head">HEAD</a>
### General Proviso
The HEAD version shows the current development. No guarantees that
software or firmware builds or that the documentation is consistent.
The full set of tests is only run for tagged releases.

### Summary
- add Travis CI integration (phase 1)
- add Coverity (manual scan upload, not via Travis)
- add KW11-P (programmable clock) to all w11 systems
- sys_w11_n4: reduce cache from 64 to 32 kB to keep timing closure
- stay with vivado 2017.2 as default tool, 2017.2 to 2018.2 exhibit much
  longer build times for w11 designs (see Xilinx Forum post [884858](https://forums.xilinx.com/t5/Synthesis/vivado-2018-2-much-slower-than-2017-2-at-least-for-small-designs/m-p/884858))

<!-- --------------------------------------------------------------------- -->
---
## <a id="w11a_V0.752">2018-08-26: [w11a_V0.752](https://github.com/wfjm/w11/releases/tag/w11a_V0.752) - rev 1041(wfjm)</a>
### Summary
- the Arty board is now also offered with a Spartan-7 FPGA. To evaluate the
  Spartan vs Artix performance a w11a port to the Arty S7 board was added.
  The design runs with 80 MHz, same clock rate as achieved with Artix-7 FPGAs.
  _Note_: the design is only simulation tested, was _not FPGA tested_ !!
- use vivado 2017.2 as default (needed for Spartan-7 support). All vivado
  versions from 2017.3 to 2018.2 were tested. All designs build properly under
  vivado 2018.2, but the CPU time for a build increased very substantially,
  so they are currently not used as default build tool.

### New features
- Add Digilent Arty A7 (50 die size) support
  - general board support (for rev E board)
  - rgbdrv_3x2mux.vhd : driver for array with 2 RGB LEDs
  - add systems
    - w11a: w11a system with 256 kB memory (from BRAM) (_only sim tested_)
### Changes
- xviv_msg_filter: allow {yyyy.x} tags (in addition to ranges)
- xviv_msg_summary: check also for .bit and .dcp files
- get vivado 2017.2 ready (needed for Spartan-7 support)
- test vivado 2017.3 - 2018.2 ready
  - *.vmfset: update rules to cover 2017.4-2018.2
  - all designs build under 2017.2 and 2018.2

<!-- --------------------------------------------------------------------- -->
---
## <a id="w11a_V0.751">2018-08-10: [w11a_V0.751](https://github.com/wfjm/w11/releases/tag/w11a_V0.751) - rev 1037(wfjm)</a>

### Summary
- The license disclaimers in the source files referred so far to GPL V2 or later
  They are now consistent with the License.txt file, which refers to GPL V3.
- Add Digilent Cmod A7 (35 die size) support
- Add [INSTALL_quickstart](INSTALL_quickstart.md)
- get vivado 2017.1 ready
- Added Unix 7th Edition oskit; rename 5th Edition kit
  - u5ed_rk: renamed from unix-v5_rk
  - u7ed_rp: added, very preliminary, boots on CmodA7, further testing needed

### New features
- Add Digilent Cmod A7 (35 die size) support
  - general board support
  - c7_sram_memctl: SRAM memory controller (incl tb)
  - is61wv5128bll: simple memory model (incl tb)
  - sn_humanio_emu_rbus: human IO emulator
  - 92-retro-usb-persistent.rules: add more board rules
  - associated changes
    - sn_humanio_rbus: add stat_rbf_emu (=0); single cycle btn pulses
    - rgbdrv_analog(_rbus): add ACTLOW generic to invert output polarity
    - ti_rri: adopt Digilent autodetect for CmodA7
  - add systems
    - tst_rlink: rlink tester
    - tst_sram: SRAM tester
    - w11a: w11a system with 672 kB memory (512 SRAM + 160 BRAM)
- rtl/vlib/rutil.vhd: added package, with imin helper function

### Changes
- cleanups
  - s3_sram_memctl: drop superfluous idata_cei=1 in s_write2
- 17bit support for tst_sram
  - tst_sram.vhd: allow AWIDTH=17; sstat_rbf_awidth instead of _wide
  - tcl/tst_sram/*.tcl: 17bit support; use sstat(awidth); add isnarrow
- get vivado 2017.1 ready
  - xviv_msg_filter: add version-range tag support
  - *.vmfset:
    - drop the nonsense 'Synth 8-6014' messages
    - adopt to different path used by 'Synth 8-3332' messages
- Rw11VirtDiskOver: more detailed stats
- add test_w11a_mem70.tcl; retire old tests tb_w11a_mem70*.dat

### Bug Fixes
- shell_egd.tcl: BUGFIX: shell_pspec_map: fix mapping for addr>20000

### Known issues

<!-- --------------------------------------------------------------------- -->
---
## <a id="w11a_V0.75">2017-06-04: [w11a_V0.75](https://github.com/wfjm/w11/releases/tag/w11a_V0.75) - rev 904(wfjm)</a>

### Summary
- the only device class missing so far for the w11 was *network interfaces*.
  This release adds a preliminary and functionally restricted `DEUNA` Ethernet
  interface and thus for the the first time full networking support for 211bsd.
  The provisos for the current implementation are
  - no buffer chaining
  - no loopback
  - no memory access error checking
  - works with 211bsd: ping, telnet, and ftp tested
  - RSX11-M uses buffer chaining, will definitively not work
- move to Ubuntu 16.04 as development platform
  - document urjtag build (jtag in Ubuntu 16.04 is broken)
  - add environment sanity wrappers for acroread,awk,firefox to ensure
    proper operation of vivado under Ubuntu 16.04
  - use -std=c++11 (gcc 4.7 or later)
  - for all FTDI USB-UART it is essential to set them to `low latency` mode.
    That was default for linux kernels 2.6.32 to 4.4.52. Since about March
    2017 one gets kernels with 16 ms default latency again, thanks to
    [kernel patch 9589541](https://patchwork.kernel.org/patch/9589541/).
    **For newer systems it is essential to install a udev rule** which
    automatically sets low latency, see [documentation](../tools/sys/README.md).
- the cpu monitor dmcmon was not available in vivado systems due to synthesis
  issues caused by dmscnt. Is resolved, dmcmon now part of sys_w11a_n4.
- many improvements to the w11 shell in ti_w11: rbmon integrated, usage
  of ibmon and dmcmon streamlined.
- add *overlay* file system (Rw11VirtDiskOver, scheme over:) which keeps all
  write in backend memory. Very convenient for development. The changes can
  be written to the disk image with a tcl level command (cpu0* virt flush).
- add two new 211bsd system images (oskits)
  - 211bsd_rpmin: for small memory systems (512 or 672 kB)
  - 211bsd_rpeth: with DEUNA Ethernet support
- cleanup 211bsd system images (oskits)
  - 211bsd_rp, the master, see [CHANGELOG](../tools/oskit/211bsd_rp/CHANGELOG.md)
  - 211bsd_rk, see [CHANGELOG](../tools/oskit/211bsd_rl/CHANGELOG.md)
  - 211bsd_rl, see [CHANGELOG](../tools/oskit/211bsd_rk/CHANGELOG.md)
- man pages now [available online](http://www.retro11.de/manp/w11/man/cat1/).

### New features
- add DEUNA (Ethernet) support
  - add DEUNA device (xu) for ibus
  - add DEUNA to all sys_w11a systems
    - add ibdr_deuna to maxisys
    - setup sys_conf for all systems
  - backend support classes for networking
    - RethBuf: Ethernet buffer
    - RethTools: some handy tools
    - Rw11VirtEth: new virt base for Ethernet
    - Rw11VirtEthTap: concrete networking via tap devices
  - backend for DEUNA
    - Rw11CntlDEUNA: controller and almost all logic
    - Rw11UnitDEUNA: unit
  - tcl support for DEUNA
  - tbench support for DEUNA
  - some new preinit and preboot hooks
- tools for setting up Ethernet bridge and tap
  - add ip_create_br: create bride and convert default Ethernet interface
  - add ip_create_tap: create use-mode tap device
  - add ip_inspect: helper script
- update USB serial latency handling
  - 91-retro-usb-latency.rules: udev rule to set low latency for FDTI USB UART
  - 92-retro-usb-persistent.rules: udev rule for persistent device names
  - 99-retro-usb-permissions.rules renamed to 90-retro-usb-permissions.rules
- add Rw11VirtDiskOver (simple overlay file container)
  - Rw11VirtDiskBuffer: added, disk buffer representation
  - Rw11VirtDiskOver: added, a 'keep changes in memory' overlay file container
  - Rw11Virt: add fWProt,WProt()
  - Rw11VirtDiskFile: adopt WProt handling
  - RtclRw11Unit: add fpVirt,DetachCleanup(),AttachDone(),M_virt()
  - RtclRw11UnitBase: add AttachDone()
- RtimerFd: first practical version
- Rtime: class for absolute and delta times

### Changes
- sys_w11a_n(2|3): use SWI(7:6) to allow fx2 debug via LEDs
- sys_tst_sram_n4: add sysmon_rbus
- 23 line interrupt mapper for full system configuration
- revise interface for ibd_ibmon and rbd_rbmon
  - use start,stop,suspend,resume functions; improved stop on wrap handling
  - add 'repeat collapse' logic (store only first and last of a sequence)
- refurbish dmcmon
  - has now the sta,sto,sus,res logic as rbmon and ibmon
  - does not depend on full state number generation anymore
  - missed WAIT instructions so far, has been fixed
- dmcmon included in sys_w11a_n4 again
  - full snum generation code gives bad synthesis under vivado (fine in ISE)
  - the updated dmcmon can life with a simple, category based, snum
- move hook_*.tcl files to tools/oskiit/hook directory
- w11 shell .bs now support ibus register names and ranges
  - rw11/dmhbpt.tcl: hb_set: use imap_range2addr, allow regnam and range
- integrate rbus monitor in w11 shell
  - ti_rri: setup rbus monitor if detected
  - rw11/shell.tcl: add .rme,.rmd,.rmf,.rml
  - ibd_ibmon/util.tcl: move out imap_reg2addr
  - rbmoni/util.tcl: add procs filter,rme,rmf
  - rlink/util.tcl: add amap_reg2addr
  - rw11/util.tcl: move in imap_reg2addr; add imap_range2addr
  - rw11/shell.tcl: integrate rbmon: add .rme,.rmd,.rmf,.rml
- update probe handling
  - probe/setup auxiliary devices: kw11l,kw11p,iist
  - keep probe data, make it tcl gettable
- re-arrange rawio commands for rlc and rlp
  - RtclRlink(Connect|Port): drop M_rawio; add M_rawread,M_rawrblk,M_rawwblk
  - RtclRlinkPort: LogFileName(): returns now const std::string&
- make setup procs idempotent
  - RlinkConnect: add rbus monitor probe, add HasRbmon()
  - RtclRlinkConnect: M_amap: -testname opt addr check; add hasrbmon get
  - RtclRw11Cpu: M_(imap|rmap): -testname optional addr check
  - */util.tcl: setup: now idempotent
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
  - RparseUrl: add Set() with default scheme handling
- remove double inheritance in RtclRw11Unit* stack
  - RtclRw11Unit: drop fpCpu, use added Cpu()=0 instead
  - RtclRw11UnitBase: add TUV,TB; add TUV* ObjUV(); inherit from TB
  - RtclRw11Unit(Disk|Stream|Tape|Term): define ObjUV();inherit from RtclRw11Unit
  - RtclRw11Unit(dev): inherit from RtclRw11UnitBase
- update trace output handling
  - Rw11Cntl*: use controller name as message prefix
  - Rw11CntlPC11,Rw11CntlDL11: trace received chars
- more compact dumps, add Dump(..,detail)
  - RlinkCommand: add CommandInfo()
  - RtclCmdBase: add GetArgsDump()
  - RlinkCommandList: Dump(): add detail arg
  - Rstats: add NameMaxLength(); Print(): add counter name
  - Rw11Cntl: use Dump(detail) for PrimClist ect
  - Rw11(Cntl|Unit|Virt)*,: Dump(): add detail arg
  - many other classes: Dump(): add detail arg
  - RtclRw11(Cntl|Unit|*): M_dump: use GetArgsDump and Dump detail
- update time handling
  - use clock_gettime instead of gettimeofday
  - add Rtime support in RtclGet/RtclSet
  - use Rtime; drop Rtools::TimeOfDayAsDouble()
- tcl command handling update
  - support now sub-command handling
  - support dynamically created commands (like 'virt')
  - support command info (via '?' option)
- Auto-detection of Digilent boards with `FT2232HQ` interface for
  [ti_rri](http://www.retro11.de/manp/w11/man/cat1/ti_rri.0.html) and
  [ti_w11](http://www.retro11.de/manp/w11/man/cat1/ti_w11.0.html).
- miscellaneous fixes and changes
  - svn_set_ignore: check svn:ignore existence before reading it
  - telnet_wrapper: add 'r' --> reset and stty sane handling
  - Makefile: add all_tcl to all; use njobihtm
  - tb_rlink_stim.dat: start section B (error aborts) and C (re-transmit)
  - ticonv_rri: use 'rlc rawwblk' instead of 'rlc rawio -wblk'
  - rbmoni/test_regs.tcl: add data/addr logic tests
  - librw11/Rw11Cpu: add ModLalh()
  - librtools/Rstats: add IncLogHist() and fix + and * operator definition

### Bug Fixes
- rlink_core: BUGFIX: correct re-transmit after nak aborts
- resolve hangup of fx2 USB controller
  - was caused by inconsistent use of rx fifo thresholds
  - adding more lines to monitor output (fsm_* lines for state tracking)
- RlinkPort: BUGFIX: RawRead(): proper irc for exactsize=false
- Rexception: BUGFIX: add fErrtxt for proper what() return
- `rlc get logfile` or `rlc get *` crashed with segfault
  - error was a type mismatch in the getter declaration in RtclRlinkConnect
  - fixed by changing the return type in RlinkConnect

### Known issues

<!-- --------------------------------------------------------------------- -->
---
## <a id="w11a_V0.742">2017-01-07: [w11a_V0.742](https://github.com/wfjm/w11/releases/tag/w11a_V0.742) - rev 841(wfjm)</a>

### Summary
- fixes for Vivado 2016.4; all designs build under vivado 2016.4
- added **preliminary** support for Nexys4 DDR board (thanks to [Michael Lyle](https://github.com/mlyle) for testing!)
- [w11 shell](../tools/tcl/rw11/shell.tcl) re-organized and expanded,
  now default in [ti_w11](../tools/bin/ti_w11)
- `CPUERR` cleared with cpu reset (see [ECO-029](ECO-029-cpuerr_creset.md))
- `PS` initialized now with `000000` (see [ECO-028](ECO-028-ps_init.md))

<!-- --------------------------------------------------------------------- -->
---
## <a id="w11a_V0.741">2016-12-23: [w11a_V0.741](https://github.com/wfjm/w11/releases/tag/w11a_V0.741) - rev 826(wfjm)</a>
### Summary
- moved w11 repository from OpenCores to GitHub
  [wfjm/w11](https://github.com/wfjm/w11/)
- moved w11 project pages from OpenCores to GitHub-Pages
  [wfjm.github.io/home/w11](https://wfjm.github.io/home/w11/)
- converted existing documentation from plain text to markdown
- added README.md files in sub-directories
