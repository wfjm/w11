## divtst: data collection

`divstst` has been run on real PDP-11 CPUs as well as on simulated CPUs
with the [SimH](http://simh.trailing-edge.com/) and the
[e11](http://www.dbit.com/) simulator.
The results are available in

| Case      | sim | CPU | Comment |
| --------- | --- | --- | ------- |
| [2014-08-22_1170_btq](2014-08-22_1170_btq.log)    | real | 11/70 | from Johnny Billquist, node magica |
| [2014-08-22_1193_btq](2014-08-22_1170_btq.log)    | real | 11/93 (J11) | from Johnny Billquist, node pontus |
| [2014-08-22_e11_1174_btq](2014-08-22_e11_1174_btq.log)    | e11 | 11/74 | from Johnny Billquist, node mim |
| [2014-08-22_simh_1194_btq](2014-08-22_simh_1194_btq.log)  | SimH | 11/94 (J11) | from Johnny Billquist, node jocke |

The file name encodes the approximate date of data taking (relevant for
simulators which indeed change over time), the sim/CPU case, and the source
of data.

### Some findings
The N and Z condition codes and the registers are _unspecified_ after an
overflow abort of the `DIV` instruction. The only thing guaranteed is
that V=1 and C=0. The seen responses for the _unspecified_ parts
are indeed different, a good example is
```
   ddh    ddl     dr : nzvc      q      r  remarks
177777 100000 177777 : 0110 000000 100000  real 11/70: Z=1, R0MOD
177777 100000 177777 : 0010 177777 100000  real 11/93: r0,r1 unchanged
177777 100000 177777 : 0010 100000 000000  e11  11/74: R0MOD R1MOD
```
