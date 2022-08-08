This directory contains the **w11 test codes**.

The _tcodes_ are MACRO-11 stand-alone codes. They are meant for
verification and not as diagnostic tool:
- in case of success, they stop on a `halt` at 2000, thus with PC=002002
- in case of error, they `halt` at the point of the failed check

The codes can be executed
- in a w11 GHDL simulation, usually via a `ti_w11 -c7 -w -e <mac-file>`
- with SimH, usually via a `load <lda-file>`, `dep pc 200`, `cont`
- with `e11`, usually via a `mount pr: <lda-file>`, `boot pr:`

A [Makefile](Makefile) is provided with the targets
```
  make alllda           all .lda + .lst files
  make alllst           all .lst files
  make allexp           all exp.mac export files
  make alltsim          all SimH tests
  make allte11          all e11 tests
  make alltw11          all w11 GHDL simulation tests
  make <tcode>.lda      compile, create .lda + .lst
  make <tcode>.lst      compile, create .lst
  make <tcode>.exp.mac  compile with -E
  make <tcode>.tsim     run on SimH simulator
  make <tcode>.te11     run on e11  simulator
  make <tcode>.tw11     run on w11  GHDL simulation (for C7)
```
