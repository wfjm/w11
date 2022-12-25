# EKBEE1 - 11/70 memory management

### Documentation
- [DiagnosticsHandbook](http://www.bitsavers.org/pdf/dec/pdp11/xxdp/PDP11_DiagnosticHandbook_1988.pdf) p22
- [EKBEE0 source listing](http://www.bitsavers.org/pdf/dec/pdp11/microfiche/Diagnostic_Program_Listings/Listings/CEKBEE0__PDP-11-70__11-70_MEM_MGMT__AH-7976E-MC__SEP_1980_bw.pdf) (only EKBEE0 available, all code addresses identical)

### Usage
```
ti_w11 -c7 @ekbee1_run.tcl                      # w11 on GHDL, using cmoda7
ti_w11 -tuD,12M,break,xon @ekbee1_run.tcl       # w11 on FPGA, arty as example
pdp11 ekbee1_run.scmd                           # SimH simulator
e11 /initfile:ekbee1_run.ecmd                   # E11  simulator
```

### Expected output when no errors are reported
```
CEKBEE0 11/70 MEM MGMT
CPU UNDER TEST FOUND TO BE A KB11-B/C

END PASS #     1  TOTAL ERRORS SINCE LAST REPORT      0
END PASS #     2  TOTAL ERRORS SINCE LAST REPORT      0
...
```

### w11 remarks
Requires [patch](ekbee1_patch_w11a.tcl).

### SimH remarks (tested with V3.12-3 RC2)
Requires [patch](ekbee1_patch_1170.scmd).

### E11 remarks
_to come_
