## Notes on oskit: XXDP V2.2 and V2.5 system on RL02 volumes

### General remarks
See notes on
- [I/O emulation setup](../../../doc/w11a_io_emulation.md)
- [FPGA Board setup](../../../doc/w11a_board_connection.md)
- [Rlink and Backend Server setup](../../../doc/w11a_backend_setup.md)
- [SimH simulator setup](../../../doc/w11a_simh_setup.md)
- [e11 simulator setup](../../../doc/w11a_e11_setup.md)
- [Legal terms](../../../doc/w11a_os_guide.md)
- **and read [README_license.md](README_license.md) !!**

### Installation
A disk images for XXDP V2.2 and V2.5 are available from bitsavers  
http://bitsavers.trailing-edge.com/bits/DEC/pdp11/discimages/rl02
```
         xxdp22.rl02.gz
         xxdp25.rl02.gz
```

Download, unpack and copy the disk images (*.dsk), e.g.
```bash
       cd $RETROBASE/tools/oskit/xxdp_rl

       disk_path=http://bitsavers.trailing-edge.com/bits/DEC/pdp11/discimages
       wget $disk_path/rl02/xxdp22.rl02.gz
       wget $disk_path/rl02/xxdp25.rl02.gz

       gunzip -c xxdp22.rl02.gz > xxdp22.dsk
       gunzip -c xxdp25.rl02.gz > xxdp25.dsk
```

### Usage

- Start disk imge in SimH simulator (see section SimH in
  [w11a_os_guide](../../../doc/w11a_os_guide.md#user-content-simh))
  ```
       pdp11 xxdp22_rl_boot.scmd
       pdp11 xxdp25_rl_boot.scmd
  ```

  or on w11a (see section Rlink in
  [w11a_os_guide](../../../doc/w11a_os_guide.md#user-content-rlink))
  ```
       ti_w11 <opt> @xxdp22_rl_boot.tcl
       ti_w11 <opt> @xxdp25_rl_boot.tcl
  ```

  where `<opt>` is the proper option set for the board.

- Hit `<ENTER>` in the `xterm` window to connect to SimH or backend server.
  The boot dialog in the console `xterm` window will look like
  (required input is in `{..}`, with `{<CR>}` denoting a carriage return.
  ```
     XXDP V2.2 boot dialog:

       CHMDLD0 XXDP+ DL MONITOR
       BOOTED VIA UNIT 0
       28K UNIBUS SYSTEM

       ENTER DATE (DD-MMM-YY): {10-jan-85}

       RESTART ADDR: 152010
       THIS IS XXDP+.  TYPE "H" OR "H/L" FOR HELP.

       .
  ```

  XXDP V2.5 boot dialog:
  ```
       BOOTING UP XXDP-XM EXTENDED MONITOR

       XXDP-XM EXTENDED MONITOR - XXDP V2.5
       REVISION: F0
       BOOTED FROM DL0
       124KW OF MEMORY
       UNIBUS SYSTEM

       RESTART ADDRESS: 152000
       TYPE "H" FOR HELP !

       .

     Now you are at the XXDP prompt '.' and can exercise the system:
     
       . {H}
         --> will print help
       . {D}
         --> will list the files
       . {R EKBAD0}
         --> will run the 'PDP 11/70 cpu diagnostic part 1'
  ```

  There is no `halt` or `shutdown` command, just terminate the 
  simulator or backend server session.
