## Notes on oskit: RSX-11M V3.1 system on RK05 volumes

### General remarks
See notes on
- [I/O emulation setup](../../../doc/w11a_io_emulation.md)
- [FPGA Board setup](../../../doc/w11a_board_connection.md)
- [Rlink and Backend Server setup](../../../doc/w11a_backend_setup.md)
- [SimH simulator setup](../../../doc/w11a_simh_setup.md)
- [e11 simulator setup](../../../doc/w11a_e11_setup.md)
- [Legal terms](../../../doc/w11a_os_guide.md)
- **and read [README_license.txt](README_license.txt) !!**

### Installation
A disk set is available from
http://www.retro11.de/data/oc_w11/oskits/rsx11m-31_rkset.tgz

Download, unpack and copy the disk images (*.dsk), e.g.
```bash
       cd $RETROBASE/tools/oskit/rsx11m-31_rk
       rsx11m-31_rk_setup
```

### Usage

- Start disk imge in SimH simulator (see section SimH in
  [w11a_os_guide](../../../doc/w11a_os_guide.md#user-content-simh))
  ```
      pdp11 rsx11m-31_rk_boot.scmd
  ```

  or **ONLY IF YOU HAVE A VALID LICENSE** on w11a (see section Rlink in
  [w11a_os_guide](../../../doc/w11a_os_guide.md#user-content-rlink))
  ```
       ti_w11 <opt> @rsx11m-31_rk_boot.tcl
  ```

  where `<opt>` is the proper option set for the board.

- Hit `<ENTER>` in the `xterm` window to connect to SimH or backend server.
  The boot dialog in the console `xterm` window will look like
  (required input is in `{..}`, with `{<CR>}` denoting a carriage return:
  ```
         RSX-11M V3.1 BL22   65408K MAPPED
       >RED DK0:=SY0:
       >RED DK0:=LB0:
       >MOU DK0:SYSTEM0
       >@[1,2]STARTUP
  ```

  That RSX shows `65408K` is a bug in V3.1. It should be `1920K` the
  size of accessible memory in words. For configurations with 1 MByte
  and below the correct value is displayed, above a wrong one.

  This os version was released in December 1977, so it's no suprise
  that it is not y2k ready. So enter a date before prior to 2000.
  ```  
       >* PLEASE ENTER TIME AND DATE (HR:MN DD-MMM-YY) [S]: {<.. see above ..>}
       >TIM 17:18 12-may-83
       >;
       >RUN ERRLOG
       >
       ;ERL -- ERROR LOG INITIALIZED
       >MOU DK1:SYSTEM1
       >;
       >INS DK1:[1,54]BIGMAC/PAR=GEN
       >INS DK1:[1,54]BIGTKB/PAR=GEN
       >INS DK1:[1,54]CDA
       >INS DK1:[1,54]DSC/PAR=GEN
       >INS DK1:[1,54]EDT/PAR=GEN
       >INS DK1:[1,54]FLX
       >INS DK1:[1,54]FOR
       >INS DK1:[1,54]FTB
       >INS DK1:[1,54]LBR
       >INS DK1:[1,54]PSE
       >INS DK1:[1,54]RNO
       >INS DK1:[1,54]SRD
       >INS DK1:[1,54]SYE
       >;
       >INS DK1:[1,54]TEC
       >INS DK1:[1,54]TEC/TASK=...MAK
       >INS DK1:[1,54]TEC/TASK=...MUN
       >;
       >INS DK1:[1,54]VTEC
       >;
       >;
       >SET /UIC=[1,6]
       >PSE =
       >SET /UIC=[200,200]
       >;
       >ACS DK1:/BLKS=512.
       >;
       >@ <EOF>
       >
  ```

  Now you are at the MCR prompt and can exercise the system.

  At the end is important to shutdown properly with a `run $shutup`.
  The simululaor (or the rlink backend) can be stopped when the
  CPU has halted.
