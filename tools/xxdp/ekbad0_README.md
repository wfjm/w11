# EKBAD0 - 11/70 cpu diagnostic part 1

### Documentation
- [DiagnosticsHandbook](http://www.bitsavers.org/pdf/dec/pdp11/xxdp/PDP11_DiagnosticHandbook_1988.pdf) p18
- [EKBEE0 source listing](http://www.bitsavers.org/pdf/dec/pdp11/microfiche/Diagnostic_Program_Listings/Listings/CEKBAD0__PDP-11-70__11-70_CPU_1__AH-7963D-MC__SEP_1980_bw.pdf)

### Usage
```
ti_w11 -c7 @ekbad0_run.tcl                      # w11 on GHDL, using cmoda7
ti_w11 -tuD,12M,break,xon @ekbad0_run.tcl       # w11 on FPGA, arty as example
pdp11 ekbad0_run.scmd                           # SimH simulator
e11 /initfile:ekbad0_run.ecmd                   # E11  simulator
```

### Expected output (code halts in case of an error)
```
AA
CEKBAD0 11/70 CPU #1

END PASS
END PASS
...
```

### Remarks
Runs without patches on w11, SimH and E11.
