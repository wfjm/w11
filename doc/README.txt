# $Id: README.txt 467 2013-01-02 19:49:05Z mueller $

Release notes for w11a

  Table of content:
  
  1. Documentation
  2. Files
  3. Change Log


1. Documentation -------------------------------------------------------------

  More detailed information on installation, build and test can be found 
  in the doc directory, specifically

    * README.txt: release notes
    * INSTALL.txt: installation and building test benches and systems
    * w11a_tb_guide.txt: running test benches
    * w11a_os_guide.txt: booting operating systems 
    * w11a_known_issues.txt: known differences, limitations and issues

2. Files ---------------------------------------------------------------------

   doc                          Documentation
   rtl                          VHDL sources
   rtl/bplib                    - board and component support libs
   rtl/bplib/atlys                - for Digilent Atlys board
   rtl/bplib/fx2lib               - for Cypress FX2 USB interface controller
   rtl/bplib/issi                 - for ISSI parts
   rtl/bplib/micron               - for Micron parts
   rtl/bplib/nexys2               - for Digilent Nexsy2 board
   rtl/bplib/nexys3               - for Digilent Nexsy3 board
   rtl/bplib/nxcramlib            - for CRAM part used in Nexys2/3
   rtl/bplib/s3board              - for Digilent S3BOARD
   rtl/ibus                     - ibus devices (UNIBUS peripherals)
   rtl/sys_gen                  - top level designs
   rtl/sys_gen/tst_fx2loop        - top level designs for Cypress FX2 tester
     nexys2                         - systems for Nexsy2
   rtl/sys_gen/tst_rlink          - top level designs for an rlink tester
     nexys2,nexys3,s3board          - systems for Nexsy2,Nexsy3,S3BOARD
   rtl/sys_gen/tst_rlink_cuff     - top level designs for rlink over FX2 tester
     nexys2                         - systems for Nexsy2
   rtl/sys_gen/tst_serloop        - top level designs for serport loop tester
     nexys2,nexys3,s3board          - systems for Nexsy2,Nexsy3,S3BOARD
   rtl/sys_gen/tst_snhumanio      - top level designs for human I/O tester
     atlys,nexys2,nexys3,s3board    - systems for Atlys,Nexsy2,Nexsy3,S3BOARD
   rtl/sys_gen/w11a               - top level designs for w11a SoC
     nexys2,nexys3,s3board          - w11a systems for Nexsy2,Nexsy3,S3BOARD
   rtl/vlib                     - VHDL component libs
   rtl/vlib/comlib                - communication
   rtl/vlib/genlib                - general
   rtl/vlib/memlib                - memory
   rtl/vlib/rbus                  - rri: rbus
   rtl/vlib/rlink                 - rri: rlink
   rtl/vlib/serport               - serial port (UART)
   rtl/vlib/simlib                - simulation helper lib
   rtl/vlib/xlib                  - Xilinx specific components
   rtl/w11a                     - w11a core
   tools                        helper programs
   tools/bin                    - scripts and binaries
   tools/dox                    - Doxygen documentation configuration
   tools/make                   - make includes
   tools/fx2                    - Firmware for Cypress FX2 USB Interface
   tools/fx2/bin                  - pre-build firmware images in .ihx format
   tools/fx2/src                  - C and asm sources
   tools/fx2/sys                  - udev rules for USB on fpga eval boards
   tools/src                    - C++ sources for rlink backend software
   tools/src/librlink             - basic rlink interface
   tools/src/librlinktpp          - C++ to tcl binding for rlink interface
   tools/src/librtcltools         - support classes to implement Tcl bindings
   tools/src/librtools            - general support classes and methods
   tools/src/librutiltpp          - Tcl support commands implemented in C++
   tools/tcl                    - Tcl scripts

3. Change Log ----------------------------------------------------------------

