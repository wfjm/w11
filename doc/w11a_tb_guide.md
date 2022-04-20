# Guide to running test benches

### Table of content

- [Tests bench environment](#user-content-env)
- [Unit test benches](#user-content-tb-unit)
- [System test benches](#user-content-tb-sys)
- [Test bench driver](#user-content-tb-driver)
- [Execute all available tests](#user-content-tb-exec)
- [Available unit test benches](#user-content-list-tb-unit)
- [Available system test benches](#user-content-list-tb-sys)

### General Notes
- GHDL is used for all behavioral simulations
- Optionally Vivado xsim can be used
- For post-synthesis or post-implementation functional simulations 
  either GHDL or Vivado xsim can be used.
- For timing simulations, only Vivado xsim can be used.
- ISE isim is also available, but considered legacy support

### <a id="env">Tests bench environment</a>

All test benches have the same simple structure:

- the test benches are 'self-checking'. For unit tests, a stimulus process 
  reads test patterns as well as the expected responses from a stimulus file

- the responses are checked in very simple cases by the stimulus process,
  in general by a monitoring process

- the test bench produces a comprehensive log file. For each checked
  response, the line contains the word "CHECK" and either an "OK" or a
  "FAIL", in the latter case in general with an indication of what's wrong.
  Other unexpected behavior, like timeouts, will also result in a line
  containing the word "FAIL".

- at the end a line with the word "DONE" is printed.

- Most tests can be run as

  | Name | Model Type | Sub Type |
  | :--- | :--------- | :------- |
  | bsim | behavioral model  | |
  | ssim | post-synthesis    | functional |
  | osim | post-optimization | functional |
  | rsim | post-routing      | functional |
  | esim | post-synthesis    | timing |
  | psim | post-optimization | timing |
  | tsim | post-routing      | timing |

  Building the simulation models is handled by the build environment. See 
  [README_buildsystem_Vivado.md](README_buildsystem_Vivado.md) for details
  of the Vivado flow and 
  [README_buildsystem_ISE.md](README_buildsystem_ISE.md) for the ISE flow.

### <a id="tb-unit">Unit test benches</a>

All unit test are executed via `tbw` (test bench wrapper) script.

- the test bench is run like

         tbw <testbenchname> [stimfile] | tbfilt --tee <logfile>

   where 
   - tbw sets up the environment of the test bench and starts it.
     It generates required symbolic links, e.g. to the stimulus file,
     the defaults extracted from the file tbw.dat, if an optional file
     name is given this one will be used instead.
   - tbfilt saves the full test bench output to a logfile and filters
     the output for PASS/FAIL criteria

- for convenience, a wrapper script `tbrun_tbw` is used to generate the 
  tbw|tbfilt pipe. This script also checks with `make` whether the
  test bench is up-to-date or must be (re)-compiled.

### <a id="tb-sys">System test benches</a>

The system tests allow verification of a full system design.
In this case, VHDL test bench code contains
- (simple) models of the memories used on the FPGA boards
- drivers for the rlink connection (currently just serial port)
- code to interface the rlink data stream to a UNIX 'named pipe',
  implemented with a C routine which is called via VHPI from VHDL.

This way the whole GHDL simulation can be controlled via a bi-directional
byte stream. 

The rlink backend process can connect either via a named pipe to a GHDL 
simulation, or via a serial port to an FPGA board. This way the same tests 
can be executed in simulation and on real hardware.

In general, the script `tbrun_tbwrri` is used to generate the quite lengthy 
command to properly set up the tbw|tbfilt pipe.  This script also checks 
with `make` whether the test bench is up-to-date or must be (re)-compiled.

### <a id="tb-driver">Test bench driver</a>

All available tests (unit and system test benches) are described in a
set of descriptor files, usually called `tbrun.yml`. The top-level file
in `$RETROBASE` includes other descriptor files located in the source 
directories of the tests.

The script `tbrun` reads these descriptor files, selects tests based
on `--tag` and `--exclude` options, and executes the tests with the
simulation engine and simulation type given by the `--mode` option.
For a full description see `man tbrun`.

The low-level drivers `tbrun_tbw` and `tbrun_tbwrri` will automatically 
build the model if it is not available or outdated. This is very convenient
when working with a single test bench during development.

When executing a large number of them it's in general better to separate
the model building (make phase) made model execution (run phase). Both
the low level drivers as well as `tbrun` support this via the options
`--nomake` and `--norun`.

The individual test benches are simplest started via tbrun and a proper
selection via `--tag`. Very helpful is

     cd $RETROBASE
     tbrun --dry --tag=.*

which gives a listing of all available tests. The tag list, as well as
the shell commands to execute the test, are shown.

### <a id="tb-exec">Execute all available tests</a>

As stated above it is in general better to separate the model building 
(make phase) made model execution (run phase). The currently recommended
way to execute all test benches is given below.
The run time is measured on a 3 GHz dual-core system.

     cd $RETROBASE
     # build all behavioral models
     #   first all with ISE work flow
     time nice tbrun -j 2 -norun -tag=ise -tee=tbrun_make_ise_bsim.log
       # --> real 3m41.732s   user 6m3.381s   sys 0m24.224s

     #   than all with Vivado work flow
     time nice tbrun -j 2 -norun -tag=viv -tee=tbrun_make_viv_bsim.log
       # --> real 3m36.532s   user 5m58.319s   sys 0m25.235s
     
     # than execute all behavioral models
     time nice tbrun -j 2 -nomake -tag=ise -tee=tbrun_run_ise_bsim.log
       # --> real 3m19.799s   user 5m45.060s   sys 0m6.625s
     time nice tbrun -j 2 -nomake -tag=viv -tee=tbrun_run_viv_bsim.log
       #--> real 3m49.193s   user 5m44.063s   sys 0m5.332s

All test create an individual logfile. `tbfilt` can be used to scan
these logfiles and create a summary with

     tbfilt -all -sum -comp
   
It should look like

     76m   0m00.034s c    0.92u   0 PASS tb_is61lv25616al_bsim.log
     76m   0m00.153s c    4.00u   0 PASS tb_mt45w8mw16b_bsim.log
     76m   0m00.168s c     1146   0 PASS tb_nx_cram_memctl_as_bsim.log
     ...
     ...
     76m   0m03.729s c    61258   0 PASS tb_pdp11core_bsim_base.log
     76m   0m00.083s c     1121   0 PASS tb_pdp11core_bsim_ubmap.log
     76m   0m00.068s c     1031   0 PASS tb_rlink_tba_pdp11core_bsim_ibdr.log

### <a id="list-tb-unit">Available unit test benches</a>

     tbrun --tag=comlib                    # comlib unit tests
     tbrun --tag=serport                   # serport unit tests
     tbrun --tag=rlink                     # rlink unit tests
     tbrun --tag=issi                      # SRAM model unit tests
     tbrun --tag=micron                    # CRAM model unit tests
     tbrun --tag=sram_memctl               # SRAM controller unit tests
     tbrun --tag=cram_memctl               # CRAM controller unit tests
     tbrun --tag=w11a                      # w11a unit tests

### <a id="list-tb-sys">Available system test benches</a>

     tbrun --tag=sys_tst_serloop.*         # all sys_tst_serloop designs
     tbrun --tag=sys_tst_rlink             # all sys_tst_rlink designs
     tbrun --tag=sys_tst_rlink_cuff        # all sys_tst_rlink_cuff designs
     tbrun --tag=sys_tst_sram              # all sys_tst_sram designs
     tbrun --tag=sys_w11a                  # all w11a designs
