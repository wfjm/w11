This directory holds asm-11 test bench files.

The test bench files are self-checking and annotated with the expected
compilation result for checking with [asm-11_expect](../../bin/asm-11_expect).
All test cases expected to compile without errors.
The error response is tested in a separate test bench fileset located
in the [tests-err](../tests-err) directory.

The [Makefile](Makefile) provides the targets
```
  make alllda           ; create all .lda files
  make allcof           ; create all .cof files
  make alllst           ; create all .lst files
  make allexp           ; check all .lst files with asm-11_expect
  make distclean        ; remove all generated files
```
