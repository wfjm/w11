$Id: README.txt 614 2014-12-20 15:00:45Z mueller $

Release notes for w11a

  Table of content:
  
  1. Documentation
  2. Change Log

1. Documentation -------------------------------------------------------------

  More detailed information on installation, build and test can be found 
  in the doc directory, specifically

    * README.txt: release notes
    * INSTALL.txt: installation and building test benches and systems
    * FILES.txt: short description of the directory layout, what is where ?
    * w11a_tb_guide.txt: running test benches
    * w11a_os_guide.txt: booting operating systems 
    * w11a_known_issues.txt: known differences, limitations and issues

2. Change Log ----------------------------------------------------------------

- trunk (2015-01-04: svn rev 28(oc) 629(wfjm); untagged w11a_V0.63)  +++++++++

  - Summary
    - the w11a rbus interface used so far a narrow dynamically adjusted 
      rbus->ibus window. Replaces with a 4k word window for whole IO page.
    - utilize rlink protocol version 4 features in w11a backend
      - use attn notifies to dispatch attn handlers
      - use larger blocks (7*512 rather 1*512 bytes) for rdma transfers
      - use labo and merge csr updates with last block transfer
      - this combined reduces the number of round trips by a factor 2 to 3, 
        and in some cases the throughput accordingly.

  - Remarks on reference system
    - still using tcl 8.5 (even though 8.6 is now default in Ub 14.04)
    - don't use doxygen 1.8.8 and 1.8.9, it fails to generate vhdl docs

  - New features
    - new modules
      - tools/bin
        - ghdl_assert_filter      - filter to suppress startup warnings
        - tbrun_tbw               - wrapper for tbw based test benches
        - tbrun_tbwrri            - wrapper for ti_rri + tbw based test benches
      - tools/src/librw11
        - Rw11Rdma                - Rdma engine base class
        - Rw11RdmaDisk            - Rdma engine for disk emulation

  - Changes
    - rtl/vlib/rlink
      - rlink_core                - use 4th stat bit to signal rbus timeout
    - rtl/vlib/rbus
      - rbd_rbmon                 - reorganized, supports now 16 bit addresses
    - rtl/w11a
      - pdp11_core_rbus           - use full size 4k word ibus window
    - tools/bin/tbw               - add -fifo and -verbose options
    - tools/src/librtools
      - Rexception                - add ctor from RerrMsg
    - tools/src/librlink
      - RlinkCommandExpect        - rblk/wblk done counts now expectable
      - RlinkConnect              - cleanups and minor enhancements
      - RlinkServer               - use attn notifies to dispatch handlers
    - tools/src/librw11
      - Rw11CntlRK11              - re-organize, use now Rw11RdmaDisk
      - Rw11Cpu                   - add ibus address map
    - tools/src/librwxxtpp
      - RtclRw11CntlRK11          - add get/set for ChunkSize
      - RtclRw11Cpu               - add amap sub-command for ibus map access

  - Resolved known issues from V0.62
    - the rbus monitor (rbd_rbmon) has been updated to handle 16 bit addresses

  - Known issues
    - (V0.62): rlink v4 error recovery not yet implemented, will crash on error
    - (V0.62): command lists aren't split to fit in retransmit buffer size
      {both issues not relevant for w11 backend over USB usage because the
       backend produces proper command lists and the USB channel is error free}

