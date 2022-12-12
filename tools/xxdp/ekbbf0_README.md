# EKBBF0 - 11/70 cpu diagnostic part 2

### Documentation
- [DiagnosticsHandbook](http://www.bitsavers.org/pdf/dec/pdp11/xxdp/PDP11_DiagnosticHandbook_1988.pdf) p19
- [EKBBF0 source listing](http://www.bitsavers.org/pdf/dec/pdp11/microfiche/Diagnostic_Program_Listings/Listings/CEKBBF0__PDP11-70__11-70_CPU_2__AH-7968F-MC__SEP_1980_bw.pdf)

### Usage
```
ti_w11 -c7 @ekbbf0_run.tcl                      # w11 on GHDL, using cmoda7
ti_w11 -tuD,12M,break,xon @ekbbf0_run.tcl       # w11 on FPGA, arty as example
pdp11 ekbbf0_run.scmd                           # SimH simulator
e11 /initfile:ekbbf0_run.ecmd                   # e11  simulator
```

### Expected output when no errors are reported
```
CEKBBF0 11/70 CPU #2
BR 4 TESTS DISABLED
BR 5 TESTS DISABLED
BR 6 TESTS DISABLED

CPU UNDER TEST FOUND TO BE A KB11-B/C OR KB11-CM                
OPR TEST DISABLED

END PASS #     1  TOTAL ERRORS SINCE LAST REPORT      0
END PASS #     2  TOTAL ERRORS SINCE LAST REPORT      0
```

### w11 remarks
Requires [patch](ekbbf0_patch_w11a.tcl). Still one diagnostic
```
  RACF E8 BAD
  ERRORPC TEST NUMBER
  006122  000002
```

### SimH remarks (tested with V3.12-3 RC2)
Requires [patch](ekbbf0_patch_1170.scmd).

### e11 remarks
_to come_
