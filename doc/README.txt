# $Id: README.txt 341 2010-11-27 23:05:43Z mueller $

Release notes for w11a

  Table of content:
  
  1. Documentation
  2. Files
  3. Change Log


1. Documentation ----------------------------------------------------------

  More detailed information on installation, build and test can be found 
  in the doc directory, specifically

    * README.txt: release notes
    * INSTALL.txt: installation and building test benches and systems
    * w11a_tb_guide.txt: running test benches
    * w11a_os_guide.txt: booting operating systems 
    * w11a_known_issues.txt: known differences, limitations and issues

2. Files ------------------------------------------------------------------

   doc                          Documentation
   rtl                          VHDL sources
   rtl/bplib                    - board and component support libs
   rtl/bplib/issi                 - for ISSI parts
   rtl/bplib/micron               - for Micron parts
   rtl/bplib/nexys2               - for Digilent Nexsy2 board
   rtl/bplib/s3board              - for Digilent S3BOARD
   rtl/ibus                     - ibus devices (UNIBUS peripherals)
   rtl/sys_gen                  - top level designs
   rtl/sys_gen/w11a               - top level designs for w11a SoC
   rtl/sys_gen/w11a/nexys2          - w11a SoC for Digilent Nexsy2
   rtl/sys_gen/w11a/s3board         - w11a SoC for Digilent S3BOARD
   rtl/vlib                     - VHDL component libs
   rtl/vlib/comlib                - communication
   rtl/vlib/genlib                - general
   rtl/vlib/memlib                - memory
   rtl/vlib/rri                   - remote-register-interface
   rtl/vlib/serport               - serial port (UART)
   rtl/vlib/simlib                - simulation helper lib
   rtl/vlib/xlib                  - Xilinx specific components
   rtl/w11a                     - w11a core
   tools                        helper programs
   tools/bin                    - scripts and binaries

3. Change Log -------------------------------------------------------------

- trunk (2010-11-28: svn rev 8(oc) 341(wfjm); untagged w11a_V0.51)

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

    - migrate to ibus protocol verion 2
      - in ib_mreq use now aval,re,we,rmw instead of req,we,dip
      - basic ibus transaction now takes 2 cycles, one for address select, one
        for data exchange. This avoids too long logic paths in ibus sector.

  - New features
    - ibus
      - added ib_sres_or_mon to check for miss-behaving ibus devices
      - added ib_sel to encapsulate address select logic
    - nexys2 systems
      - now DCM derived system clock supported
      - sys_gen/w11a/nexys2
        - sys_w11a_n2 now runs with 58 MHz clksys

  - Bug fixes
    - rtl/vlib/Makefile.xflow: use default .opt files under rtl/vlib again.

- w11a_V0.5 (2010-07-23) -------------------------------------

  Initial release with 
  - w11a CPU core
  - basic set of peripherals: kw11l, dl11, lp11, pc11, rk11/rk05
  - just for fun: iist (not fully implemented and tested yet)
  - two complete system configurations with 
    - for a Digilent S3BOARD    rtl/sys_gen/w11a/s3board/sys_w11a_s3
    - for a Digilent Nexys2     rtl/sys_gen/w11a/nexys2/sys_w11a_n2