- trunk (2013-01-02: svn rev 17(oc) 467(wfjm); untagged w11a_V0.56) ++++++++++

  - Summary
    - re-organized handling of board and derived clocks in test benches
    - added message filter definitions for some designs (.mfset files)
    - added Cypress EZ-USB FX2 controller (USB interface)
    - added firmware for EZ-USB FX2 supporting jtag access and data transfer
    - FPGA configure over USB now supported directly in make build flow
    - added test systems for USB testing and rlink over USB verification
    - no functional change of w11a CPU core or any pre-existing test systems
    - Note: Carefully read the disclaimer about usage of USB VID/PID numbers
            in the file README_USB-VID-PID.txt. You'll be responsible for any
            misuse of the defaults provided with the project sources !!

  - New refernce system
    The development and test system was upgraded from Kubuntu 10.04 to 12.04.
    The version of several key tools and libraries changed:
       linux kernel    3.2.0    (was  2.6.32)
       gcc/g++         4.6.3    (was  4.4.3)
       boost           1.46.1   (was  1.40)
       libusb          1.0.9    (was  1.0.6)
       perl            5.14.2   (was  5.10.1)
       tcl             8.5.11   (was  8.4.19)
       xilinx ise     13.3      (was 13.1)
    --> see INSTALL.txt, INSTALL_ghdl.txt and INSTALL_urjtag.txt

  - New features
    - added firmware for Cypress FX2 controller
      - tools/fx2
        - bin    - pre-build firmware images in .ihx file format
        - src    - C and asm sources
        - sys    - udev rules for usb interfaces on fpga eval boards
    - new modules
      - rtl/bplib/fx2lib
        - fx2_2fifoctl_ic - Cypress EZ-USB FX2 controller (2 fifo; int clk)
        - fx2_3fifoctl_ic - Cypress EZ-USB FX2 controller (3 fifo; int clk)
    - new systems
      - rtl/sys_gen/tst_fx2loop/nexys2/ic/sys_tst_fx2loop_ic_n2
      - rtl/sys_gen/tst_fx2loop/nexys2/ic3/sys_tst_fx2loop_ic3_n2
      - rtl/sys_gen/tst_rlink_cuff/nexys2/ic/sys_tst_rlink_cuff_ic_n2
    - tools/bin
      - xilinx_sdf_ghdl_filter: tool to patch ISE sdf files for usage with ghdl

  - Changes
    - documentation
      - added a 'system requirements' section in INSTALL.txt
      - added INSTALL_ghdl.txt and INSTALL_urjtag.txt covering ghdl and urjtag
      - added README_USB-VID-PID.txt
    - organizational changes
      - added TCLINC,RETRO_FX2_VID,RETRO_FX2_PID environment variables
    - functional changes
      - tools/bin
        - vbomconv - file name substitution handling redone; many vboms updated
    - retired modules
      - vlib/rlink/tb/
        - tbcore_rlink_dcm  - obsolete, use tbcore_rlink

