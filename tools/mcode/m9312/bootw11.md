# M9312: bootw11: interactive boot

The `bootw11` code is a proof-of-principle boot code for the w11.
Intended usage is the test of the M9312 emulation. It supports
- DK:  RK11/RK05 boot
- DL:  RL11/RL02 boot
- DB:  RH70/RP06 boot
- MT:  TM11 boot
- PR:  PC11 boot

### Start on w11
See general notes on
- [FPGA Board setup](../../../doc/w11a_board_connection.md)
- [Rlink and Backend Server setup](../../../doc/w11a_backend_setup.md)

First, connect to an FPGA board or in a GHDL simulation with
```bash
ti_w11 <opt>
```
Then load the `bootw11` code into the emulated M9312. Because software
sees the M9312 as a read-only memory area, the code can't be loaded with
the usual methods. Instead, a dedicated interface is used:
```
  package require ibd_m9312
  set start [ibd_m9312::load cpu0 "bootw11.mac"]
```
The code is started with
```
  cpu0 cp -stapc $start
```
and writes a `@` prompt to console. To test a boot device, first attach
a bootable disk or a `ram:` disk with dummy boot block, and then enter the
boot device name, with optional unit number and a `CR`. Like
```
  cpu0rka0 att "ram:dk0?noboot;pat=dead"
  < DK0
```
This uses the `<` command that injects tests into the console directly.
The dummy boot block will write a message to console and halt the CPU.
The code can be restarted, it's in an emulated PROM after all, for additional
tests.
