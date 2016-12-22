# Changelog: w11a_V0.70 -> w11a_V0.74

### Table of contents
- Release [w11a_V0.74](#user-content-w11a_V0.74)
- Release [w11a_V0.73](#user-content-w11a_V0.73)
- Release [w11a_V0.72](#user-content-w11a_V0.72)
- Release [w11a_V0.71](#user-content-w11a_V0.71)
- [CHANGELOG for w11a_V.60 to w11a_V0.70.md](CHANGELOG-w11a_V.60-w11a_V0.70.md)
- [CHANGELOG for w11a_V.50 to w11a_V0.60.md](CHANGELOG-w11a_V.50-w11a_V0.60.md)

<!-- --------------------------------------------------------------------- -->
---
## 2016-10-02: w11a_V0.74 - svn rev 37(oc) 811(wfjm) <a name="w11a_V0.74"></a>
### Preface
- the current version of the  memory controller for the micron `mt45w8mw16b`
  'cellular ram' used on nexys2, nexys3, and nexys4 uses the asynchronous
  access mode. The device supports a 'page mode' to speed up read access to
  subsequent addresses. Even though prepared in the controller logic this
  feature was simply forgotten. This is now properly implemented and 
  results in a bit faster cache line load times. The overall performance
  of a w11a design is measurably, but marginally better.
- many unit tests still used a ISE environment. All board independent
  tests were converted now to a vivado environment, only tests which
  really depend a FPGA not supported by vivado stay with ISE.
- a total of 82 unit or system tests are currently available. Many of them
  can be executed by different simulation engines, ghdl or the ISE/vivado 
  build-in simulators, and for different stages of the implementation flow, 
  from initial behavioral simulation over post-synthesis functional to final 
  post-routing timing simulation. This results in a large number of possible
  tests. All test benches are all self-checking, but the execution of them
  was so far not sufficiently automatized.
  This was addressed with `tbrun`, a test bench driver, which obtains a
  list of all available test benches from configuration files, selects
  a subset given by selection criteria, and executes them. It can handle
  the parallel execution of tests so multi-core systems can be very
  easily exploited. Running all tests is now a single shell command.
- a new tool 'tbfilt' simplifies the logic of self-checking test benches
  and can also be used as a tool to analyze the full log files produced
  by the test benches
- several test benches have been added to this release, most notably the
  memory tester sys_tst_sram_* which was originally developed to verify
  the s3board SRAM controller and later ported to verify the nexys* CRAM
  controller.
- the system test benches with SRAM and CRAM now include the PCB trace
  delay between FPGA and memory chip. The new entity `simbididly` models a
  bi-directional bus delay.
- so far test benches ended by stopping the clock, all processes were 
  written such that they enter a permanent wait, which causes the simulation
  to stop. Worked for fine behavioral simulations, but fails when Xilinx 
  MMCMs are involved in post-synthesis simulations. The UNISIM models 
  apparently have timed waits. The test benches were modified to stop via a
  report with severity failure, the test environment detects this specific
  assertion/report failure and accepts it as successful termination of
  the simulation.
- the configuration of the board switches in system test benches was done
  in a sub-optimal way which could lead to startup problems. tbrun_tbwrri
  uses now a different mechanism which ensures that all board and test
  bench configuration is done in the first ns of the simulation and has
  thus completed well before all other activities.
- finally a caveat: post-synthesis simulations work fine with ISE, but
  currently not with vivado, even in case of almost identical designs,
  like `sys_tst_rlink_n3` vs `sys_tst_rlink_n4`. Is under investigation.

### Summary
- upgraded CRAM controller, now with 'page mode' support
- new test bench driver tbrun, give automatized test bench execution

### New features

    - new modules
      - rtl/bplib/issi/tb/*         - added unit test for is61lv25616al model
      - rtl/bplib/micron/tb/*       - added unit test for mt45w8mw16b model
      - rtl/sys_gen/tst_serloop     - add serloop2 (2 clock) designs for n3,n4
        - nexys3/sys_tst_serloop2_n3.vhd
        - nexys4/sys_tst_serloop2_n4.vhd
      - rtl/sys_gen/tst_sram        - add sram test design for
        - nexys2/*
        - nexys3/*
        - nexys4/*
        - s3board/*
      - rtl/vlib/genlib/tb
        - clkdivce_tb.vhd             - copy for tb usage of clkdivce
      - rtl/vlib/rlink/tb
        - rlink_tba.vhd               - rlink test bench adapter
        - tb_rlink_tba.vhd            - test bench for rbus devices
        - tbd_tba_ttcombo.vhd         - tba tester for ttcombo
      - rtl/vlib/simlib
        - simbididly.vhd              - bi-di bus delay model
      - rtl/vlib/xlib
        - gsr_pulse.vhd               - pulse GSR at startup
        - gsr_pulse_dummy.vhd         - no-action dummy (for bsim models)
      - rtl/w11a/tb
        - tb_rlink_tba_pdp11core.vhd  - tba tester for w11a

    - new files
      - doc/man/man1                - added tbrun,tbfilt man pages
      - */tbrun.yml                 - test bench descriptors for tbrun
      - rtl/sys_gen/w11a/tb
        - tb_w11a_mem70*.dat          - stim files for additional tests
      - rtl/w11a/tb
        - tb_pdp11core_ubmap.dat      - stim files for additional test
      - tools/bin
        - njobihtm                    - determine #jobs
        - tbfilt                      - test bench output filter
        - tbrun                       - test bench driver
        - ticonv_rri                  - converts old 'mode rri' for ti_rri
       - tools/tcl/tst_sram/*.tcl     - support for sys_tst_sram

### Changes

    - rtl/bplib
      - arty/tb/tb_arty.vhd           - add gsr_pulse (provisional....)
      - */tb/tb_*.vhd                 - tbcore_rlink without CLK_STOP now
      - fx2lib/tb/fx2_2fifo_core.vhd  - proc_ifclk: remove clock stop
      - nexys2/tb/tb_nexys2_core.vhd  - use simbididly
      - nexys3/tb/tb_nexys3_core.vhd  - use simbididly
      - nexys4/tb/tb_nexys4_cram.vhd  - use simbididly
      - nxcramlib
        - nx_cram_memctl_as.vhd       - add page mode support
        - nxcramlib.vhd               - add cram_*delay functions
      - s3board
        - s3_sram_memctl.vhd          - drop "KEEP" for data (better for dbg)
        - tb/tb_s3board_core.vhd      - use simbididly
    - rtl/make_ise
      - generic_ghdl.mk               - ghdl_clean: remove also gcov files
    - rtl/make_viv
      - generic_ghdl.mk               - ghdl_clean: remove also gcov files
      - generic_vivado.mk             - viv_clean: rm only vivado logs
      - generic_xsim.mk               - xsim work dir now xsim.<mode>.<stem>
    - rtl/sys_gen/tst_serloop
      - */tb/tb_tst_serloop*.vhd      - remove CLK_STOP logic
      - tb/tb_tst_serloop.vhd         - remove CLK_STOP logic
    - rtl/sys_gen/w11a/nexys*
      - sys_conf.vhd                  - use cram_*delay functions 
    - rtl/vlib/rlink
      - rlink_core.vhd                - remove 'assert false' from report stmts
      - tb/tb_rlink.vhd               - use clkdivce_tb
      - tbcore/tbcore_rlink.vhd       - conf: add .wait, CONF_DONE; drop CLK_STOP
    - rtl/vlib/simlib                 
      - simbus.vhd                    - rename SB_CLKSTOP > SB_SIMSTOP
      - simclk.vhd                    - CLK_STOP now optional port
    - rtl/vlib/xlib
      - */s*_cmt_sfs_*.vhd            - remove 'assert false' from report stmts
    - tools/bin
      - tbrun_tbwrri                  - add --r(l|b)mon,(b|s)wait; configure
                                        now via _conf={...}
      - tbw                           - use {} as delimiter for immediate mode
      - vbomconv                      - add VBOMCONV_GHDL_OPTS and .._GHDL_GCOV
      - xise_ghdl_*                   - add ghdlopts as 1st option; def is -O2

    - removed files
      - tools/bin/ghdl_assert_filter  - obsolete (use tbfilt now)
    - renames
      - rtl/make_viv/viv_*.tcl -> tools/vivado - separate make and tools

### Bug fixes

    - tools/bin
      - tbw                         - xsim: append -R to ARGV (was prepended...)
      - xtwi                        - add ":." to PATH even under BARE_PATH

### Known issues
- all issues: see README_known_issues.txt
- no resolved or new issues in this release

<!-- --------------------------------------------------------------------- -->
---
## 2016-06-26: w11a_V0.73 - svn rev 36(oc) 779(wfjm) <a name="w11a_V0.73"></a>
### Preface
- the 'basic vivado support' added with V0.64 was a minimal effort port of
  the code base used under ISE, leading to sub-optimal results under vivado.
  - the FSM inference under vivado is quirky and has several issues. The
    most essential one prevented re-coding with 'one_hot' encoding, which
    lead to high logic depth and low clock rates. Proper work-arounds were
    applied to almost all FSMs, now vivado infers all (but one) properly
    and re-codes them as 'one_hot'. That is especially important for the
    pdp11_sequencer, which has 113 states. The sys_w11a_n4 system can now
    run with up to 90 MHz (was 75-80 MHz before).
  - due to a remaining synthesis issue the dmscnt and dmcmon debug units
    are currently disabled for Artix based systems (see issue V0.73-3).
  - memory inference is now used for all distributed and block rams under
    vivado. The memory generators in memlib are still used under ISE
    Note: they were initially setup to work around ISE synthesis issues.
  - vivado synthesis and implementation use now 'explore' type flows for
    optimal timing performance.
  - the two clock dram based fifo was re-written (as `fifo_2c_dram2`) to allow
    proper usage of vivado constraints (e.g. scoped xdc).
- vivado is now the prime platform for all further development
  - the component test benches run now by default under Vivado with an
    Artix-7 as default target. The makefiles for ISE with a Spartan-6 target
    are available as `Makefile.ise` and via the `makeise` command.
  - a message filter (`xviv_msg_filter`) has been developed which lists only
    the unexpected message of a synthesis or implementation run. Filter
    rule sets (`.vmfset` files) are available for all designs.
  - full support for the vivado simuator `xsim` has been added, there are
    make targets to build a behavioral simulation as well as post-synthesis,
    post-optimize, and post-routing functional and timing models. All these
    models are now created in separate sub-directories and can now co-exist.
    However see issues V0.73-1 and V0.73-2 for severe caveats on xsim.
  - vivado write_vhdl generates code which violates a vhdl language rule. 
    Attributes of port signals are declared in the wrong place. xsim and 
    other simulators accept this, but ghdl doesn't. As a work-around the
    generated code is cleaned up by a filter (see xviv_sim_vhdl_cleanup).  
- additional rlink devices
  - the XADC block, available on all 7Series FPGAs, is now accessible via
    rlink on all Arty, Basys3 and Nexys4 designs. Especially useful on the
    Arty board because on this board also the currents are monitored.
  - the USR_ACCESS register, available on all 7Series FPGAs, is now readable
    via rlink on all Arty, Basys3 and Nexys4 designs. The vivado build flow
    initializes this register with the build timestamp. This allows to
    verify the build time of a design at run time.
- the cache used by the w11a (`pdp11_cache`) was initialy developed with the
  tight block ram resources of the early Spartan-3 systems in mind. It had
  8 kByte and used 5 BRAMs of size 18 kBit. With very little changes the 
  implenenation is now parametrized, and can generate also 16,32, 64 and 
  even 128 kByte caches which also use the 36 kBit BRAMs on the Artix.
  There is a trade-off between cache sizes and clock rate due to routing
  delays to the BRAM blocks. The w11a on the nexys4 runs with 16 kByte
  cache and 90 MHz clock or with 64 kByte cache and 80 MHz. For practical
  work loads, like a kernel compile, the 64 kByte configuration is better
  and thus the default.
- resolved known issue V0.64-7: was caused by a combination of issues
  and is now resolved by a combination of measures: add portsel logic for 
  arty tb, proper portsel setup, configurable timeout, and finally proper 
  timeout setting.
- resolved known issue V0.64-3: So far the arty, basys3 and nexys4 serial 
  port, based on a FTDI FT2232, was often operated at 10 MBaud. This rate 
  is in fact not supported by FTDI, the chip will use 8 instead of 10 MBaud.
  Due to auto-bauding, which simly adapts to the actual baud rate, this went
  undetected for some time. Now all designs use a serport block clocked with
  120 MHz and can be operated with 12 MBaud. 

### Summary
- new reference system: switched to Vivado 2016.2 (from 2015.4)
- code base cleaned-up for vivado, fsm now inferred
- xsim support complete (but many issues to be resolved yet)
- added configurable w11a cache
- removed some never documented and now strategically obsolete designs:
  - sys_tst_fx2loop (for nexys2 and nexys3)
  - sys_tst_rlink_cuff_ic3 (a three channel variant of the fx2 interface)

### New features

    - new modules
      - rtl/vlib
        - generic_clk_100mhz.xdc    - generic 100 MHz on CLK constraint (for tbs)
      - rtl/vlib/cdclib             - new directory for clock domain crossing
        - cdc_pulse.vhd               - cdc for a pulse (moved in from genlib)
        - cdc_signal_s1.vhd           - cdc for a signal, 2 stage
        - cdc_vector_s0.vhd           - cdc for a vector, 1 stage
      - rtl/vlib/memlib
        - fifo_2c_dram2.vhd             - re-write of fifo_2c_dram to allow
                                          proper usage of vivado constraints
      - rtl/vlib/rbus
        - rb_sres_or_6.vhd              - rbus result or, 6 input
        - rbd_usracc.vhd                - return usr_access register
      - rtl/vlib/rlink
        - rlink_sp2c.vhd                - rlink_core8 + serport_2clock2 combo
      - rtl/vlib/serport
        - serport_2clock2.vhd           - like serport_2clock, use fifo_2c_dram2
      - rtl/vlib/xlib
        - usr_access_unisim.vhd         - Wrapper for USR_ACCESS* entities
    - new files
      - tools/bin
        - xise_msg_summary            - list all filtered ISE messages
        - xviv_msg_filter             - message filter for vivado
        - xviv_msg_summary            - list all filtered vivado messages
        - xviv_sim_vhdl_cleanup       - cleanup vivado generated vhdl for ghdl
        - makeise                     - wrapper for make -f Makefile.ise
      - tools/tcl/rbtest
        - test_flow.tcl               - test back pressure and flow control

### Changes

    - rtl/bplib/*/*_pins.xdc        - add BITSTREAM.CONFIG.USR_ACCESS setup
    - rtl/bplib/*/tb/tb_*.vbom      - use -UUT attribute
    - rtl/sys_gen/*/*/tb/tb_*.vbom  - use -UUT attribute
    - rtl/make_ise
      - generic_ghdl.mk               - use ghdl.?sim as workdir for ghdl
      - generic_xflow.mk              - use .imfset for ISE message rules
    - rtl/make_viv
      - generic_ghdl.mk               - use ghdl.?sim as workdir for ghdl
      - generic_vivado.mk             - add [sorep]sim.v and %.vivado targets
                                      - vmfset support, use xviv_sim_vhdl_cleanup
      - generic_xsim.mk               - [rep]sim models; use xsim.?sim as workdir
      - viv_tools_build.tcl           - use explore flows;  prj,opt,pla modes
      - viv_tools_config.tcl          - add USR_ACCESS readback
      - viv_tools_model.tcl           - add [sor]sim_vhdl [sorepd]sim_veri modes
    - rtl/sys_gen/*/*                 (all rlink based designs)
      - sys_*.vhd                     - define rlink SYSID
    - rtl/sys_gen/*/*                 (all rlink and 7series based designs)
      - sys_*.vhd                     - add rbd_usracc, use serport_2clock2
      - sys_conf.vhd                  - use PLL for clkser_gentype
    - rtl/sys_gen/w11a/*
      - sys_conf.vhd                  - add sys_conf_cache_twidth
    - rtl/sys_gen/tst_serloop/nexys4
      - sys_tst_serloop1_n4.vhd       - clock now from cmt and configurable
    - rtl/sys_gen/tst_serloop/tb
      - tb_tst_serloop.vhd            - use serport_(uart_rxtx|xontx)_tb
    - rtl/vlib/*/tb/tb_*.vbom       - use -UUT attribute
    - rtl/vlib/*/tb/tbd_*.vbom      - use generic_clk_100mhz.xdc
    - rtl/vlib/comlib/comlib.vhd    - leave return type unconstraint
    - rtl/vlib/simlib/simlib.vhd    - add writetimens()
    - rtl/w11a
      - pdp11_bram_memctl.vhd         - use memory inference now
      - pdp11_cache.vhd               - now configurable size (8,16,32,64,128 kB)
      - pdp11_sequencer.vhd           - proc_snum conditional (vivado fsm fix)
    - rtl/*/*.vbom                  - use memory inference for vivado
    - rtl/*/*.vhd                   - workarounds and fixes to many FSMs
    - tools/bin
      - tbrun_tbw                     - use _bsim.log for behavioral sim log
      - tbrun_tbwrri                  - use _bsim.log for behavioral sim log
                                        use 120 sec timeout for simulation
      - tbw                           - add '-norun', -run now default
      - ti_rri                        - add --tout option
                                        use 120 sec timeout for simulation
      - vbomconv                      - add file properties (-UUT,-SCOPE_REF)
                                        full xsim support now in -vsim_prj
      - tools/src/librlink
        - RlinkConnect                - add USR_ACCESS register support
      - tools/src/librlinktpp
        - RtclRlinkConnect            - add USR_ACCESS, timeout access
      - tools/tcl/rbtest
        - test_data.tcl               - add dinc register tests
      - tools/tcl/rlink
        - util.tcl                    - add USR_ACCESS register support

    - removed designs
      - rtl/sys_gen/tst_fx2loop/nexys*/*/sys_tst_fx2loop_*_n*
      - rtl/sys_gen/tst_rlink_cuff/nexys2/ic3/sys_tst_rlink_cuff_ic3_n2
    - renames
      - *.mfset -> *.imfset         - to be complementary to new .vmfset
      - Makefile -> Makefile.ise    - old ISE makefiles in component areas

### Bug fixes

    - rtl/bplib/arty/tb
      - tb_arty.vhd:                - add portsel logic
    - rtl/bplib/sysmon
      - sysmon_rbus_core.vhd        - use s_init (and not s_idle) after RESET
    - rtl/vlib/xlib
      - s7_cmt_sfs_*.vhd            - correct mmcm range check boundaries
    - tools/bin
      - ti_w11:                     - proper portsel oob for -fx
      - tbrun_tbwrri:               - proper portsel oob for -hxon

### Known issues
- all issues: see README_known_issues.txt
- resolved issues:
  - **V0.72-1**: since vivado 2016.1 xelab builds models which use DPI in a
      mixed vhdl-verilog language environment.
  - **V0.72-2**: now full support to build behavioral as well as functional and
      timing simulations with xsim. See V.073-1 and 0.73-2 for caveats.
  - **V0.64-7**: flow control issues with simulation models resolved
  - **V0.64-3**: basys3, nexys4 and arty designs support now 12 MBaud.
- new issues:
  - **V0.73-1**: as of vivado 2016.2 `xelab` shows sometimes extremely long
    build times, especially for generated post-synthesis vhdl models. But also 
    building a behavioral simulation for a w11a design can take 25 min.
    Even though post-synthesis or post-routing models are now generated
    in verilog working with xsim is cumbersome and time consuming.
  - **V0.73-2**: Many post-synthesis functional and especially post-routing
    timing simulations currently fail due to startup and initialization
    problems. Cause is MMCM/PLL startup, which is not properly reflected
    in the test bench. Will be resolved in an upcoming release.
  - **V0.73-3**: The 'state number generator' code in `pdp11_sequencer` causes
    in vivado 2016.1 (and .2) that the main FSM isn't re-coded anymore, which
    has high impact on achievable clock rate. The two optional debug units
    depending on the state number, `dmscnt` and `dmcmon`, are therefore
    currently deactivated in all Artix based systems (but are available on
    all Spartan based systems).

<!-- --------------------------------------------------------------------- -->
---
## 2016-03-19: w11a_V0.72 - svn rev 35(oc) 746(wfjm) <a name="w11a_V0.72"></a>
### Preface
- The new low-cost Digilent Arty board is a very attractive platform.
  The DDR3 memory will take some time to integrate, in this release thus
  only designs using the BRAMs.
- added support for the Vivado simulator. Simple test benches work fine.
  Rlink based test benches don't work due to a bug in Vivado 2015.4.
- A rather esoteric CPU bug was fixed in release V0.71 but forgotten to
  mention in the README. See [ECO-027-trap_mmu.md](ECO-027-trap_mmu.md) 
  for details.

### Summary
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

### New features

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

    - new files
      - doc/man/man1
        - tbrun_tbw.1               - man file for tbrun_tbw
        - tbrun_tbwrri.1            - man file for tbrun_tbwrri
    - new systems
      - rtl/sys_gen/tst_rlink       - rlink tester
        - arty/sys_tst_rlink_arty     - for Arty
      - rtl/sys_gen/w11a            - w11a
        - arty_bram/sys_w11a_br_arty  - for Arty (BRAM only, 176 MByte)

### Changes

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

### Bug fixes

    - tools/tcl/rutil
      - regdsc.tcl                  - regdsc: fix variable name in error msg

### Known issues
- all issues: see README_known_issues.txt
- resolved issues:
  - **V0.64-4**: support added for Vivado xsim. See however issue V0.72-1+2.
  - **V0.64-5**: w11a_tb_guide.txt covers xsim tests too.

- new issues:
  - **V0.72-1**: Vivado 2015.4 xelab crashes when DPI is used in a mxied
    vhdl-verilog language environment. This prevents currently to
    build a xsim simulation model for rlink based test benches.
  - **V0.72-2**: xsim simulations with timing annotation not yet available.

<!-- --------------------------------------------------------------------- -->
---
## 2015-12-30: w11a_V0.71 - svn rev 34(oc) 722(wfjm) <a name="w11a_V0.71"></a>
### Preface
- the w11a so far lacked any 'hardware debugger' support, which made the
  debugging of CPU core issues a bit tedious. This release added a first
  implementation of CPU debugger and monitoring features
  - `dmhbpt`: hardware break point unit. Allows to set multiple break points
    on instruction fetches (thus code break points) and on data
    reads/writes (thus data access break points). The number of
    breakpoints is configurable between 0 and 4, in current
    designs 2 are available
  - `dmcmon`: CPU state monitor. A buffer of configurable size which holds
    a wide range of information on execution of the most recent
    instructions. Tracing can be a instruction as well as on
    micro cycle level.
  - `dmscnt`: micro state counter. A counter array which allows to monitor
    in which micro state the CPU time is spend, separated for
    kernel and supervisor/user mode.
- These three units together with the already existing ibus monitor allow
  a very detailed and specific monitoring and debugging of the CPU.
- The w11a CPU core is not functionally modified in this release, the only
  exception is the suspend logic needed to implement hardware break points.
  Both the hardware break point and the instruction level tracing in dmcmon 
  require a clean definition of instruction boundaries, which the current 
  w11a core does not provide in some cases. This leads to imprecise 
  breakpoints (CPU executes one additional instruction) and incomplete 
  `dmcmon` traces (at instruction level when exceptions are taken). 
- The w11a core will be modified in the next release to handle the above
  mentioned conditions properly. The dmhbpt and dmcmon will be fully
  documented when the w11a core changes are done, they work as expected
  under all conditions, and the full back end integration is completed.
- bottom line is that this release has little added value for normal w11
  usage. It is technically necessary to separate the addition of all
  the debug units and modification of the CPU core into two releases.

### Summary
- new reference system
  - switched to Vivado 2015.4 (from 2014.4)
    Note: 2015.4 has WebPACK support for Logic Analyser and HLS. Both are
    not used so far, but the logic analyser may come in handy soon.
  - switched to tcl8.6 (from tcl8.5)
    Note: tcl8.6 is default tcl in Ubuntu 2014.04LTS, but up to now the
    tclshcpp helper was linked against tcl8.5. So far no tcl8.6
    langauge features are used, but may be in future.

### New features

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

### Changes

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

### Bug fixes

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

### Known issues
- all issues: see README_known_issues.txt