- trunk (2011-12-23: svn rev 16(oc) 442(wfjm); untagged w11a_V0.55)  +++++++++

  - Summary
    - added xon/xoff (software flow control) support to serport library
    - added test systems for serport verification
    - use new serport stack in sys_w11a_* and sys_tst_rlink_* systems

  - New features
    - new modules
      - vlib/serport
        - serport_xonrx  - xon/xoff logic rx path
        - serport_xontx  - xon/xoff logic tx path
        - serport_1clock - serial port module (uart, fifo, flow control)
      - vlib/rlink
        - rlink_core8 - rlink core8 with 8bit interface
        - rlink_sp1c  - rlink_core8 + serport_1clock combo
    - new unit tests
      - bplib/s3board/tb/tb_s3_sram_memctl       (for s3board sram controller
      - bplib/nxcramlib/tb/tb_nx_cram_memctl_as  (for nexys2,3 cram controller)
    - new systems
      - sys_gen/tst_serloop/nexys2/sys_tst_serloop1_n2
      - sys_gen/tst_serloop/nexys3/sys_tst_serloop1_n3
      - sys_gen/tst_serloop/s3board/sys_tst_serloop1_s3
      - sys_gen/tst_rlink/s3board/sys_tst_rlink_s3

  - Changes
    - retired modules
      - vlib/rlink
        - rlink_rlb2rl       - obsolete, now all in rlink_core8
        - rlink_base         - use now new rlink_core8
        - rlink_serport      - obsolete, now all in rlink_sp1c
        - rlink_base_serport - use now new rlink_sp1c

- trunk (2011-12-04: svn rev 15(oc) 436(wfjm); untagged w11a_V0.54)  +++++++++

  - Summary
    - added support for nexys3 board for w11a

  - New features
    - new systems
      - sys_gen/w11a/nexys3/sys_w11a_n3
      - sys_gen/w11a/nexys3/sys_tst_rlink_n3

  - Changes
    - module renames:
        bplib/nexys2/n2_cram_dummy     -> bplib/nxcramlib/nx_cram_dummy
        bplib/nexys2/n2_cram_memctl_as -> bplib/nxcramlib/nx_cram_memctl_as

  - Bug fixes
    - tools/src/lib*: backend libraries compile now on 64 bit systems

- trunk (2011-11-20: svn rev 14(oc) 428(wfjm); untagged w11a_V0.532) +++++++++

  - Summary
    - generalized the 'human I/O' interface for s3board,nexys2/3 and atlys
    - added test design for the 'human I/O' interface
    - no functional change of w11a CPU core or any existing test systems

  - Changes
    - functional changes
      - use now 'a6' polynomial of Koopman et al for crc8 in rlink
    - with one exception all vhdl sources use now numeric_std
    - module renames:
        vlib/xlib/dcm_sp_sfs_gsim   -> vlib/xlib/dcm_sfs_gsim
        vlib/xlib/dcm_sp_sfs_unisim -> vlib/xlib/dcm_sfs_unisim_s3e
        vlib/xlib/tb/tb_dcm_sp_sfs  -> vlib/xlib/tb/tb_dcm_sfs

  - New features
    - new modules
      - rtl/sys_gen/tst_snhumanio
        - sub-tree with test design for 'human I/O' interface modules
        - atlys, nexys2, and s3board directories contain the systems
          for the respective Digilent boards

- trunk (2011-09-11: svn rev 12(oc) 409(wfjm); untagged w11a_V0.531) +++++++++

  - Summary
    - Many small changes to prepare upcoming support for
      - Spartan-6 boards (nexys3 and atlys)
      - usage of Cypress FX2 USB interface on nexys2/3 and atlys boards
    - no functional change of w11a CPU core or any test systems

  - Changes
    - use boost libraries instead of custom coding:
      - boost/function and /bind for callbacks, retire RmethDscBase and RmethDsc
      - boost/foreach for some iterator loops
      Note: boost 1.35 and gcc 4.3 or newer is required, see INSTALL.txt
    - module renames:
        bplib/s3board/s3_rs232_iob_int -> bplib/bpgen/bp_rs232_2line_iob
        bplib/s3board/s3_rs232_iob_ext -> bplib/bpgen/bp_rs232_4line_iob
        bplib/s3board/s3_dispdrv       -> bplib/bpgen/sn_4x7segctl
        bplib/s3board/s3_humanio       -> bplib/bpgen/sn_humanio
        bplib/s3board/s3_humanio_rbus  -> bplib/bpgen/sn_humanio_rbus
    - other renames:
        tools/bin/impact_wrapper       -> tools/bin/config_wrapper
    - reorganize Makefile includes and xflow option files
        rtl/vlib/Makefile.ghdl         -> rtl/make/generic_ghdl.mk
        rtl/vlib/Makefile.isim         -> rtl/make/generic_isim.mk
        rtl/vlib/Makefile.xflow        -> rtl/make/generic_xflow.mk
        rtl/vlib/xst_vhdl.opt          -> rtl/make/syn_s3_speed.opt
        rtl/vlib/balanced.opt          -> rtl/make/imp_s3_speed.opt

- trunk (2011-04-17: svn rev 11(oc) 376(wfjm); untagged w11a_V0.53) ++++++++++

  - Summary
    - Introduce C++ and Tcl based backend server. A set of C++ classes provide
      the basic rlink communication primitives. Additional glue classes provide
      a Tcl binding. This first phase contains the basic functionality needed
      to control simple test benches.
    - add an 'rlink exerciser' (tst_rlink) and a top level design for a Nexys2
      board (sys_tst_rlink_n2) and a test suite implemented in Tcl.

  - Note: No functional changes in w11a core and I/O system at this point!
          The w11a demonstrator systems are still operated with the old
          backend code (pi_rri).

  - New features
    - new directory trees for
      - C++ sources of backend (plus make and doxygen documentation support)
        - tools/dox                - Doxygen documentation configuration
        - tools/make               - make includes
        - tools/src/librlink       - basic rlink interface
        - tools/src/librlinktpp    - C++ to tcl binding for rlink interface
        - tools/src/librtools      - general support classes and methods
        - tools/src/librtcltools   - support classes to implement Tcl bindings
        - tools/src/librutiltpp    - Tcl support commands implemented in C++
      - VHDL sources of an 'rlink exerciser'
        - rtl/sys_gen/tst_rlink    - top level designs for an rlink tester
        - rtl/sys_gen/tst_rlink/nexys2  - rlink tester system for Nexsy2 board
      - Tcl sources of 'rlink exerciser'
        - tools/tcl/rlink          - defs and proc's for basic rlink functions
        - tools/tcl/rutil          - general support procs
        - tools/tcl/rbtest         - defs and proc's for rbd_tester
        - tools/tcl/rbbram         - defs and proc's for rbd_bram
        - tools/tcl/rbmoni         - defs and proc's for rbd_rbmon
        - tools/tcl/rbs3hio        - defs and proc's for s3_humanio_rbus
        - tools/tcl/tst_rlink      - defs and proc's for tst_rlink
    - new modules
      - rtl/vlib/rbus
        - rbd_bram     - rbus bram test target
        - rbd_eyemon   - eye monitor for serport's
        - rbd_rbmon    - rbus monitor
        - rbd_tester   - rbus tester
        - rbd_timer    - usec precision timer
      - rtl/vlib/memlib
        - additional wrappers for distributed and block memories added
      - tools/bin
        - ti_rri: Tcl driver for rlink tests and servers (will replace pi_rri)

- trunk (2011-01-02: svn rev 9(oc) 352(wfjm); untagged w11a_V0.52) +++++++++++

  - Summary
    - Introduce rbus protocol V3
    - reorganize rbus and rlink modules, many renames

  - New features
    - vlib/rbus
      - added several rbus devices useful for debugging
        - rbd_tester: test target, used for example in test benches

  - Changes
    - module renames:
      - the rri (remote-register-interface) components were re-organized and
        cleanly separated into rbus and rlink components:
          rri/rb_sres_or_*              -> rbus/rb_sres_or_*     
          rri/rri_core                  -> rlink/rlink_core    
          rri/rri_base_serport          -> rlink/rlink_base_serport    
          rri/rrilib                    -> rbus/rblib    
                                        -> rlink/rlinklib    
          rri/rri_serport               -> rlink/rlink_serport    
          rri/tb/rritb_sres_or_mon      -> rbus/rb_sres_or_mon    
      - the rri test bench monitors were reorganized and renamed
          rri/tb/rritb_cpmon            -> rlink/rlink_mon    
          rri/tb/rritb_cpmon_sb         -> rlink/rlink_mon_sb    
          rri/tb/rritb_rbmon            -> rbus/rb_mon    
          rri/tb/rritb_rbmon_sb         -> rbus/rb_mon_sb    
      - the rri low level test bench were also renamed
          rri/tb/tb_rri                 -> rlink/tb/tb_rlink    
          rri/tb/tb_rri_core            -> rlink/tb/tb_rlink_direct    
          rri/tb/tb_rri_serport         -> rlink/tb/tb_rlink_serport    
      - the base modules for rlink+cext based test benches were renamed
          rri/tb/rritb_core_cm          -> rlink/tb/tbcore_rlink_dcm
          rri/tb/rritb_core             -> rlink/tb/tbcore_rlink
          rri/tb/vhpi_rriext            -> rlink/tb/rlink_cext_vhpi
          rri/tb/cext_rriext.c          -> rlink/tb/rlink_cext.c

      - other rri/rbus related renames
          bplib/s3board/s3_humanio_rri  -> s3_humanio_rbus
          w11a/pdp11_core_rri           -> pdp11_core_rbus

      - other renames
          w11a/tb/tb_pdp11_core         -> tb_pdp11core

    - signal renames:
      - rlink interface (defined in rlink/rlinklib.vhd): 
        - rename rlink port signals:
          CP_*  -> RL_*
        - rename status bit names to better reflect their usage in v3:
          ccrc  -> cerr   - indicates cmd crc error or other cmd level abort
          dcrc  -> derr   - indicates data crc error or other data level abort
          ioto  -> rbnak  - indicates rbus abort, either no ack or timeout
          ioerr -> rberr  - indicates that rbus err flag was set

    - migrate to rbus protocol version 3
      - in rb_mreq use now aval,re,we instead of req,we
      - basic rbus transaction now takes 2 cycles, one for address select, one
        for data exchange. Same concept and reasoning behind as in ibus V2.

    - vlib/rlink/rlink_core
      - cerr and derr state flags now set on command or data crc errors as well
        as on eop/nak aborts when command or wblk data is received.
      - has now 'monitor port', RL_MONI.
      - RL_FLUSH port removed, the flush logic is now in rlink_serport

    - restructured rlink modules
      - rlink_core is the rlink protocol engine with a 9 bit wide interface
      - rlink_rlb2rl (new) is an adapter to a byte wide interface
      - rlink_base (new) combines rlink_core and rlink_rlb2rl
      - rlink_serport (re-written) is an adapter to a serial interface
      - rlink_base_serport (renamed) combines rlink_base and rlink_serport

- trunk (2010-11-28: svn rev 8(oc) 341(wfjm); untagged w11a_V0.51) +++++++++++

  - Summary 
    - Introduce ibus protocol V2
    - Nexys2 systems use DCM
    - sys_w11a_n2 now runs with 58 MHz

  - New features
    - ibus
      - added ib_sres_or_mon to check for miss-behaving ibus devices
      - added ib_sel to encapsulate address select logic
    - nexys2 systems
      - now DCM derived system clock supported
      - sys_gen/w11a/nexys2
        - sys_w11a_n2 now runs with 58 MHz clksys

  - Changes
    - module renames:
      - in future 'box' is used for large autonomous blocks, therefore use
        the term unit for purely sequential logic modules:
          pdp11_abox -> pdp11_ounit
          pdp11_dbox -> pdp11_aunit
          pdp11_lbox -> pdp11_lunit
          pdp11_mbox -> pdp11_munit

    - signal renames:
      - renamed RRI_LAM -> RB_LAM in all ibus devices
      - renamed CLK     -> I_CLK50 in all top level nexys2 and s3board designs

    - migrate to ibus protocol version 2
      - in ib_mreq use now aval,re,we,rmw instead of req,we,dip
      - basic ibus transaction now takes 2 cycles, one for address select, one
        for data exchange. This avoids too long logic paths in the ibus logic.

  - Bug fixes
    - rtl/vlib/Makefile.xflow: use default .opt files under rtl/vlib again.

- w11a_V0.5 (2010-07-23) +++++++++++++++++++++++++++++++++++++++++++++++++++++

  Initial release with 
  - w11a CPU core
  - basic set of peripherals: kw11l, dl11, lp11, pc11, rk11/rk05
  - just for fun: iist (not fully implemented and tested yet)
  - two complete system configurations with 
    - for a Digilent S3BOARD    rtl/sys_gen/w11a/s3board/sys_w11a_s3
    - for a Digilent Nexys2     rtl/sys_gen/w11a/nexys2/sys_w11a_n2
