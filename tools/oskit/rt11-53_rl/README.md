## Notes on oskit: RT-11 V5.3 system on a RL02 volume

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
http://www.retro11.de/data/oc_w11/oskits/rt11-53_rlset.tgz

Download, unpack and copy the disk images (*.dsk), e.g.
```bash
       cd $RETROBASE/tools/oskit/rt11-53_rl
       rt11-53_rl_setup
```

### Usage

- Start disk imge in SimH simulator (see section SimH in
  [w11a_os_guide](../../../doc/w11a_os_guide.md#user-content-simh))
  ```
       pdp11 rt11-53_rl_boot.scmd
  ```

  or **ONLY IF YOU HAVE A VALID LICENSE** on w11a (see section Rlink in
  [w11a_os_guide](../../../doc/w11a_os_guide.md#user-content-rlink))
  ```
       ti_w11 <opt> @rt11-53_rl_boot.tcl
  ```

  where `<opt>` is the proper option set for the board.

- Hit `<ENTER>` in the `xterm` window to connect to SimH or backend server.
     The boot dialog in the console `xterm` window will look like
     (required input is in `{..}`, with `{<CR>}` denoting a carriage return:
  ```

    RT-11FB  V05.03  

    .TYPE V5USER.TXT

                                  RT-11 V5.3

           Installation of RT-11 Version 5.3 is complete and you are now
        executing from the working volume    (provided you have used the
        automatic installation procedure). DIGITAL recommends you verify
        the correct  operation  of  your  system's  software  using  the
        verification procedure.  To do this, enter the command:

                                 IND VERIFY

            Note that VERIFY should be performed  only after the distri-
        bution media have been backed up.  This was accomplished as part
        of automatic installation on  all  RL02,  RX02,  TK50, and  RX50
        based systems,   including the  MicroPDP-11 and the Professional
        300.  If you have not completed automatic installation, you must
        perform a manual backup before using VERIFY.  Note also,  VERIFY
        is NOT supported on RX01 diskettes,    DECtape I or II,   or the
        Professional 325.

        DIGITAL also  recommends  you  read  the  file V5NOTE.TXT, which
        contains information  formalized too late to be included  in the
        Release Notes.  V5NOTE.TXT can be TYPED or PRINTED.
       
        .
  ```

  Now you are at the RT-11 prompt and can exercise the system.

  There is no `halt` or `shutdown` command, just terminate the 
  simulator or backend server session.
