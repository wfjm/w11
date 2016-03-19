$Id: README.txt 746 2016-03-19 13:08:36Z mueller $

Release notes for w11a

  Table of content:
  
  1. Documentation
  2. Change Log

1. Documentation -------------------------------------------------------------

  More detailed information on installation, build and test can be found 
  in the doc directory, specifically

    * README.txt: release notes
    * README_known_issues.txt: known issues
    * INSTALL.txt: installation and building test benches and systems
    * FILES.txt: short description of the directory layout, what is where ?
    * w11a_tb_guide.txt: running test benches
    * w11a_os_guide.txt: booting operating systems 
    * w11a_known_issues.txt: known differences, limitations and issues

2. Change Log ----------------------------------------------------------------

- trunk (2016-03-19: svn rev 35(oc) 746(wfjm); untagged w11a_V0.72)  +++++++++
  - Preface
    - The new low-cost Digilent Arty board is a very attractive platform.
      The DDR3 memory will take some time to integrate, in this release thus
      only designs using the BRAMs.
    - added support for the Vivado simulator. Simple test benches work fine.
      Rlink based test benches don't work due to a bug in Vivado 2015.4.
    - A rather esoteric CPU bug was fixed in release V0.71 but forgotten to
      mention in the README. See ECO-027-trap_mmu.txt for details.

  - Summary
    - added Arty support. The w11a design uses BRAMs as memory, like the
      Basys3 version. This gives 176 KByte memory, not enough for 2.11BSD, 
      but for many other less demanding OS available for a PDP11.
    - added support for SYSMON/XADC (see README_xadc.txt)
    - Vivado flow is now default for test benches of components and all Artix
      based systems. If applicable an ISE flow is available under Makefile.ise
      (resolves known issues V0.64-4 and V0.64-5).
    - re-factored tbcore_rlink to support DPI and VHPI
    - Vivado supports with DPI (from SystemVerilog) a mechanism to call
      external C code. The rlink test bench code so far relies on VHPI, which
      is supported by ghdl, but not by ISE ISim or Vivado xsim. The code was
      restructured and can use now DPI or VHPI to support both ghdl and
      Vivado. Unfortunately has Vivado 2015.4 a bug, DPI doesn't work in a
      mixed vhdl-verilog language environment (see Known issues), so the
      code base is there, but utilization will habe to wait.
    - Vivado synthesis by default keeps hierarchy. This leads to doubly defined
      modules if a component is used in both test bench and unit under test.
      To avoid this copies of s7_cmt_sfs and some serport_* modules were
      created and are now used in the test benches.

  - New features
    - new directory trees for
      - rtl/bplib/arty              - board support files for arty
      - rtl/bplib/sysmon            - driver + rbus iface for SYSMON/XADC
      - rtl/vlib/rlink/tbcore       - new location for rlink tb iface code
      - tools/tcl/rbsysmon          - sysmon/xadc support
    - new modules
      - rtl/bplib/bpgen
        - rgbdrv_*                  - driver + rbus iface for 3 color RGBLED
      - rtl/vlib/rlink/tbcore 
        - rlink_cext_iface_dpi.sv     - DPI based cext iface
        - rlink_cext_iface_vhpi.vhd   - VHPI based cext iface
        - rlink_cext_dpi.c            - dpi to vhpi adapter
      - rtl/vlib/serport/tb
        - serport_uart_*_tb           - added copies for tb usage
      - rtl/vlib/xlib/tb
        - s7_cmt_sfs_tb               - added copy for tb usage
      - 
    - new files
      - doc/man/man1
        - tbrun_tbw.1               - man file for tbrun_tbw
        - tbrun_tbwrri.1            - man file for tbrun_tbwrri
    - new systems
      - rtl/sys_gen/tst_rlink       - rlink tester
        - arty/sys_tst_rlink_arty     - for Arty
      - rtl/sys_gen/w11a            - w11a
        - arty_bram/sys_w11a_br_arty  - for Arty (BRAM only, 176 MByte)

  - Changes
    - */.cvsignore                  - all ignore files re-organized
    - */tb/Makefile                 - Vivado now default, keep Makefile.ise
    - rtl/bplib/*/tb/tb_*.vhd       - use s7_cmt_sfs_tb and serport_master_tb
    - rtl/vlib/comlib
      - comlib.vhd                  - add work-around for vivado 2015.4 issue
    - rtl/vlib/rbus
      - rb_sres_or_mon              - supports 6 inputs now
    - rtl/vlib/serport
      - serport_master              - moved to tb, _tb appended to name
    - rtl/vlib/rlink/tbcore
      - tbcore_rlink                - re-structured to use rlink_cext_iface
    - rtl/sys_gen/...
      - sys_tst_rlink_b3            - hardwire XON=1, support XADC
      - sys_tst_rlink_n4            - support XADC and RGBLEDs
      - sys_w11a_b3                 - hardwire XON=1, support XADC; 72 MHz now
      - sys_w11a_n4                 - support XADC
    - tools/bin
      - tbrun_tbw                   - add vivado xsim and Makefile.ise support
      - tbrun_tbwrri                - use --sxon and --hxon instead of --xon
      - tbw                         - add XSim support
      - ti_w11                      - add arty support, add -fx
      - vbomconv                    - add [ise,viv]; add @uut tag handling;
                                      add preliminary --(vsyn|vsim)_export;
                                      add vivado xsim support;
      - xtwi,xtwv                   - add BARE_PATH to provide clean environment

  - Bug fixes
    - tools/tcl/rutil
      - regdsc.tcl                  - regdsc: fix variable name in error msg

  - Known issues
    - all issues: see README_known_issues.txt
    - resolved issues:
      - V0.64-4: support added for Vivado xsim. See however issue V0.72-1+2.
      - V0.64-5: w11a_tb_guide.txt covers xsim tests too.

    - new issues:
      - V0.72-1: Vivado 2015.4 xelab crashes when DPI is used in a mxied
          vhdl-verilog language environment. This prevents currently to
          build a xsim simulation model for rlink based test benches.
      - V0.72-2: xsim simulations with timing annotation not yet available.

- trunk (2015-12-30: svn rev 34(oc) 722(wfjm); untagged w11a_V0.71)  +++++++++
  - Preface
    - the w11a so far lacked any 'hardware debugger' support, which made the
      debugging of CPU core issues a bit tedious. This release added a first
      implementation of CPU debugger and monitoring features
      - dmhbpt: hardware break point unit. Allows to set multiple break points
                on instruction fetches (thus code break points) and on data
                reads/writes (thus data access break points). The number of
                breakpoints is configurable between 0 and 4, in current
                designs 2 are available
      - dmcmon: CPU state monitor. A buffer of configurable size which holds
                a wide range of information on execution of the most recent
                instructions. Tracing can be a instruction as well as on
                micro cycle level.
      - dmscnt: micro state counter. A counter array which allows to monitor
                in which micro state the CPU time is spend, separated for
                kernel and supervisor/user mode.
      These three units together with the already existing ibus monitor allow
      a very detailed and specific monitoring and debugging of the CPU.

      The w11a CPU core is not functionally modified in this release, the only
      exception is the suspend logic needed to implement hardware break points.
      Both the hardware break point and the instruction level tracing in dmcmon 
      require a clean definition of instruction boundaries, which the current 
      w11a core does not provide in some cases. This leads to imprecise 
      breakpoints (CPU executes one additional instruction) and incomplete 
      dmcmon traces (at instruction level when exceptions are taken). 
     
      The w11a core will be modified in the next release to handle the above
      mentioned conditions properly. The dmhbpt and dmcmon will be fully
      documented when the w11a core changes are done, they work as expected
      under all conditions, and the full back end integration is completed.

    - bottom line is that this release has little added value for normal w11
      usage. It is technically necessary to separate the addition of all
      the debug units and modification of the CPU core into two releases.

  - Summary
    - new reference system
      - switched to Vivado 2015.4 (from 2014.4)
        Note: 2015.4 has WebPACK support for Logic Analyser and HLS. Both are
              not used so far, but the logic analyser may come in handy soon.
      - switched to tcl8.6 (from tcl8.5)
        Note: tcl8.6 is default tcl in Ubuntu 2014.04LTS, but up to now the
              tclshcpp helper was linked against tcl8.5. So far no tcl8.6
              langauge features are used, but may be in future.

  - New features
    - new modules
      - rtl/w11a
        - pdp11_dmcmon              - pdp11: debug&moni: cpu monitor
        - pdp11_dmhbpt              - pdp11: debug&moni: hardware breakpoint
        - pdp11_dmhbpt_unit         - pdp11: dmhbpt - individual unit
        - pdp11_dmscnt              - pdp11: debug&moni: state counter
    - new files
      - tools/bin
        - dmscntanal                - analyze dmscnt data
        - dmscntconv                - convert dmscnt data
      - tools/asm-11/lib
        - defs_mmu.mac              - definitions for mmu registers
        - defs_nzvc.mac             - definitions for condition code combos
        - defs_reg70.mac            - definitions for 11/70 CPU registers
        - tcode_std_base.mac        - Default tcode base code for simple tests
        - tcode_std_start.mac       - Default tcode startup code
        - vec_devcatch.mac          - vector catcher for device interrupts
        - vec_devcatch_reset.mac    - re-write vector catcher
      - tools/tbench
        - w11a_cmon                 - directory with dmcmon tests
        - w11a_hbpt                 - directory with dmhbpt tests
      - tools/tcl
        - ibd_(dl|lp|pc|rk|rl)11    - directory with register regdsc's
      - tools/tcl/rutil
        - fileio.tcl                - new tofile and fromfile procs
      - tools/tcl/rw11
        - dmcmon.tcl                - support code for dmcmon
        - dmhbpt.tcl                - support code for dmhbpt
        - dmscnt.tcl                - support code for dmscnt
        - shell.tcl                 - new w11a tcl shell
        - shell_egd.tcl             - code for e,g,d commands
      - tools/tcl/rw11util
        - regmap.tcl                - support for 'map of regdsc' definitions

  - Changes
    - rtl/vlib/rlink
      - rlink_core.vhd              - add proc_sres: strip 'x' from RB_SRES.dout
    - rtl/vlib/rlink/tb
      - tbcore_rlink                - drive SB_CNTL from start to avoid 'U'
    - rtl/w11a
      - pdp11                       - add defs for pdp11_dm(scnt|hbpt|cmon)
      - pdp11_*                     - add support for pdp11_dm(scnt|hbpt|cmon)
    - rtl/sys_gen/w11a/*
      - sys_conf                    - add sys_conf_(dmscnt|dmhbpt*|dmcmon*)
    - rtl/sys_gen/w11a/*/tb
      - sys_conf_sim                - add sys_conf_(dmscnt|dmhbpt*|dmcmon*)
    - tools/bin/
      - ti_w11                      - add -ghw option
      - tmuconv                     - fix '.' handling for br/sob instructions
                                      correct xor (now r,dst, and not src,r)
    - tools/tcl/rutil
      - regdsc.tcl                  - add regbldkv,reggetkv
      - util.tcl                    - rename optlist2arr->args2opts, new logic
    - tools/tcl/rw11
      - asm.tcl                     - new arg list format in asm(run|treg|tmem)
      - dasm.tcl                    - add dasm_inst2txt
    - tools/tcl/ibd_ibmon
      - util.tcl                    - add symbolic register dump

  - Bug fixes
    - rtl/bplib/micron
      - mt45w8mw16b                 - fix issue when 1st access is to addr 0
    - rtl/bplib/nxcramlib
      - nx_cram_memctl_as           - always define imem_oe in do_dispatch()
    - rtl/ibus
      - ibdr_tm11                   - add missing BESET to sensitivity list
    - rtl/w11a
      - pdp11_sequencer             - proper trap_mmu and trap_ysv handling
    - tools/bin
      - asm-11                      - fix '.' handling in instructions

  - Known issues
    - all issues: see README_known_issues.txt

