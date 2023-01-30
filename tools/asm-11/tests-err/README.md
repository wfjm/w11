This directory holds asm-11 error response test bench files.

This fileset tests the error response of asm-11.
All test cases expected to compile with errors.
The test bench files are self-checking and annotated with the expected
compilation result for checking with [asm-11_expect](../../bin/asm-11_expect).
The listing files have the file type `.lsterr`, the make rule for that file type
ignores the non-zero exit code of asm-11.

The [Makefile](Makefile) provides the targets
```
  make alllda           ; create all .lda files
  make allcof           ; create all .cof files
  make alllst           ; create all .lsterr files
  make allexp           ; check all .lsterr files with asm-11_expect
  make distclean        ; remove all generated files
```
