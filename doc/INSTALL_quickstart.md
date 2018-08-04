# Quick start Guide

This _quick start guide_ describes the fastest possible path to a running
operating system on a w11 on current Series-7 based boards. It leaves out
legacy Spartan-3 and Spartan-6 designs, verification, test benches, test
designs, and many other aspects, for all this consult the full
[INSTALL](INSTALL.md) and the READMEs in [doc](.). This write-up
focuses on the steps _[prepare](#user-content-prepare)_,
_[build](#user-content-build)_ and _[boot](#user-content-boot)_,
and gives one [concrete example](#user-content-tested).

### <a id="prepare">Prepare</a>

First all required software must be installed
- clone the w11 project, essentially

      git clone https://github.com/wfjm/w11

  for details see [INSTALL#download](INSTALL.md#user-content-download).

- ensure the packages required for the backend software are installed,
  see [INSTALL#sysreq](INSTALL.md#user-content-sysreq), and that
  Xilinx Vivado is installed.

- setup the shell environment,
  see [INSTALL#envvar](INSTALL.md#user-content-envvar),
  
      export RETROBASE=<install-dir>
      export PATH=$PATH:$RETROBASE/tools/bin:.
      export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$RETROBASE/tools/lib
      
      export TCLINC=/usr/include/tcl8.6
      export TCLLIBNAME=tcl8.6

      export XTWV_PATH=<install-path-of-vivado>

  setup the TCL environment,
  see [INSTALL#build-tcl](INSTALL.md#user-content-build-tcl)

      cd $HOME
      ln -s $RETROBASE/tools/tcl/.tclshrc .
      ln -s $RETROBASE/tools/tcl/.wishrc  .

   and ensure that USB `udev` rules for access and latency are setup,
   see [tools/sys/README](../tools/sys/README.md).
  
- compile the backend software tools

       cd $RETROBASE/tools/src
       time make -j 4

       cd $RETROBASE/tools/tcl
       setup_packages

  see [INSTALL#build-tools](INSTALL.md#user-content-build-tools).

### <a id="build">Build: generate bit file and configure FPGA</a>

All details of the Vivado implementation flow are encapsulated by the
[build system](README_buildsystem_Vivado.md) in a simple `make` command

    cd $RETROBASE/rtl/sys_gen/w11a/<board>
    time make sys_w11a_<btype>.bit

with the currently supported combinations

    board           btype     memory   Comment
    cmoda7          c7        672 kB   Digilent Cmod A7 board
    arty_bram       br_arty   176 kB   Digilent Arty A7-35 board
    basys3          b3        176 kB   Digilent Basys3 board
    nexys4d_bram    br_n4d    512 kB   Digilent Nexys4 board (DDR RAM)
    nexys4          n4       3840 kB   Digilent Nexys4 board (cellular RAM)

The FPGA is configured via the vivado hardware server with

    make sys_w11a_<btype>.vconfig

### <a id="boot">Boot an operating system</a>

A variety of _oskits_ is provided under [tools/oskit](../tools/oskit).
The quick start guide describes only how to boot plain 2.11BSD. The
full featured [211bsd_rp](../tools/oskit/211bsd_rp/README.md) can be
used when more than 1024 kB memory is available, for systems with 512 to
1024 kB memory use the pruned down
[211bsd_rpmin](../tools/oskit/211bsd_rpmin/README.md).
For 2.11BSD with Ethernet, other OS and more details consult
[w11a_os_guide](w11a_os_guide.md).

Key steps are
- consult the README in the oskit directory and download the disk image files,
  typically with a `wget` and `tar` command
  
- setup `vt100` emulator windows

      cd $RETROBASE/tools/oskit/<oskit-name>
      console_starter -d DL0 &
      console_starter -d DL1 &

- configure the board switches _(important!!)_ and start the backend software
  with the options as described in
  [w11a_os_guide#rlink](w11a_os_guide.md#user-content-rlink), typically

      cd $RETROBASE/tools/oskit/<oskit-name>
      ti_w11 <options> @<oskit-name>_boot.tcl

  Hit `<ENTER>` in the `DL0vt100` console window to connect, than follow
  the expected startup sequence on the console `DL0vt100` is described in the
  README in the oskit directory.

### <a id="tested">Concrete test run</a>
The recipe was tested
- system environment
  - Kubuntu 16.04 LTS
  - Vivado 2017.1
  - on 2018-08-04

- after commit [6ee3ed6](https://github.com/wfjm/w11/commit/6ee3ed6)

      cd $RETROBASE/tools/src
      time make -j 4
        # real 2m58.501s   user 5m4.244s   sys 0m35.600s

- for design `nexys4`
      
      cd $RETROBASE/rtl/sys_gen/w11a/nexys4
      time make sys_w11a_n4.bit
      # real 10m48.274s   user 0m55.660s   sys 0m3.160s
      time make sys_w11a_n4.vconfig
      # real 0m32.747s   user 0m15.996s   sys 0m0.736s
      
- for oskit `211bsd_rp`
  - in linux terminal
  
        cd $RETROBASE/tools/oskit/211bsd_rp
        wget http://www.retro11.de/data/oc_w11/oskits/211bsd_rpset.tgz
        tar -xzf 211bsd_rpset.tgz

        console_starter -d DL0 &
        console_starter -d DL1 &

        # set board switches to SWI = 00000000 00101000
        ti_w11 -tuD,12M,break,cts  @211bsd_rp_boot.tcl

  - in window `DL1vt100` hit `<ENTER>` to connect to backend, than see output and do required inputs as written in [README](../tools/oskit/211bsd_rp/README.md):
  
        70Boot from xp(0,0,0) at 0176700
        : {<CR>}
        : xp(0,0,0)unix
        Boot: bootdev=05000 bootcsr=0176700
        ...
        # ^D
        ...
        login: {root}

  - when done with exploring 2.11BSD do proper system shutdown
    - in 211bsd session type `shutdown`
    - in ti_w11 session wait for `CPU attention` and `H:cpu0` prompt,
      than exit with `^D`.
