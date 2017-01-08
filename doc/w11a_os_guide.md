# Guide to run operating system images on w11a systems

### Table of content

- [I/O emulation setup](#user-content-io-emu)
- [FPGA Board setup](#user-content-fpga-setup)
- [Rlink and Backend Server setup](#user-content-rlink)
- [simh simulator setup](#user-content-simh)
- [oskits](#user-content-oskits)
  - [Unix systems](#user-content-oskits-unix)
  - [DEC operating systems](#user-content-oskits-dec)

### I/O emulation setup <a name="io-emu"></a>

All UNIBUS peripherals which exchange data (currently DL11, LP11, PC11, RK11,
RL11, RPRH and TM11 ) are currently emulated via a backend process. The 
communication between FPGA board and backend server can be via

- Serial port
  - via an integrated USB-UART bridge
    - on Arty, Basys3, and Nexys4 and Nexys4 DDR with a `FT2232HQ`, 
      allows up to 12M Baud
    - on nexys3 with a `FT232R`, allows up to 2M Baud
  - via RS232 port, as on s3board and nexys2
    - using a serial port (/dev/ttySx) is limited to 115 kBaud on most PCs.
    - using a USB-RS232 adapter was tested up to 460k Baud. 
   
- Direct USB connection using a Cypress FX2 USB controller
  - is supported on the nexys2 and nexys3 FPGA boards
  - much faster than serial port connections (see below)
  - also allows to configure the FPGA over the same USB connection

- Notes: 
  - A 12M Baud connection, like on a nexys4, gives disk access rates and 
    throughputs much better than the real hardware of the 70's and is well 
    suitable for practical usage.
  - In an OS with good disk caching like 2.11BSD the impact of disk speed
    is actually smaller than the bare numbers suggest.
  - A 460k Baud connection gives in practice a disk throughput of ~20 kB/s. 
    This allows to test the system but is a bit slow for real usage.
  - USB-RS232 cables with a FTDI `FT232R` chip work fine, tests with Prolific 
    Technology `PL2303` based cable never gave reliable connections for higher 
    Baud rates.

Recommended setup for best performance (boards ordered by vintage):

| Board      | Channel/Interface      | nom. speed   | peak transfer rate |
| :--------- | :--------------------- | :----------- | -----------------: |
| Arty       | USB-UART bridge        | 12M Baud     |  1090 kB/sec |
| Basys3     | USB-UART bridge        | 12M Baud     |  1090 kB/sec |
| Nexys4 DDR | USB-UART bridge        | 12M Baud     |  1090 kb/sec |
| Nexys4     | USB-UART bridge        | 12M Baud     |  1090 kb/sec |
| Nexys3     | Cypress FX2 USB        | USB2.0 speed | 30000 kB/sec |
| Nexys2     | Cypress FX2 USB        | USB2.0 speed | 30000 kB/sec |
| S3board    |  RS232+USB-RS232 cable | 460k Baud    |    41 kB/sec |
    
### FPGA Board setup <a name="fpga-setup"></a>

Recommended setups

- Arty
  - connect USB cable to micro-USB connector labeled 'J10'
  - to configure via vivado hardware server `make <sys>.vconfig`

- Basys3
  - connect USB cable to micro-USB connector labeled 'PROG'
  - to configure via vivado hardware server `make <sys>.vconfig`

- Nexys4 and Nexys4 DDR
  - connect USB cable to micro-USB connector labeled 'PROG'
  - to configure via vivado hardware server `make <sys>.vconfig`

- Nexys3
  - use Cypress FX for configure and and rlink communication
  - connect USB cable to micro-USB connector labeled 'USB PROG'
  - to configure via FX2 and jtag tool `make <sys>.jconfig`

- Nexys2
  - connect USB cable to mini-USB connector (between RS232 and PS/2 port)
  - to configure via FX2 and jtag tool `make <sys>.jconfig`

- S3board
  - connect the USB-RS232 cable to the RS232 port
  - connect a JTAG programmer (e.g. Xilinx USB Cable II) to JTAG pins
  - to configure via ISE Impact `make <sys>.iconfig`

### Rlink and Backend Server setup <a name="rlink"></a>

All examples below use the same basic setup

- setup `vt100` emulator windows

        cd $RETROBASE/tools/oskit/<oskit-name>
        console_starter -d DL0 &
        console_starter -d DL1 &

- setup rlink connection using `ti_rri` backend server via the `ti_w11` 
  quick start wrapper script. Ensure that all 8 switches on the board
  are in the indicated positions (SWI=...). The concrete boot script
  name is given in the following sections

  - for arty over serial

          SWI = 0110                (gives console light emulation...)
          ti_w11 -tuD,12M,break,xon  @<oskit-name>_boot.tcl

     **Note**: the arty w11a has currently only 176 kB memory (all from BRAMS!)
     unix-v5 works fine. XXDP, RT11 and RSX-11M should work.
     211bsd will not boot, either most RSX-11M+ systems.

  - for b3 over serial

          SWI = 00000000 00101000   (gives console light display on LEDS)
          ti_w11 -tuD,12M,break,xon  @<oskit-name>_boot.tcl


     **Note**: the basys3 w11a has only 176 kB memory (all from BRAMS!)
     unix-v5 works fine. XXDP, RT11 and RSX-11M should work.
     211bsd will not boot, either most RSX-11M+ systems.

  - for n4 or n4d over serial

          SWI = 00000000 00101000   (gives console light display on LEDS)
          ti_w11 -tuD,12M,break,cts  @<oskit-name>_boot.tcl

  - for n2,n3 over fx2

          SWI = 00101100
          ti_w11 -u @<oskit-name>_boot.tcl

  - for s3 serial

          SWI = 00101010
          ti_w11 -tu<dn>,460k,break,xon @<oskit-name>_boot.tcl
   
    Notes: 
    - the letter after `-tu` is either the serial device number,
      denoted as `<dn>`, or the letter `D` for auto-detection of
      Digilent boards with a FT2232HQ based interface.
      - for Arty, Basys3 and Nexys4 board simply use `D`
      - otherwise check with `ls /dev/ttyUSB*` to see what is available
      - `<dn>` is typically '1' if a single `FT2232HQ` based board is connected,
        like an Arty, Basys3, or Nexys4. Initially two ttyUSB devices show up, 
        the lower is for FPGA configuration and will disappear when the Vivado 
        hardware server is used once. The upper provides the data connection.
      - `<dn>` is typically '0' if only a single USB-RS232 cable is connected

     - on LED display
       - is controlled by SWI(3)

                0 -> system status
                1 -> DR emulation --> OS specific light patterns

     - on Hex display
       - is controlled by SWI(5:4)
       - boards with a 4 digit display

                00 -> serial link rate divider
                01 -> PC
                10 -> DISPREG
                11 -> DR emulation

       - boards with 8 digit display

                SWI(5) select for DSP(7:4) display
                    0 -> serial link rate divider
                    1 -> PC
                SWI(4) select for DSP(3:0) display
                    0 -> DISPREG
                    1 -> DR emulation

### simh simulator setup <a name="simh"></a>

Sometimes it is good to compare the w11a behavior with the PDP-11 software
emulator from the simh project (see http://simh.trailing-edge.com/).

Under `$RETROBASE/tools/simh` two setup files are provided with configure
simh to reflect the w11a setup as close as possible:
- `setup_w11a_min.scmd`  
  Very close the current w11a state when it runs on an s3board
  - processor: 11/70, no FPP, 1 Mbyte
  - periphery:   2 DL11, LP11, RK11, PC11
- `setup_w11a_max.scmd`  
  Planned configuration for the w11a, in addition
  - processor: 4 Mbyte memory (as on Nexys2, Nexys3,...)
  - periphery: DZ11, RL11/RL02, RK70/RP06, TM11/TU10

Startup scripts are provided with each oskit. They call the w11a_max
configuration, so will show in the emulator what w11a can do when
finished.

All examples below use the same basic setup
- setup vt100 emulator window for 2nd DL11

         cd $RETROBASE/tools/oskit/<oskit-name>
         console_starter -s -d DL1 &

   **Note**: the -s ensures that the port numbers used by simh are taken!

- start the simulator

         pdp11 <oskit-name>_boot.scmd

###oskits <a name="oskits"></a>

Ready to be used 'oskits' are provided under

     $RETROBASE/tools/oskit/<oskit-name>

The tarballs with the disk images are provided from a web server
and have to be installed separately.

###Unix systems <a name="oskits-unix"></a>

#### Legal and license issues

Ancient UNIX systems for the PDP-11 can now be freely used under the
'Caldera license'. 2.11BSD was released 1992 under the 4 clause BSD 
license. Taken together

- Unix V1 to V7
- all BSD Unix versions for PDP-11

can be freely distributed and used for non-commercial purposes.   

Several oskits are provided:

| oskit Name  |  OS  | Disk/Tape| Comment |
| :---- | :----| :------  | :------ |
| [unix-v5_rk](../tools/oskit/unix-v5_rk) | Unix V5 System  | RK05 | |
| [211bsd_rk](../tools/oskit/211bsd_rk)  | 2.11BSD system  | RK05 | _very elementary subset_ |
| [211bsd_rl](../tools/oskit/211bsd_rl)  | 2.11BSD system  | RL02 | _small subset_ |
| [211bsd_rp](../tools/oskit/211bsd_rp)  | 2.11BSD system  | RP06 | _full system_ |

For further details consult the `README.md` file in the oskit directory.

### DEC operating systems <a name="oskits-dec"></a>

#### Legal and license issues

Unfortunately there is no general hobbyist license for DEC operating 
systems for PDP-11 computers. The 'Mentec license' is commonly understood 
to cover the some older versions of DEC operating systems, for example

- RT-11 V5.3 or prior
- RSX-11M V4.3 or prior
- RSX-11M PLUS V3.0 or prior

on a simulator. It is commonly assumed that the license terms cover the
usage of the PDP11 simulator from the 'simh' suite. Usage of the e11
simulator is not covered according to the author of e11.

>  **THIS LICENSE DOES NOT COVER THE USAGE OF THESE HISTORIC DEC**  
>  **OPERATING SYSTEMS ON ANY 'REAL HARDWARE' IMPLEMENTATION OF A**  
>  **PDP-11. SO USAGE ON THE W11 IS *NOT* COVERED BY THE 'Mentec-license'.**

Some oskits are provided with systems sysgen'ed to run on a configuration 
like the w11a.

- Feel free to explore them with the simh simulator.
  The boot scripts for simh are included ( `<kit>.simh` )
   
- In case you happen to have a valid license feel free to try them
  out the W11A and let the author know whether is works as it should.
  For convenience the boot scripts are also included ( `<kit>.tcl` ).

Several oskits are provided:

| oskit Name  |  OS  | Disk/Tape| Comment |
| :---- | :----| :------  | :------ |
| [rsx11m-31_rk](../tools/oskit/rsx11m-31_rk)  | RSX-11M V3.1    | RK05 | |
| [rsx11m-40_rk](../tools/oskit/rsx11m-40_rk)  | RSX-11M V4.0    | RK05 | |
| [rsx11mp-30_rp](../tools/oskit/rsx11mp-30_rp) | RSX-11M+ V3.0   | RP06 | |
| [rt11-40_rk](../tools/oskit/rt11-40_rk)    | RT-11 V4.0      | RK05 | |
| [rt11-53_rl](../tools/oskit/rt11-53_rl)    | RT-11 V5.3      | RL02 | |
| [xxdp_rl](../tools/oskit/xxdp_rl)       | XXDP 22 and 25  | RL02 | |

For further details consult the `README.md` file in the oskit directory.
