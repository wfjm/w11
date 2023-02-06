# SimH simulator setup

Sometimes it is good to compare the w11a behavior with the PDP-11 software
emulator from the SimH project. See [INSTALL_simh](INSTALL_simh.md) for
installation instructions and supported versions.

Under `$RETROBASE/tools/simh` two setup files are provided which configure
SimH to reflect the w11a setup as close as possible:
- `setup_w11a_min.scmd`  
  Very close to the current w11a state when it runs on an s3board
  - processor: 11/70, no FPP, 1 Mbyte
  - periphery:   2 DL11, LP11, RK11, PC11
- `setup_w11a_max.scmd`  
  Planned configuration for the w11a, in addition
  - processor: 4 Mbyte memory (as on Nexys2, Nexys3,...)
  - periphery: in addition DZ11, RL11/RL02, RK70/RP06, TM11/TU10

Startup scripts are provided with each oskit. They call the `w11a_max`
configuration, so will show in the emulator what w11a can do when
finished.

All examples below use the same basic setup
- set up vt100 emulator window for 1st and 2nd DL11
  ```bash
      console_starter -s -d DL0 &
      console_starter -s -d DL1 &
  ```
   **Note**: the `-s` ensures that the port numbers used by SimH are taken!

- the simulator is usually started with `.scmd` command file, for
  [oskits](../tools/oskit/README.md) for example with
  ```bash
      cd $RETROBASE/tools/oskit/<oskit-name>
      pdp11 <oskit-name>_boot.scmd
  ```
