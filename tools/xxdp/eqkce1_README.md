# EQKCE1 - 11/70 CPU exerciser

### Documentation
- [DiagnosticsHandbook](http://www.bitsavers.org/pdf/dec/pdp11/xxdp/PDP11_DiagnosticHandbook_1988.pdf) p27
- [EQKCE1 source listing](http://www.bitsavers.org/pdf/dec/pdp11/microfiche/Diagnostic_Program_Listings/Listings/MD-11-DEQKC-B__PDP11-70__CPU_INSTRUCTION_EXERCISER__EP-DEQKC-B-DL-A__NOV_1976_bw.pdf)

### Usage
```
ti_w11 -c7 @eqkce1_run.tcl                      # w11 on GHDL, using cmoda7
ti_w11 -tuD,12M,break,xon @eqkce1_run.tcl       # w11 on FPGA, arty as example
pdp11 eqkce1_run.scmd                           # SimH simulator
e11 /initfile:eqkce1_run.ecmd                   # E11  simulator
```

### Expected output when no errors are reported
```
CEQKC-E...PDP 11/70 CPU EXERCISER

CPU UNDER TEST FOUND TO BE A KB11-B/C

PROCESSOR ID REGISTER =110234 (OCTAL)  -28516 (DECIMAL) 
OPT.CP=145406

**NOTE** SWITCH REG BIT 8 HAS BEEN REVERSED IN REV D
NOTE THAT SWR BIT 8 SET NOW ALLOWS I/O RELOCATION

THIS PROGRAM SUPPORTS I/O RELOCATION ONLY WITH THE FOLLOWING DEVICES:
RP03,RK05,RP04/5/6,RS03/4
1THE QUICK BROWN FOX JUMPED OVER THE LAZY DOGS BACK 0123456789
2THE QUICK BROWN FOX JUMPED OVER THE LAZY DOGS BACK 0123456789
3THE QUICK BROWN FOX JUMPED OVER THE LAZY DOGS BACK 0123456789
4THE QUICK BROWN FOX JUMPED OVER THE LAZY DOGS BACK 0123456789
5THE QUICK BROWN FOX JUMPED OVER THE LAZY DOGS BACK 0123456789
000:00:00

END PASS #     1  TOTAL ERRORS SINCE LAST REPORT      0
...
```

### w11 remarks
Runs without patches.

### SimH remarks (tested with V3.12-3 RC2)
Requires [patch](eqkce1_patch_1170.scmd).

### E11 remarks (tested with V7.4 ALPHA 03/21/23)
Runs without patches.
