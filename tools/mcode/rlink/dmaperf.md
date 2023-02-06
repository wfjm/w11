# Performance tester for rlink rblk/wblk
The `dmaperf.tcl` script measures the performance of rlink `rblk` and
`wblk` block transfer commands. It tests transfer sizes of 256, 512, 1024,
and 1536 words of 16 bit. To study backpressure due to CPU activities, five
different CPU run modes are tested:
```
  -1   CPU halted
   0   CPU executes a WAIT instruction
   1   CPU executes `inc r1` (just 2 cycles per instruction)
   2   CPU executes `ashc @v,r2` with v=31. (the currently slowest instruction)
   3   CPU copies data with maximal cache contention
```
The scripts prints a table with test results, typical results are given below.

### Start on w11
See general notes on
- [FPGA Board setup](../../../doc/w11a_board_connection.md)
- [Rlink and Backend Server setup](../../../doc/w11a_backend_setup.md)

To run the `noboot` code use
```bash
    ti_w11 <opt> -b @dmaperf_run.tcl
```
with the options `<opt>` as described in
[Rlink and Backend Server setup](../../../doc/w11a_backend_setup.md).

### Typical results
#### FT2232HQ based board
The FT2232HQ based serial interface on newer Digilent boards provides a
serial link speed of 12 MBit/s. `dmaperf.tcl` gives on a Basys3 board
(data taken 2023-02-06):
```
      bsize=     256           512          1024          1536 wrd
      code   blk/s  KB/s   blk/s  KB/s   blk/s  KB/s   blk/s  KB/s
  wblk
        -1     500   250     333   333     250   500     200   601
         0     499   250     333   333     249   498     200   599
         1     499   250     333   333     250   499     200   599
         2     497   249     333   333     250   499     179   538
         3     499   250     333   333     250   499     200   599
  rblk
        -1     499   249     334   334     273   547     250   751
         0     499   250     352   352     281   562     249   748
         1     498   249     350   350     295   590     249   748
         2     499   250     340   340     272   545     249   746
         3     499   250     335   335     279   558     250   749
```
For small transfer sizes the throughput is limited by the link command latency
while for larger transfer sizes the throughput approaches the link speed.
No backpressure from CPU activities is seen with one exception. The modest
reduction seen for `wblk` transfers with maximal size of 1536 words with
a CPU running an endless loop of `ashc @v,r2` is reproducible and most
likely a _lock-in effect_ caused by the highly regular pattern of this test.

#### Cypress FX2 based board
The Cypress FX2 based interface on Digilent Nexys 2 and Nexys 3 boards provides
a link speed and a command latency only limited by USB2 properties.
`dmaperf.tcl` gives on a Nexys 2 board (data taken 2014-12-27):
 ```
       bsize=     256           512          1024          1536 wrd
      code   blk/s  KB/s   blk/s  KB/s   blk/s  KB/s   blk/s  KB/s
  wblk
        -1    2653  1327    2614  2614    1924  3848    1574  4723
         0    2644  1322    2644  2644    1990  3980    1594  4782
         1    2653  1327    2653  2653    1980  3960    1604  4812
         2    2000  1000    1584  1584    1000  2000     725  2176
         3    2644  1322    1990  1990    1327  2653    1020  3059
  rblk
        -1    3921  1960    2653  2653    2653  5307    2614  7842
         0    3941  1970    2653  2653    2634  5267    1950  5851
         1    3832  1916    2624  2624    2624  5248    1990  5970
         2    1980   990    1594  1594    1149  2297     794  2382
         3    2594  1297    2208  2208    1495  2990    1238  3713
 ```
With such an inherently fast connection, the backpressure due to CPU
activities is clearly visible.
