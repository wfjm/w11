# Memory clear

The `memclr` code zero's all system memory, only locations 0 and 2 have
a non-zero content when the program halts. Can be used to set the memory
to a well-defined state.

### Start on w11
See general notes on
- [FPGA Board setup](../../../doc/w11a_board_connection.md)
- [Rlink and Backend Server setup](../../../doc/w11a_backend_setup.md)

To run the `memclr` code use
```bash
    ti_w11 <opt> -w -e memclr.mac
```
with the options `<opt>` as described in
[Rlink and Backend Server setup](../../../doc/w11a_backend_setup.md).
