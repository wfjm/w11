# Dummy boot block

The `noboot` code simply prints the message
```
++======================================++
|| This is not a hardware bootable disk ||
++======================================++

CPU WILL HALT
```
and halts the CPU. The entry point is 0 and can therefore be started
with a `clr pc` as is done on boot PROMs. Code like this is used as a dummy
boot block in non-bootable disk volumes. The `lda` file is also useful in
PC11 loader tests.

### Start on w11
See general notes on
- [FPGA Board setup](../../../doc/w11a_board_connection.md)
- [Rlink and Backend Server setup](../../../doc/w11a_backend_setup.md)

To run the `noboot` code use
```bash
    ti_w11 <opt> -w -e noboot.mac
```
with the options `<opt>` as described in
[Rlink and Backend Server setup](../../../doc/w11a_backend_setup.md).
