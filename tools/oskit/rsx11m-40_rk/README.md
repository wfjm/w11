## Notes on oskit: RSX-11M V4.0 system on RK05 volumes
See notes on
- [I/O emulation setup](../../../doc/w11a_io_emulation.md)
- [FPGA Board setup](../../../doc/w11a_board_connection.md)
- [Rlink and Backend Server setup](../../../doc/w11a_backend_setup.md)
- [SimH simulator setup](../../../doc/w11a_simh_setup.md)
- [Legal terms](../../../doc/w11a_os_guide.md)
- **and read [README_license.txt](README_license.txt) !!**

### Installation
A disk set is available from
http://www.retro11.de/data/oc_w11/oskits/rsx11m-40_rkset.tgz

Download, unpack and copy the disk images (*.dsk), e.g.
```
       cd $RETROBASE/tools/oskit/rsx11m-40_rk
       rsx11m-40_rk_setup
```

### Usage

- Start disk imge in SimH simulator (see section SimH in
  [w11a_os_guide](../../../doc/w11a_os_guide.md#user-content-simh))
  ```
       pdp11 rsx11m-40_rk_boot.scmd
  ```

  or **ONLY IF YOU HAVE A VALID LICENSE** on w11a (see section Rlink in
  [w11a_os_guide](../../../doc/w11a_os_guide.md#user-content-rlink))
  ```
       ti_w11 <opt> @rsx11m-40_rk_boot.tcl
  ```

  where `<opt>` is the proper option set for the board.

- Hit `<ENTER>` in the `xterm` window to connect to SimH or backend server.
  The boot dialog in the console `xterm` window will look like
  (required input is in `{..}`, with `{<CR>}` denoting a carriage return:
  ```
         RSX-11M V4.0 BL32   1920.K MAPPED
       >RED DK:=SY:
       >RED DK:=LB:
       >MOU DK:SYSM40RKV0
       >@DK:[1,2]STARTUP
  ```

  This os version was released in November 1981, so it's no suprise
  that it is not y2k ready. So enter a date before prior to 2000.
  ```
       >* PLEASE ENTER TIME AND DATE (HR:MN DD-MMM-YY) [S]: {<.. see above ..>}
       >TIM 18:17 12-may-83
       >* ENTER LINE WIDTH OF THIS TERMINAL [D D:132.]: {<CR>}
       >SET /BUF=TI:132.
       >ACS SY:/BLKS=512.
       >CLI /INIT=DCL/TASK=...DCL
       >;
       >; mount 2nd system disk
       >;
       >mou dk1:SYSM40RKV1/pub
       >;
       >; installing tasks from 2nd system disk
       >;
       >INS DK1:$BRU
       >INS DK1:$DMP
       >INS DK1:$DSC
       >INS DK1:$EDT
       >INS DK1:$FLX
       >INS DK1:$K11RSX/TASK=...KER
       >INS DK1:$LBR
       >INS DK1:$MAC
       >INS DK1:$RMD
       >INS DK1:$SLP
       >INS DK1:$SRD
       >INS DK1:$TEC
       >INS DK1:$TEC/TASK=...MAK
       >INS DK1:$TKB
       >INS DK1:$VFY
       >INS DK1:$VTEC
       >@ <EOF>
       >
  ```

  Now you are at the MCR prompt and can exercise the system.

  You can also login on the 2nd DL11, possible accounts are
  ```
       >hel 1,1             ; password root
       >hel 200,201         ; password test
  ```

  At the end it is important to shutdown properly with a `run $shutup`.
  The simululaor (or the rlink backend) can be stopped when the
  CPU has halted.
