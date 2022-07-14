## Guide to the Build System (Xilinx ISE Version)

### Table of content

- [Concept](#user-content-concept)
- [Setup system environment](#user-content-sysenv)
  - [Setup environment variables](#user-content-envvar)
  - [Compile UNISIM/UNIMACRO/SIMPRIM libraries for GHDL](#user-content-ghdllibs)
- [Building test benches](#user-content-buildtb)
  - [With GHDL](#user-content-buildtb-ghdl)
  - [With ISE ISim](#user-content-buildtb-isim)
- [Building FPGA bit files](#user-content-buildfpga)
- [Configuring FPGAs (via make flow)](#user-content-config-make)
- [Configuring FPGAs (directly via config_wrapper)](#user-content-config-wrap)
- [Note on Artix-7 based designs](#user-content-artix)

### <a id="concept">Concept</a>

This project uses GNU make to
- generate bit files     (synthesis with xst and place&route with par)
- generate test benches  (with GHDL or Xilinx ISim)
- configure the FPGA     (with Xilinx Impact or Linux jtag)

The Makefile's in general contain only a few definitions, all the make logic
is concentrated in a few master makefiles which are included.

Simulation and synthesis tools usually need a list of the VHDL source
files, often in proper compilation order (libraries before components).
The different tools have different formats of these 'project files'.

The build system employed in this project is based on manifest files called

     'vbom' or "VHDL bill of material" files

which list for each VHDL source file the libraries and sources for the
instantiated components, the latter via their vbom, and last but not least
the name of the VHDL source file. 

All file names are relative to the current directory. A recursive traversal 
through all vbom's gives for each VHDL module all sources needed to compile
it. The vbomconv script in tools/bin does this and generates depending on 
options
- make dependency files
- ISE xst project files  (synthesis)
- ISE ISim project files (simulation)
- GHDL commands for analysis, inspection and make step

The master make files contain pattern rules like

    %.ngc  : %.vbom           -- synthesize with xst
    %      : %.vbom           -- build functional model test bench

which encapsulate all the vbomconv magic

A full w11a system is built from about 100 source files, test benches 
from even more. Using the vbom's a large number of designs can be easily 
maintained.

For more details on vbomconv consult the man page.

### <a id="sysenv">Setup system environment</a>

#### <a id="envvar">Setup environment variables</a>

The build flows require the environment variables:
- `RETROBASE`:  must refer to the installation root directory
- `XTWI_PATH`:  install path of the ISE version, without `/ISE_DS/` !
- `RETRO_FX2_VID` and `RETRO_FX2_PID`: default USB VID/PID for Cypress FX2

For general instructions on environment see [INSTALL.md](INSTALL.md) .
For details on `RETRO_FX2_VID` and `RETRO_FX2_PID` see 
[INSTALL_fx2_support.md](INSTALL_fx2_support.md).

Notes:  
- The build system uses a small wrapper script called `xtwi` to encapsulate
  the Xilinx environment. It uses `XTWI_PATH` to set up the ISE environment on 
  the fly. For details consult 'man xtwi'. 
- don't run the ISE setup scripts ..../settings(32|64).sh in your working 
  shell. Setup only `XTWI_PATH` !
  
#### <a id="ghdllibs">Compile UNISIM/UNIMACRO/SIMPRIM libraries for GHDL</a>

A few entities use `UNISIM` or `UNIMACRO` primitives, and models derived after
the par step require also `SIMPRIM` primitives. In these cases, GHDL has to
link against a compiled `UNISIM`, `UNIMACRO` or `SIMPRIM` libraries.

To make handling of the parallel installation of several ISE versions
easy the compiled libraries are stored in sub-directories under `$XILINX`:

     $XILINX/ghdl/unisim
     $XILINX/ghdl/unimacro
     $XILINX/ghdl/simprim

Two helper scripts will create these libraries:

     cd $RETROBASE
     xise_ghdl_unisim            # does UNISIM and UNIMACRO
     xise_ghdl_simprim           # does SIMPRIM

Run these scripts for each ISE version which is installed.

### <a id="buildtb">Building test benches</a>

The build flows support two simulators
- GHDL      -> open source, with VHPI support, doesn't accept sdf files
- ISE ISim  -> limited to 50k lines in WebPack, no VHPI support

#### <a id="buildtb-ghdl">With GHDL</a>

To compile a GHDL based test bench named `<tbench>` all is needed is

    make <tbench>

The make file will use `<tbench>.vbom`, create all make dependency files,
and generate the needed GHDL commands.

In many cases the test benches can also be compiled against the gate
level models derived after the `xst`, `map` or `par` step. To compile them

    make <tbench>_ssim                  # for post-xst  (using UNISIM)
    make <tbench>_fsim                  # for post-map  (using SIMPRIM)
    make <tbench>_tsim                  # for post-par  (using SIMPRIM)

Individual working directories are used for the different models

    ghdl.bsim        for bahavioral model
    ghdl.ssim        for post-xst
    ghdl.fsim        for post-map
    ghdl.tsim        for post-par

and can co-exist. The `make ghdl_tmp_clean` can be used to flush the GHDL
work areas, but in general this is not needed (since V0.73).

Notes:
- the post-xst simulation (_ssim targets) proved to be a valuable tool.
- GHDL fails to read sdf files generated by Xilinx tools, and thus does
  not support a post-par simulation with full timing.
- post-par simulations without timing annotation often fail, most likely
  due to clocking and delta cycle issues due to inserted clock buffers.

#### <a id="buildtb-isim">With ISE ISim</a>

To compile a ISE ISim based test bench named `<tbench>` all is needed is

    make <tbench>_ISim

The make file will use `<tbench>.vbom`, create all make dependency files,
and generate the needed ISE ISim project files and commands.

In many cases the test benches can also be compiled against the gate
level models derived after the xst, map or par step. To compile them

    make ise_tmp_clean
    make <tbench>_ISim_ssim             # for post-xst
    make <tbench>_ISim_fsim             # for post-map
    make <tbench>_ISim_tsim             # for post-par

Notes:
- ISim in ISE WebPack is limited to about 50k lines source code. That is
  enough for many functional simulations, a w11a system has about 27k lines,
  the test bench adds another 3k lines. But the limit gets quickly exceeded 
  with post-xst and especially post-par models. If the limit is exceeded, the
  simulation engine throttles to snails speed.
- ISim does not support VHPI (interfacing of external C routines to VHDL).
  Since VHPI is used in the rlink simulation all system test benches with
  an rlink interface, thus most, will only run with GHDL and not with ISim.
 
### <a id="buildfpga">Building FPGA bit files</a>

To generate a bit file for a system named `<sys>` all is needed is

    make <sys>.bit

The make file will use `<sys>.vbom`, create all make dependency files, build 
the ucf file with cpp, and run the synthesis flow (`xst`, `ngdbuild`, `par`,
`trce`). The log files will be conveniently renamed

    <sys>_xst.log        # xst log file
    <sys>_tra.log        # translate (ngdbuild) log file (renamed %.bld)
    <sys>_map.log        # map log file                  (renamed %_map.mrp)
    <sys>_par.log        # par log file                  (renamed %.par)
    <sys>_pad.log        # pad file                      (renamed %_pad.txt)
    <sys>_twr.log        # trce log file                 (renamed %.twr)
    <sys>_tsi.log        # trce tsi file                 (renamed %.tsi)
    <sys>_bgn.log        # bitgen log file               (renamed %.bgn)
  
If only the xst or par output is wanted just use

    make <sys>.ngc
    make <sys>.ncd

Some tools require a `.svf` rather than a `.bit` file. It can be created with

    make <sys>.svf

A simple _message filter_ system is also integrated into the make build flow.
For many (though not all) systems a `.mfset` file has been provided which
defines the `xst`, `par`, and `bitgen` messages which are considered ok. To see
only the remaining message extracted from the various `.log` files simply
use the make target

    make <sys>.mfsum

after a re-build.

### <a id="config-make">Configuring FPGAs (via make flow)</a>

The make flow supports also loading the bitstream into FPGAs, either
via Xilinx Impact, or via the Cypress FX2 USB controller is available.

For Xilinx Impact a Xilinx USB Cable II has to be properly setup, than
simply use

    make <sys>.iconfig

For using the Cypress FX2 USB controller on Digilent Nexys2 and Nexys3
boards just connect the USB cable and

    make <sys>.jconfig

This will automatically check and optionally re-load the FX2 firmware
to a version matching the FPGA design, generate a .svf file from the
.bit file, and configure the FPGA. In case the bit file is out-of-date
the whole design will be re-implemented before.

### <a id="config-wrap">Configuring FPGAs (directly via `config_wrapper`)</a>

The make flow described above uses two scripts

    config_wrapper              # must be used with xtwi !
    fx2load_wrapper

which can be used directly for loading available bit or svf files into
the FPGA. For detailed documentation see the respective man pages.

### <a id="artix">Note on Artix-7 based designs</a>

The development for Nexys4 started in 2013 with ISE but moved to Vivado when
it matured 2014 (see
[blog](https://wfjm.github.io/blogs/w11/2015-02-01-vivado-and-nexys4.html)).
The make files for the ISE build flows have been kept for comparison are have
the name `Makefile.ise`.
So for some Nexys4 designs one can still start with a 

      make -f Makefile.ise  <target>
    or
      makeise <target>

an ISE based build. To be used for tool comparisons, the ISE generated bit 
files were never tested in an FPGA.
