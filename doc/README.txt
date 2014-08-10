$Id: README.txt 579 2014-08-08 20:39:46Z mueller $

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

- trunk (2014-08-08: svn rev 25(oc) 579(wfjm); tagged w11a_V0.61)  ++++++++++

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
