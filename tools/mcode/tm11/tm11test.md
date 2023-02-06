# TM11 tester

The `tm11test` code writes and reads back records and files on a TM11 tape unit.

### Start on w11
See general notes on
- [FPGA Board setup](../../../doc/w11a_board_connection.md)
- [Rlink and Backend Server setup](../../../doc/w11a_backend_setup.md)

Start `tm11test` on an FPGA board with
```bash
ti_w11 <opt> -b @tm11test_run.tcl
```
with the options `<opt>` as described in
[Rlink and Backend Server setup](../../../doc/w11a_backend_setup.md).
The run will produce a tape container file `w11_tm11test.tap`.
It can be inspected with the `tap2file` command
```bash
  tap2file -v w11_tm11test.tap
```
and give the output
```
   0,    0 :     80 : 00 00 00 00 50 00 06 07 08 09 0a 0b 0c 0d 0e 0f ...
   0,    1 :     80 : 00 00 01 00 50 00 06 07 08 09 0a 0b 0c 0d 0e 0f ...
   0,    2 :    160 : 00 00 02 00 a0 00 06 07 08 09 0a 0b 0c 0d 0e 0f ...
   0,    3 :    160 : 00 00 03 00 a0 00 06 07 08 09 0a 0b 0c 0d 0e 0f ...
   0,    4 : ---EOF---
w11_tm11test_00.dat:      4 records, length min=   80, max=  160
   1,    0 :     92 : 01 00 00 00 5c 00 06 07 08 09 0a 0b 0c 0d 0e 0f ...
   1,    1 :     92 : 01 00 01 00 5c 00 06 07 08 09 0a 0b 0c 0d 0e 0f ...
   1,    2 :     92 : 01 00 02 00 5c 00 06 07 08 09 0a 0b 0c 0d 0e 0f ...
   1,    3 :    100 : 01 00 03 00 64 00 06 07 08 09 0a 0b 0c 0d 0e 0f ...
   1,    4 :    110 : 01 00 04 00 6e 00 06 07 08 09 0a 0b 0c 0d 0e 0f ...
   1,    5 :    110 : 01 00 05 00 6e 00 06 07 08 09 0a 0b 0c 0d 0e 0f ...
   1,    6 :    120 : 01 00 06 00 78 00 06 07 08 09 0a 0b 0c 0d 0e 0f ...
   1,    7 :    120 : 01 00 07 00 78 00 06 07 08 09 0a 0b 0c 0d 0e 0f ...
   1,    8 : ---EOF---
w11_tm11test_01.dat:      8 records, length min=   92, max=  120
   2,    0 :    130 : 02 00 00 00 82 00 06 07 08 09 0a 0b 0c 0d 0e 0f ...
   2,    1 :    130 : 02 00 01 00 82 00 06 07 08 09 0a 0b 0c 0d 0e 0f ...
   2,    2 :    140 : 02 00 02 00 8c 00 06 07 08 09 0a 0b 0c 0d 0e 0f ...
   2,    3 :    140 : 02 00 03 00 8c 00 06 07 08 09 0a 0b 0c 0d 0e 0f ...
   2,    4 : ---EOF---
w11_tm11test_02.dat:      4 records, length min=  130, max=  140
   3,    0 : ---EOF---
   4,    0 : ---EOT---
```

### Start on SimH
```bash
pdp11 tm11write.scmd
```
The run will produce a tape container file `simh_tm11test.tap`.
It can be inspected with the `tap2file` command and should give the same
result as for the w11 run.