- trunk (2014-12-20: svn rev 27(oc) 614(wfjm); untagged w11a_V0.62)  +++++++++

  - Summary
    - migrate to rlink protocol version 4
      - Goals for rlink v4
        - 16 bit addresses (instead of 8 bit)
        - more robust encoding, support for error recovery at transport level
        - add features to reduce round trips
          - improved attention handling
          - new 'list abort' command
      - For further details see README_Rlink_V4.txt
    - use own C++ based tcl shell tclshcpp instead of tclsh

    Notes:
      1. rlink protocol, core, and backend are updated in this release
      2. error recovery in backend not yet implemented
      3. the designs using rlink are still essentially unchanged
      4. the new rlink v4 features will be exploited in upcoming releases

  - New reference system
    The development and test system was upgraded from Kubuntu 12.04 to 14.04.
    The version of several key tools and libraries changed:
       linux kernel    3.13.0   (was  3.2.0) 
       gcc/g++         4.8.2    (was  4.6.3)
       boost           1.54     (was  1.46.1)
       libusb          1.0.17   (was  1.0.9)
       perl            5.18.2   (was  5.14.2)
       tcl             8.5.15   (was  8.5.11)
       sdcc            3.3.0    (was  2.9.0)
       doxygen         1.8.7    {installed from sources; Ub 14.04 has 1.8.6}

    Notes:
      1. still using tcl 8.5 (even though 8.6 is now default in Ub 14.04)
      2. sdcc 3.x is not source compatible with sdcc 2.9. The Makefile
         allows to use both, see tools/fx2/src/README.txt .
      3. don't use doxygen 1.8.8, it fails to generate vhdl docs

  - New features
    - new environment variables TCLLIB and TCLLIBNAME. TCLLIBNAME must be
      defined, and hold the library name matching the Tcl version already
      specified with TCLINC.
    - new modules
      - rtl/vlib/comlib/crc16     - 16 bit crc generator (replaces crc8)
      - tools/src/tclshcpp/*      - new tclshcpp shell

  - Changes
    - rtl/vlib/comlib
      - byte2cdata,cdata2byte     - re-write, commas now 2 byte sequences
    - rtl/vlib/rlink
      - rlink_core                - re-write for rlink v4
    - rtl/*/*                     - use new rlink v4 iface and 4 bit STAT
    - rtl/vlib/rbus/rbd*          - new addresses in 16 bit rlink space
    - rtl/vlib/simlib/simlib      - add simfifo_*, wait_*, writetrace
    - tools/bin/
      - fx2load_wrapper           - use _ic instead of _as as default firmware
      - ti_rri                    - use tclshcpp (C++ based) rather tclsh
    - tools/fx2/bin/*.ihx         - recompiled with sdcc 3.3.0 + bugfixes
    - tools/fx2/src/Makefile      - support sdcc 3.3.0
    - tools/src/
      - */*.cpp                   - adopt for rlink v4; use nullptr 
      - librlink/RlinkCrc16       - 16 crc, replaces RlinkCrc8
      - librlink/RlinkConnect     - many changes for rlink v4
      - librlink/RlinkPacketBuf*  - re-write for for rlink v4
    - tools/tcl/*/*.tcl           - adopt for rlink v4
    - renames:
      - tools/bin/telnet_starter  -> tools/bin/console_starter

  - Bug fixes
    - tools/fx2/src
      - dscr_gen.A51              - correct string 0 descriptor
      - lib/syncdelay.h           - handle triple nop now properly

  - Known issues
    - rlink v4 error recovery not yet implemented, will crash on error
    - command lists aren't split to fit in retransmit buffer size
      {both issues not relevant for w11 backend over USB usage because the
       backend produces proper command lists and the USB channel is error free}
    - the rbus monitor (rbd_rbmon) not yet handling 16 bit addresses and
      therefore of limited use

- trunk (2014-08-08: svn rev 25(oc) 579(wfjm); tagged w11a_V0.61)  +++++++++++

  - Summary
    - The div instruction gave wrong results in some corner cases when either
      divisor or quotient were the largest negative integer (100000 or -32768).
      This is corrected now, for details see ECO-026-div.txt
    - some minor updates and fixes to support scripts
    - xtwi usage and XTWI_PATH setup explained in INSTALL.txt

  - New features
    - the Makefile's for in all rtl building block directories allow now to
      configure the target board for a test synthesis via the XTW_BOARD
      environment variable or XTW_BOARD=<board name> make option.

  - Changes
    - tools/bin/asm-11            - add call and return opcodes
    - tools/bin/create_disk       - add RM02,RM05,RP04,RP07 support
    - tools/bin/tbw               - use xtwi to start ISim models
    - tools/bin/ticonv_pdpcp      - add --tout and --cmax; support .sdef
    - tools/dox/*.Doxyfile        - use now doxygen 1.8.7
    - tools/src/librw11
      - Rw11CntlRK11              - add statistics

  - Bug fixes
    - rtl/w11a                    - div bug ECO-026
      - pdp11_munit                 - port changes; fix divide logic
      - pdp11_sequencer             - s_opg_div_sr: check for late div_quit
      - pdp11_dpath                 - port changes for pdp11_munit
    - tools/bin/create_disk       - repair --boot option (was inaccessible)
    - tools/bin/ti_w11            - split args now into ti_w11 opts and cmds
    - tools/src/librwxxtpp
      - RtclRw11Cpu                 - redo estatdef logic; avoid LastExpect()
    - tools/dox/make_doxy         - create directories, fix 'to view use' text

- w11a_V0.6 (2014-06-06) +++++++++++++++++++++++++++++++++++++++++++++++++++++

  cummulative summary of key changes from w11a_V0.5 to w11a_V0.60
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
    - for a Digilent S3BOARD    rtl/sys_gen/w11a/s3board/sys_w11a_s3
    - for a Digilent Nexys2     rtl/sys_gen/w11a/nexys2/sys_w11a_n2
