This directory tree contains *man pages** and is organized in

| Directory | Content |
| --------- | ------- |
| [man1](man1) | man pages for section 1:  Commands (Programs)|
| [man5](man5) | man pages for section 5: File formats and conventions|

All actively used commands available in [tools/bin](../bin) have a _man_ page.
Only some legacy commands which will be removed in the near future are not
documented
```
  ticonv_pdpcp       used from: ./tools/tcl/rw11/util.tcl:  run_pdpcp
  ticonv_rri         used from: ./tools/tcl/rlink/util.tcl: run_rri
  xilinx_tsim_xon    used from: ./rtl/make_ise/generic_xflow.mk
  xst_count_bels     used from: ./rtl/make_ise/generic_xflow.mk
```
