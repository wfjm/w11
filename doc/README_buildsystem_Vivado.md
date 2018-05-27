## Guide to the Build System (Xilinx Vivado Version)

###  Table of content

- [Concept](#user-content-concept)
- [Setup system environment](#user-content-sysenv)
  - [Setup environment variables](#user-content-envvar)
  - [Compile UNISIM/UNIMACRO libraries for ghdl](#user-content-ghdllibs)
- [Building test benches](#user-content-buildtb)
  - [With ghdl](#user-content-buildtb-ghdl)
  - [With Vivado xsim](#user-content-buildtb-xsim)
- [Building FPGA bit files](#user-content-buildfpga)
- [Building vivado projects, creating models](#user-content-buildviv)
- [Configuring FPGAs (via make flow)](#user-content-config-fpga)
- [Note on ISE](#user-content-ise)

### <a id="concept">Concept</a>

This projects uses GNU `make` to
- generate bit files     (with Vivado synthesis)
- generate test benches  (with ghdl or Vivado XSim)
- configure the FPGA     (with Vivado hardware server)

The Makefile's in general contain only a few definitions. By far most of 
the build flow logic in Vivado is in tcl scripts, only a thin interface
layer is needed at the make level, which is concentrated in a few master 
makefiles which are included.  

Simulation and synthesis tools usually need a list of the VHDL source
files, sometimes in proper compilation order (libraries before components).
The different tools have different formats of these 'project descriptions.

The build system employed in this project is based on manifest files called

     'vbom' or "VHDL bill of material" files

which list for each vhdl source file the libraries and sources for the
instantiated components, the later via their vbom, and last but not least
the name of the vhdl source file. 

All file name are relative to the current directory. A recursive traversal 
through all vbom's gives for each vhld module all sources needed to compile
it. The `vbomconv` script in `tools/bin` does this, and generates depending on 
options
- make dependency files
- Vivado synthesis setup files
- Vivado simulation setup files
- ghdl commands for analysis, inspection and make step

The master make files contain pattern rules like

    %.bit  : %.vbom           -- create bit file
    %      : %.vbom           -- build functional model test bench

which encapsulate all the `vbomconv` magic

A full w11a system is build from about 100 source files, test benches 
from even more. Using the vbom's a large number of designs can be easily 
maintained.

For more details on `vbomconv` consult the man page.

### <a id="sysenv">Setup system environment</a>

#### <a id="envvar">Setup environment variables</a>

The build flows require the environment variables:
- `RETROBASE`:  must refer to the installation root directory
- `XTWV_PATH`:  install path of the Vivado version

For general instructions on environment see [INSTALL.md](INSTALL.md).

Notes:  
- The build system uses a small wrapper script called xtwv to encapsulate
  the Xilinx environment. It uses `XTWV_PATH` to setup the Vivado environment 
  on the fly. For details consult 'man xtwv'. 
- don't run the Vivado setup scripts ..../settings(32|64).sh in your working 
  shell. Setup only XTWV_PATH !
  
#### <a id="ghdllibs">Compile UNISIM/UNIMACRO libraries for ghdl</a>

A few entities use `UNISIM` or `UNIMACRO` primitives, and post synthesis models 
require also `UNISIM` primitives. In these cases ghdl has to link against a 
compiled `UNISIM` or `UNIMACRO` libraries.

To make handling of the parallel installation of several Vivado versions
easy the compiled libraries are stored in sub-directories under `$XTWV_PATH`:

     $XTWV_PATH/ghdl/unisim
     $XTWV_PATH/ghdl/unimacro

A helper scripts will create these libraries:

     cd $RETROBASE
     xviv_ghdl_unisim            # does UNISIM and UNIMACRO

Run these scripts for each Vivado version which is installed.

Notes:
- Vivado supports `SIMPRIM` libraries only in Verilog form, there is no vhdl
  version anymore.
- ghdl can therefore not be used to do timing simulations with Vivado.
  However: under ISE `SIMPRIM` was available in vhdl, but ghdl did never 
  accept the sdf files, making ghdl timing simulations impossible under ISE too.

### <a id="buildtb">Building test benches</a>

The build flows currently supports ghdl and the vivado simulator xsim.

#### <a id="buildtb-ghdl">With ghdl</a>

To compile a ghdl based test bench named `<tbench>` all is needed is

    make <tbench>

The make file will use `<tbench>.vbom`, create all make dependency files,
and generate the needed ghdl commands.

In some cases the test benches can also be compiled against the gate
level models derived after the synthesis or optimize step. 
Vivado only generated functional (`UNISIM` based) models in vhdl. Timing
(`SIMPRIM` based) models are only available on verilog. The combination
vivado + ghdl is therefore limited to functional model simulation.

To compile them

    make ghdl_tmp_clean
    make <tbench>_ssim                  # for post synthesis functional
    make <tbench>_osim                  # for post optimize  functional
    make <tbench>_rsim                  # for post routing   functional

Individual working directories are used for the different models

    ghdl.bsim        for bahavioral model
    ghdl.ssim        for post synthesis
    ghdl.osim        for post optimize
    ghdl.rsim        for post routing

and can co-exist. The `make ghdl_tmp_clean` can be used to flush the ghdl
work areas, but in general this is not needed (since V0.73).

Notes:
- Many post-synthesis functional currently fail due to startup and 
  initialization problems (see issue V0.73-2).

#### <a id="buildtb-xsim">With Vivado xsim</a>

To compile a Vivado xsim based test bench named <tbench> all is needed is

    make <tbench>_XSim

The make file will use `<tbench>.vbom`, create all make dependency files,
and generate the needed Vivado xsim project files and commands.

In many cases the test benches can also be compiled against the gate
level models derived after the synthesis, optimize or routing step.
Vivado supports functional (`UNISIM` based) models in vhdl and in verilog,
and timing (`SIMPRIM` based) models only in verilog. Since practice showed
that verilog models compile and execute faster, verilog is used for both 
functional and timing models.

    make <tbench>_XSim_ssim             # for post-synthesis functional
    make <tbench>_XSim_osim             # for post-optimize  functional
    make <tbench>_XSim_rsim             # for post-routing   functional

    make <tbench>_XSim_esim             # for post-synthesis timing
    make <tbench>_XSim_psim             # for post-optimize  timing
    make <tbench>_XSim_tsim             # for post-routing   timing

Notes:
- as of vivado 2016.2 `xelab` shows sometimes extremely long build times, 
  especially for generated post-synthesis vhdl models (see issue V0.73-1).
- Many post-synthesis functional and especially post-routing timing 
  simulations currently fail due to startup and initialization problems
  (see issue V0.73-2).
 
### <a id="buildfpga">Building FPGA bit files</a>

To generate a bit file for a system named `<sys>` all is needed is

    make <sys>.bit

The make file will use `<sys>.vbom`, create all make dependency files and 
starts Vivado in batch mode with the proper scripts which will handle the
build steps. The log files and reports are conveniently renamed

    <sys>_syn.log            # synthesis log                 (from runme.log)
    <sys>_imp.log            # implementation log            (from runme.log)
    <sys>_bit.log            # write_bitstream log           (from runme.log)

    <sys>_syn_util.rpt       # (from <sys>_utilization_synth.rpt)
    <sys>_opt_drc.rpt        # (from <sys>_opt_drc.rpt)
    <sys>_pla_io.rpt         # (from <sys>_io_placed.rpt)
    <sys>_pla_clk.rpt        # (from <sys>_clock_utilization_placed.rpt)
    <sys>_pla_util.rpt       # (from <sys>_utilization_placed.rpt)
    <sys>_pla_cset.rpt       # (from <sys>_control_sets_placed.rpt)
    <sys>_rou_sta.rpt        # (from <sys>_route_status.rpt)
    <sys>_rou_drc.rpt        # (from <sys>_drc_routed.rpt)
    <sys>_rou_tim.rpt        # (from <sys>_timing_summary_routed.rpt)
    <sys>_rou_pwr.rpt        # (from <sys>_power_routed.rpt)
    <sys>_rou_util.rpt       # (extra report_utilization)
    <sys>_rou_util_h.rpt     # (extra report_utilization -hierarchical)
    <sys>_ds.rpt             # (extra report_datasheet)

The design check points are also kept

    <sys>_syn.dcp            # (from <sys>.dcp)
    <sys>_opt.dcp            # (from <sys>_opt.dcp)
    <sys>_pla.dcp            # (from <sys>_placed.dcp)
    <sys>_rou.dcp            # (from <sys>_routed.dcp)
  
If only the post synthesis, optimize or route design checkpoints are wanted

    make <sys>_syn.dcp
    make <sys>_opt.dcp
    make <sys>_rou.dcp

### <a id="buildviv">Building vivado projects, creating gate level models</a>

Vivado is used in 'project mode', whenever one of the targets mentioned
above is build a vivado project is freshly created in the directory

    project_mflow

with the project file

    project_mflow/project_mflow.xpr

There are many make targets which
- just create the project
- start vivado in gui mode to inspect the most recent project
- create gate level models

Specifically

    make <sys>.vivado          # create vivado project from <sys>.vbom
    make vivado                # open project in project_mflow
    
    make <sys>_ssim.vhd        # post-synthesis functional model (vhdl)
    make <sys>_osim.vhd        # post-optimize  functional model (vhdl)
    make <sys>_rsim.vhd        # post-routing   functional model (vhdl)

    make <sys>_ssim.v          # post-synthesis functional model (verilog)
    make <sys>_osim.v          # post-optimize  functional model (verilog)
    make <sys>_rsim.v          # post-routing   functional model (verilog)

    make <sys>_esim.v          # post-synthesis timing model (verilog)
    make <sys>_psim.v          # post-optimize  timing model (verilog)
    make <sys>_tsim.v          # post-routing   timing model (verilog)

For timing model verilog file an associated sdf file is also generated.

### <a id="config-fpga">Configuring FPGAs</a>

The make flow supports also loading the bitstream into FPGAs via the
Vivado hardware server. Simply use

    make <sys>.vconfig

Note: works with Arty, Basys3, and Nexys4, only one board must connected.

### <a id="ise">Note on ISE</a>

The development for Nexys4 started with ISE, but has now fully moved to
Vivado. The make files for the ISE build flows have been kept for comparison
are have the name `Makefile.ise`. So for some Nexys4 designs and associated
one can still start with a 

      make -f Makefile.ise  <target>
    or
      makeise <target>

an ISE based build. To be used for tool comparisons, the ISE generated bit 
files were never tested in an FPGA.
