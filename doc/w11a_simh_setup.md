# SimH simulator setup

Sometimes it is good to compare the w11a behavior with the PDP-11 software
emulator from the SimH project. See [INSTALL_simh](INSTALL_simh.md) for
installation instructions and supported versions.

Under [tools/simh](../tools/simh) two setup files are provided which
configure SimH to reflect the w11a setup as closely as possible:
- [setup_w11a_min.scmd](../tools/simh/setup_w11a_min.scmd)  
  Minimal configuration for low memory boards (as on s3board or Basys3)
  - processor: 11/70, no FPP, 1 Mbyte
  - periphery:   2 DL11, LP11, PC11, RK11/RK05
- [setup_w11a_max.scmd](../tools/simh/setup_w11a_max.scmd)  
  Full configuration for the w11a, in addition
  - processor: 4 Mbyte memory (as on Nexys and Arty type boards)
  - periphery: in addition DZ11, RL11/RL02, RM70/RP06, TM11/TU10, DEUNA

Startup scripts are provided with each oskit. They usually call the `w11a_max`
configuration and are used with
- set up VT100 emulator window for 1st and 2nd DL11 and DZ11 lines depending
  on the capabilities of the started system
  ```bash
      console_starter -s -d DL0 &
      console_starter -s -d DL1 &
      console_starter -s -d DZ0 &
      console_starter -s -d DZ1 &
  ```
   **Note**: the `-s` ensures that the port numbers used by SimH are taken!

- the simulator is usually started with an `.scmd` command file, for
  [oskits](../tools/oskit/README.md) for example with
  ```bash
      cd $RETROBASE/tools/oskit/<oskit-name>
      pdp11 <oskit-name>_boot.scmd
  ```
