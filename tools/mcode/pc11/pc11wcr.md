# PC11 write, copy and read tester

The `pc11write` code punches a file containing 1000 lines of the form
```
0000: ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz!@#$%^&*()
0001: ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz!@#$%^&*()
...
0999: ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz!@#$%^&*()
```

The `pc11copy` code reads a file of the format written by `pc11write`
and punches the read content.
The `pc11read` code reads a file of the format written by `pc11write`
and verifies the content.

### Start on w11
See general notes on
- [FPGA Board setup](../../../doc/w11a_board_connection.md)
- [Rlink and Backend Server setup](../../../doc/w11a_backend_setup.md)

Run the three codes in sequence with
```bash
ti_w11 <opt> -b @pc11write_run.tcl
ti_w11 <opt> -b @pc11copy_run.tcl
ti_w11 <opt> -b @pc11read_run.tcl
```
with the options `<opt>` as described in
[Rlink and Backend Server setup](../../../doc/w11a_backend_setup.md).
The first command will produce a file `w11_pc11write.dat`.
The second command reads that file and produce a file `w11_pc11copy.dat`.
The final command reads the file `w11_pc11copy.dat`.

### Start on SimH
```bash
pdp11 pc11write.scmd
pdp11 pc11copy.scmd
pdp11 pc11read.scmd
```
The logic is as decribed for w11, except the file names start with `simh_`.
