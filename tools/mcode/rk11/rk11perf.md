# Performance tester for RK11
The `rk11perf.tcl` script measures the performance of RK11 `read` and `write`
transfer requests. It tests transfer sizes of 1, 2, 4, 8, 12, 16, 24, and
32 disk blocks of 512 bytes.. To study backpressure due to CPU activities, four
different CPU run modes are tested:
```
   0   CPU executes a WAIT instruction
   1   CPU executes `inc r1` (just 2 cycles per instruction)
   2   CPU executes `ashc @v,r2` with v=31. (the currently slowest instruction)
   3   CPU copies data with maximal cache contention
```
The scripts prints a table with test results, typical results are given below.

For a test of the bare rlink speed see [dmaperf](../rlink/dmaperf.md).
When comparing, note that an RK11 `read` request causes a memory write
via a `wblk` and a RK11 `write` request causes a memory read via an `rblk`.

### Start on w11
See general notes on
- [FPGA Board setup](../../../doc/w11a_board_connection.md)
- [Rlink and Backend Server setup](../../../doc/w11a_backend_setup.md)

To run the `noboot` code use
```bash
    ti_w11 <opt> -b @rk11perf_run.tcl
```
with the options `<opt>` as described in
[Rlink and Backend Server setup](../../../doc/w11a_backend_setup.md).

### Typical results
#### FT2232HQ based board
The FT2232HQ based serial interface on newer Digilent boards provides a
serial link speed of 12 MBit/s. `rk11perf.tcl` gives on a Basys3 board
(data taken 2023-02-06):
```
       code=   'wait'       'inc r1'     'ashc ...'     'mov ...'
      nblk   req/s  KB/s   req/s  KB/s   req/s  KB/s   req/s  KB/s
  read
         1     497   249     497   249     496   248     498   249
         2     333   333     332   332     332   332     332   332
         4     248   497     249   498     249   498     249   498
         6     200   600     199   598     197   590     199   597
         8     166   663     166   662     142   566     165   662
        12     125   749     124   746     100   598     124   744
        16      90   723      90   722      77   612      90   718
        24      67   798      66   797      53   630      66   792
        32      50   794      50   798      42   665      50   793
  write
         1     497   249     498   249     498   249     499   249
         2     348   348     357   357     357   357     370   370
         4     331   663     333   665     331   661     330   661
         6     249   747     249   748     250   749     250   749
         8     167   666     166   665     167   666     166   665
        12     125   749     124   747     125   748     125   748
        16      92   739      93   742      94   754      92   735
        24      66   798      66   798      66   798      66   797
        32      52   839      52   838      52   838      52   838
```
For small transfer sizes the throughput is limited by the link command latency
while for larger transfer sizes the throughput approaches the link speed.
Some Backpressure from CPU activities is seen for the `ashc @v,r2` case
for read requests.

#### Cypress FX2 based board
The Cypress FX2 based interface on Digilent Nexys 2 and Nexys 3 boards provides
a link speed and a command latency only limited by USB2 properties.
`rk11perf.tcl` gives on a Nexys 2 board (data taken 2015-01-03 with a fixed
chunksize of 1792):
```
       code=   'wait'       'inc r1'     'ashc ...'     'mov ...'
      nblk   req/s  KB/s   req/s  KB/s   req/s  KB/s   req/s  KB/s
  read
         1    1987   994    1986   993    1566   783    1946   973
         2    1972  1972    1959  1959    1303  1303    1592  1592
         4    1595  3189    1582  3164     878  1756    1137  2274
         6    1327  3981    1328  3984     665  1995     986  2959
         8     992  3969     891  3563     489  1957     710  2840
        12     883  5298     727  4365     358  2145     538  3228
        16     664  5310     590  4721     281  2245     399  3194
        24     471  5656     411  4931     190  2276     275  3296
        32     378  6044     335  5365     147  2354     212  3388
  write
         1    2614  1307    2607  1303    1597   799    1992   996
         2    1990  1990    1992  1992    1323  1323    1594  1594
         4    1987  3974    1971  3942     993  1986    1288  2576
         6    1561  4682    1570  4710     717  2151     998  2994
         8    1135  4539    1137  4547     531  2123     738  2952
        12     990  5940     988  5928     398  2389     586  3517
        16     795  6358     795  6359     307  2454     450  3604
        24     495  5934     467  5606     195  2335     306  3676
        32     376  6014     330  5276     142  2273     237  3788
```
With such an inherently fast connection, the backpressure due to CPU
activities is clearly visible.
