# LP11 write tester

The `lp11write` code prints 1000 lines of the form
```
0000: ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz!@#$%^&*()
0001: ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz!@#$%^&*()
...
0999: ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz!@#$%^&*()
```

### Start on w11
See general notes on
- [FPGA Board setup](../../../doc/w11a_board_connection.md)
- [Rlink and Backend Server setup](../../../doc/w11a_backend_setup.md)

Start `lp11write` on an FPGA board with
```bash
ti_w11 <opt> -b @lp11write_run.tcl
```
with the options `<opt>` as described in
[Rlink and Backend Server setup](../../../doc/w11a_backend_setup.md).
The run will produce a file `w11_lp11write.dat`.

### Start on SimH
```bash
pdp11 lp11write.scmd
```
The run will produce a file `simh_lp11write.dat`.
