## Notes on oskit: RT-11 V4.0 system on RK05 volumes

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
http://www.retro11.de/data/oc_w11/oskits/rt11-40_rkset.tgz

Download, unpack and copy the disk images (*.dsk), e.g.
```bash
       cd $RETROBASE/tools/oskit/rt11-40_rk
       rt11-40_rk_setup
```

### Usage

- Start disk imge in SimH simulator (see section SimH in
  [w11a_os_guide](../../../doc/w11a_os_guide.md#user-content-simh))
  ```
       pdp11 rt11-40_rk_boot.scmd
  ```

  or **ONLY IF YOU HAVE A VALID LICENSE** on w11a (see section Rlink in
  [w11a_os_guide](../../../doc/w11a_os_guide.md#user-content-rlink))
  ```
       ti_w11 <opt> @rt11-40_rk_boot.tcl
  ```

  where `<opt>` is the proper option set for the board.

- Hit `<ENTER>` in the xterm window to connect to SimH or backend server.
  The boot dialog in the console `xterm` window will look like
  (required input is in `{..}`, with `{<CR>}` denoting a carriage return:
  ```
       RT-11SJ  V04.00C 
       
       .D 56=5015
       
       .TYPE V4USER.TXT
       Welcome to RT-11 Version 4. RT-11 V04 provides new hardware support
       and some major enhancements over Version 3B.
       
       Please use the HELP command;  it describes the new options in many
       of the utilities.
       
       If you are using a terminal that requires fill characters,
       modify location 56 with a Deposit command before proceeding with
       system installation. LA36 DECwriter II and VT52 DECscope terminals
       do NOT require such modification.
       
       .D 56=0
       
       .
  ```

  Now you are at the RT-11 prompt and can exercise the system.

  There is no `halt` or `shutdown` command, just terminate the 
  simulator or backend server session.
