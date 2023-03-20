# Guide to run operating system images on w11a systems

For general system setup see notes on
- [I/O emulation setup](w11a_io_emulation.md)
- [FPGA Board setup](w11a_board_connection.md)
- [Rlink and Backend Server setup](w11a_backend_setup.md)
- [SimH simulator setup](w11a_simh_setup.md)
- [E11 simulator setup](w11a_e11_setup.md)

Ready to be used 'oskits' are provided under
[tools/oskit](../tools/oskit/README.md).
Tarballs with the disk images are provided from a web server and have to
be installed separately, see instructions in the respective READMEs.

The typical startup procedure starts some `vt100` emulator windows with the
`console_starter` and executes the backend server like
```bash
    cd $RETROBASE/tools/oskit/<oskit-name>
    console_starter -d DL0 &
    console_starter -d DL1 &
    ti_w11 <opt>  @<oskit-name>_boot.tcl
```
with the options `<opt>` as described in
[Rlink and Backend Server setup](w11a_backend_setup.md).

### <a id="oskits-unix">Unix systems</a>

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
| [u5ed_rk](../tools/oskit/u5ed_rk) | Unix 5th Ed. System  | RK05 | |
| [u7ed_rp](../tools/oskit/u7ed_rp) | Unix 7th Ed. System  | RP04 | _very preliminary, port to w11a in progress_|
| [211bsd_rk](../tools/oskit/211bsd_rk)  | 2.11BSD system  | RK05 | _very elementary subset_ |
| [211bsd_rl](../tools/oskit/211bsd_rl)  | 2.11BSD system  | RL02 | _small subset_ |
| [211bsd_rp](../tools/oskit/211bsd_rp)  | 2.11BSD system  | RP06 | _full system_ |
| [211bsd_rpmin](../tools/oskit/211bsd_rpmin)  | 2.11BSD system  | RP06 | _full system; tuned for small memory (min 512 kB, better 640 kB)_ |
| [211bsd_rpeth](../tools/oskit/211bsd_rpeth)  | 2.11BSD system  | RP06 | _full system; with DEUNA Ethernet_ |

For further details consult the [README.md](../tools/oskit/README.md) file
in the oskit directory.

### <a id="oskits-dec">DEC operating systems</a>

#### Legal and license issues

Unfortunately, there is no general hobbyist license for DEC operating 
systems for PDP-11 computers. The 'Mentec license' is commonly understood 
to cover some older versions of DEC operating systems, for example

- RT-11 V5.3 or prior
- RSX-11M V4.3 or prior
- RSX-11M PLUS V3.0 or prior

on a simulator. It is commonly assumed that the license terms cover the
usage of the PDP11 simulator from the 'SimH' suite. Usage of the E11
simulator is not covered according to the author of E11.

>  **THIS LICENSE DOES NOT COVER THE USAGE OF THESE HISTORIC DEC**  
>  **OPERATING SYSTEMS ON ANY 'REAL HARDWARE' IMPLEMENTATION OF A**  
>  **PDP-11. SO USAGE ON THE W11 IS *NOT* COVERED BY THE 'Mentec-license'.**

Some oskits are provided with systems sysgen'ed to run on a configuration 
like the w11a.

- Feel free to explore them with the SimH simulator.
  The boot scripts for SimH are included ( `<kit>.simh` )
   
- In case you happen to have a valid license feel free to try them
  out the w11a and let the author know whether is works as it should.
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

For further details consult the [README.md](../tools/oskit/README.md)
file in the oskit directory.
