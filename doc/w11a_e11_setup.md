# e11 simulator setup

The "Ersatz-11" or `e11` a PDP-11 software emulator available from
[www.dbit.com](http://www.dbit.com/). It is commercial project, closed
source, but can be used with some limitations free of charge for
non-commercial applications.

The device emulation concept of e11 is quite different compared to SimH.
The operation and behavior of the two emulators differs therefore
- the console DL11 is always connected to the session window for e11.
  It is not possible to connect it to a telnet session as done for SimH.
- it is not possible to set the 2nd DL11 into 7-bit mode
- device controllers are only activated when at least one unit is mounted.
  All disk and tape controllers have therefore a `NULL` mount point active
  for the highest supported unit.
- the Ethernet emulation in e11 is currently not supported, the DEUNA device
  is therefore not active.

Under [tools/e11](../tools/e11) two setup files are provided which
configure e11 to reflect the w11a setup as closely as possible:
- [setup_w11a_min.ecmd](../tools/e11/setup_w11a_min.ecmd)  
  Minimal configuration for low memory boards (as on s3board or Basys3)
  - processor: 11/70, no FPP, 1 Mbyte
  - periphery:   2 DL11, LP11, PC11, RK11/RK05
- [setup_w11a_max.ecmd](../tools/e11/setup_w11a_max.ecmd)  
  Full configuration for the w11a, in addition
  - processor: 4 Mbyte memory (as on Nexys and Arty type boards)
  - periphery: in addition DZ11, RL11/RL02, RM70/RP06, TM11/TU10

**Note**: tested with e11 V7.4, might not work with V7.3 and earlier.

Startup scripts are provided for some oskits. They usually call the `w11a_max`
configuration and are used with
- set up VT100 emulator window for 2nd DL11 and DZ11 lines depending on the
  capabilities of the started system
  ```bash
      console_starter -s -d DL1 &
      console_starter -s -d DZ0 &
      console_starter -s -d DZ1 &
  ```
   **Note**: the provided setup files use the same ports a SimH, thus `-s` used.

- the simulator is usually started with an `.ecmd` initialization file, for
  [oskits](../tools/oskit/README.md) for example with
  ```bash
      cd $RETROBASE/tools/oskit/<oskit-name>
      e11 /initfile:<oskit-name>_boot.ecmd
  ```