- w11a_V0.7 (2015-06-21) +++++++++++++++++++++++++++++++++++++++++++++++++++++
  cummulative summary of key changes from w11a_V0.6 to w11a_V0.7
  - Bugfix for DIV instruction  (in w11a_V0.61, see ECO-026-div.txt)
  - revised rbus protocol V4    (in w11a_V0.62, see README_Rlink_V4.txt)
  - add basic Vivado support    (in w11a_V0.64)
  - add Nexys4 and Basys3 port of w11a (in w11a_V0.64)
  - add RL11/RL02  disk support (in w11a_V0.64)
  - add RH70+RP/RM disk support (in w11a_V0.65)
  - add TM11/TY10 tape support  (in w11a_V0.66)
  - reference system now ISE 14.7, Vivado 2014.4; Ubuntu 14.04 64 bit, ghdl 0.31

  for details see README-w11a_V.60-w11a_V0.70.txt

- w11a_V0.6 (2014-06-06) +++++++++++++++++++++++++++++++++++++++++++++++++++++

  cummulative summary of key changes from w11a_V0.5 to w11a_V0.6
  - revised ibus protocol V2  (in w11a_V0.51)
  - revised rbus protocol V3  (in w11a_V0.52)
  - backend server rewritten in C++ and Tcl (in w11a_V0.53 and w11a_V0.562)
  - add Nexys3 port of w11a (in w11a_V0.54)
  - add Cypress FX2 support (in w11a_V0.56 and w11a_V0.57)
  - added LP11,PC11 support (in w11a_V0.58)
  - reference system now ISE 14.7 and Ubuntu 12.04 64 bit, ghdl 0.31
  - many code cleanups; use numeric_std
  - many documentation improvements
  - development status upgraded to beta (from alpha)

  for details see README-w11a_V.50-w11a_V0.60.txt

- w11a_V0.5 (2010-07-23) +++++++++++++++++++++++++++++++++++++++++++++++++++++

  Initial release with 
  - w11a CPU core
  - basic set of peripherals: kw11l, dl11, lp11, pc11, rk11/rk05
  - just for fun: iist (not fully implemented and tested yet)
  - two complete system configurations with 
    - for a Digilent S3board    rtl/sys_gen/w11a/s3board/sys_w11a_s3
    - for a Digilent Nexys2     rtl/sys_gen/w11a/nexys2/sys_w11a_n2
