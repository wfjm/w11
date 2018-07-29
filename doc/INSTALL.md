# Guide to install and build w11a systems, test benches and support software

###  Table of content
  
- [Download](#user-content-download)
- [System requirements](#user-content-sysreq)
- [Setup environment variables](#user-content-envvar)
- [Compile UNISIM/UNIMACRO/SIMPRIM libraries for ghdl](#user-content-ghdl-lib)
- [Compile and install the support software](#user-content-build-tools)
  - [Compile sharable libraries](#user-content-build-cpp)
  - [Setup Tcl packages](#user-content-build-tcl)
- [The build system](#user-content-build-system)
- [Available designs](#user-content-build-fpga)
- [Available bitkits with bit and log files](#user-content-bitkits)
- [Generate Doxygen based source code view](#user-content-build-doxy)

### <a id="download">Download</a>

All instructions below assume that the project files reside in a
working directory with the name represented as `<install-dir>`

- to download the repository

        git clone https://github.com/wfjm/w11

- use the latest snapshop under `master`

        cd <install-dir>
        git checkout master

- to use tagged verions list available tags
      
        cd <install-dir>
        git tag -l

   and select one of them

        cd <install-dir>
        git checkout tags/<tag>

The GitHub repository contains the full version history since 2010.
Prior to October 2016 the project was maintained on OpenCores, access
to the legacy svn repository is described in
[INSTALL_from_opencores.md](INSTALL_from_opencores.md).

### <a id="sysreq">System requirements</a>
  
This project contains not only VHDL code but also support software. Therefore
quite a few software packages are expected to be installed. The following
list gives the Ubuntu/Debian package names, but mapping this to other
distributions should be straight forward. 

- building the FPGA bit files requires the Xilinx design tools 
  - Vivado WebPACK (for Artix-7 based designs)
  - ISE WebPACK (for Spartan-3 and Spartan-6 based designs)
- building and using the rlink backend software requires:
  - full C/C++ development chain (gcc,g++,cpp,make)  
      -> package: `build-essential`
  - Boost C++ library (>= 1.40), with date-time, thread, and regex  
    -> package: `libboost-dev` `libboost-date-time-dev` `libboost-thread-dev`
                `libboost-regex-dev`
  - libusb 1.0 (>= 1.0.6)  
    -> package: `libusb-1.0-0-dev`
  - Perl (>= 5.10)  (usually included in base installations)
  - Tcl  (>= 8.6), with tclreadline support  
    -> package: `tcl` `tcl-dev` `tcllib` `tclreadline`

- for VHDL simulations one needs
  - ghdl  
    -> see [INSTALL_ghdl.md](INSTALL_ghdl.md) for the unfortunately gory details
  - gtkwave  
    -> package: `gtkwave`

- additional requirements for using Cypress FX (on Nexys2/3) see
  [INSTALL_fx2_support.md](INSTALL_fx2_support.md).

- for doxygen documentation an up-to-date installation of doxygen is
  required, version 1.8.3.1 or later


### <a id="envvar">Setup environment variables</a>

The make flows for building test benches (ghdl, Vivado xsim or ISE ISim based)
and FPGA bit files (with Vivado or ISE) as well as the support software
(mainly the rlink backend server) requires the definition of the environment 
variables:

| Variable | Comment |
| :------- | :------ |
| `RETROBASE`     | must refer to the installation root directory |
| `PATH`          | the tools binary directory `$RETROBASE/tools/bin` must be in the path |
|                 | current working directory `.` must be in the path (expected e.g. by `TBW`) |
| `LD_LIBRARY_PATH` | the tools library directory `$RETROBASE/tools/lib` must be in the library path |
| `MANPATH`       | the tools man page directory `$RETROBASE/tools/man` should be in the man path |
| `TCLINC`        | pathname for includes of Tcl runtime library |
| `TCLLIBNAME`    | name of Tcl runtime library |
| `RETRO_FX2_VID` | default USB VID, see below |
| `RETRO_FX2_PID` | default USB PID, see below |
| `TCLLIB`        | pathname for libraries of Tcl _(optional)_ |
| `BOOSTINC`      | pathname for includes of boost library _(optional)_ |
| `BOOSTLIB`      | pathname for libraries of boost library _(optional, `BOOSTINC` and `BOOSTLIB` must be either both defined or both undefined)_ |
    
For bash and alike use

      export RETROBASE=<install-dir>
      export PATH=$PATH:$RETROBASE/tools/bin:.
      export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$RETROBASE/tools/lib
      export MANPATH=$MANPATH:$RETROBASE/tools/man

In most cases the boost library version coming with the distribution will
work, similar for Tcl, in those cases simply use

      export TCLINC=/usr/include/tcl8.6
      export TCLLIBNAME=tcl8.6

and don't setup `BOOSTINC` and `BOOSTLIB`.

After that building functional model based test benches will work. If you 
want to also build post-synthesis or post-place&route test benches 
read next section.

For Cypress FX2 (on Nexys2/3) related setup see 
[INSTALL_fx2_support.md](INSTALL_fx2_support.md).

### <a id="ghdl-lib">Compile UNISIM/UNIMACRO/SIMPRIM libraries for ghdl</a>

The build system for test benches also supports test benches run against the
gate level models derived after synthesis or place&route. In this case ghdl
has to link against a compiled a `UNISIM`, `UNIMACRO` or `SIMPRIM` library.
The details are described in
- [README_buildsystem_Vivado.md](README_buildsystem_Vivado.md#user-content-ghdllibs)
- [README_buildsystem_ISE.md](README_buildsystem_ISE.md#user-content-ghdllibs)

### <a id="build-tools">Compile and install the support software</a>

#### <a id="build-cpp">Compile sharable libraries</a>

Note: some `c++11` features are used in the code

| Feature | Description | in gcc since |
| :------ | :---------- | :----------: |
| N2343 | decltype (used by boost bind)  | gcc 4.3 |
| N2431 | nullptr                        | gcc 4.6 |
| N2930 | range based for                | gcc 4.6 |
| N1984 | auto-types variables           | gcc 4.4 |

Required tools and libraries:

    g++    >= 4.6    (see c++11 usage above)
    boost  >= 1.35   (boost::thread api changed, new one is used)
    linusb >= 1.0.5  (timerfd support)

Build was tested under:

    ubuntu xenial  (16.04 LTS):  gcc 5.4.0  boost 1.58    libusb 1.0.20
    ubuntu trusty  (14.04 LTS):  gcc 4.8.2  boost 1.54    libusb 1.0.17
    debian wheezy  (7.0.8):      gcc 4.7.2  boost 1.49    libusb 1.0.11

To build all sharable libraries

    cd $RETROBASE/tools/src
    make -j 4

Default is to compile with `-O2` and without `-g`. These options can be
overwritten with the `CXXOPTFLAGS` enviromnent variable (or make opion).
To build with `-O3` optimize use

    make -j 4 CXXOPTFLAGS=-O3

To build a debug version with full symbol table use

    make -j 4 CXXOPTFLAGS=-g

To cleanup, e.g. before a re-build
    
    cd $RETROBASE/tools/src
    rm_dep
    make realclean

#### <a id="build-tcl">Setup Tcl environment</a>

The Tcl files are organized in several packages. To create the Tcl
package files (`pkgIndex.tcl`)

    cd $RETROBASE/tools/tcl
    setup_packages

To use these packages it is convenient to make them available via the
'auto_path' mechanism. To do that add in your `.tclshrc` or `.wishrc`

    lappend auto_path [file join $env(RETROBASE) tools tcl]
    lappend auto_path [file join $env(RETROBASE) tools lib]

The w11 project contains two ready to use `.tclshrc` or `.wishrc`
files which
- include the auto_path statements above
- activate `tclreadline` (and thus in `tclshrc` an event loop)

To use them simply copy them into your home directory (or soft link them)

    cd $HOME
    ln -s $RETROBASE/tools/tcl/.tclshrc .
    ln -s $RETROBASE/tools/tcl/.wishrc  .

### <a id="build-system">The build system</a>

The generation of FPGA firmware and test benches is based on make flows. 
  
All details on
- building test benches
- building FPGA bit files
- configuring FPGAs

can be found under
- [README_buildsystem_Vivado.md](README_buildsystem_Vivado.md)
  for Artix-7 based designs
- [README_buildsystem_ISE.md](README_buildsystem_ISE.md)
  for Spartan-3 and Spartan-6 based designs

### <a id="build-fpga">Available designs</a>

Ready to build designs are organized in the directories

    $RETROBASE/rtl/sys_gen/<design>/<board>

    with <design>
      w11a            w11a system
      tst_rlink       rlink over serial link tester
      tst_rlink_cuff  rlink over FX2 interface tester

    and <board>
      basys3          b3: Digilent Basys3 board
      nexys4          n4: Digilent Nexys4 board (cellular RAM version)
      nexys3          n3: Digilent Nexys3 board
      nexys2          n2: Digilent Nexys2 board (-1200 FPGA version)
      s3board         s3: Digilent S3board (-1000 FPGA version)

To build the designs locally use

     cd $RETROBASE/rtl/sys_gen/<design>/<board>
     make sys_<dtype>_<btype>.bit

with in most cases 
- `<dtype>` = `<design>`
- `<code>` = 2 letter abbreviation for the board, e.g. n4 for nexys4.

### <a id="bitkits">Available bitkits with bit and log files</a>

Tarballs with ready to use bit files and all logfiles from the tool 
chain can be downloaded from
http://www.retro11.de/data/oc_w11/bitkits/ .

This area is organized in folders for different releases. The tarball
file names contain information about release, Xlinix tool, and design:

    <release>_<tool>_<design>.tgz

- Vivado based designs:
  These designs can be loaded with the Vivado hardware server into the FPGA.

- ISE based designs:
  These designs can be loaded with `config_wrapper` into the FPGA. The
  procedures for the supported boards are given below.

  Notes:
  1. `XTWI_PATH` and `RETROBASE` environment variables must be defined.
  2. `config_wrapper bit2svf` is only needed once to create the svf files.
  3. fx2load_wrapper is needed once after each board power on.

  - for Digilent Nexys3 board (using Cypress FX2 USB controller)

          xtwi config_wrapper --board=nexys3 bit2svf <design>.bit
          fx2load_wrapper     --board=nexys3
          xtwi config_wrapper --board=nexys3 jconfig <design>.svf

  - for Digilent Nexys2 board (using Cypress FX2 USB controller)

          xtwi config_wrapper --board=nexys2 bit2svf <design>.bit
          fx2load_wrapper     --board=nexys2
          xtwi config_wrapper --board=nexys2 jconfig <design>.svf

  - for Digilent S3board (using ISE Impact)

          xtwi config_wrapper --board=s3board iconfig <design>.bit

### <a id="build-doxy">Generate Doxygen based source code view</a>

Currently there is not much real documentation included in the source
files. The doxygen generated html output is nevertheless very useful
to browse the code. C++, Tcl and Vhdl source are covered by setup files
contained in the project files.

To generate the html files

     cd $RETROBASE/tools/dox
     export RETRODOXY <desired root of html documentation>
     ./make_doxy

If `RETRODOXY` is not defined `/tmp` is used. To view the docs use

     firefox $RETRODOXY/w11/cpp/html/index.html &
     firefox $RETRODOXY/w11/tcl/html/index.html &
     firefox $RETRODOXY/w11/vhd/html/index.html &
