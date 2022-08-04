## stktst: a program testing 2.11BSD stack extension logic

The `stktst` program exercises the 2.11BSD stack extension logic.
In a first step, the `sp` can be aligned to a click (64 byte) or a
segment (8129 byte) boundary.
An offset can also be applied after this alignment.
In a second step, a sequence of integer and floating point instructions with
a `-(sp)` destination is executed.
This allows to set up almost every possible stack extension situation.

Motivation for `stktst` were differences in the `MMR1` register implementation
in different PDP-11 CPUs, and differences in the modeling of `MMR1` in
different PDP-11 simulators.
That combined with the 2.11BSD stack extension handling prior to #473 can lead
to unexpected "Memory fault" aborts in 2.11BSD.

The results are collected in the [data](data) folder.

`stktst` has an assembler core [dotst.s](dotst.s) which is called from a
C main program [stktst.c](stktst.c). It is called as
```
  ./stktst <cmd> <count> [-s ns] [-c nc] [-o no]
```
The options control the initial stack alignment:
- **`-s ns`**: aligns to 8192 byte segment boundaries. ns=1 to the next one,
  nc=2 to the second next one, etc.
  Obviously, `ns` should be smaller than 8.
  The option is ignored if ns<=0.
- **`-c nc`**: aligns to 64 byte click boundaries. nc=1 to the next one,
  nc=2 to the second next one, etc.
  The first alignment step will not change the stack if it was alreay on a
  click bounday, it will therefore add 0 to 64 bytes to the stack.
  The option is ignored if nc<=0.
  Click alignment is done after segment alignment.
- **`-o no`**: adds `no` to `sp`. `no` must be even and can be positive or
  negative.

**Notes**:
- no range checks is done for `no`.
  After a **-s** is is save to use small positive `no` values to position `sp`
  a bit before a segment boundary.
  After a **-c** is is better to use negative `no` values to position `sp`
  before the next click boundary.
- the stack allocated below the argument and environment values.
  The initial `sp` value will therefore decrease when the number of characters
  in the argument list increases because the stack base moves down.
  In some cases it is therefore prudent to specify the numbers as quoted
  strings with some leading blanks, like
  ```
    ./stktst d '  3' -c '  2' -o '  4'
  ```
  That allows to change the counts without changing the length of the
  argument list.

The `cmd` argument selects the instruction that does the stack push and
`count` determines how often it is executed.
The available modes for `cmd` are
- **`I`**: use `clr -(sp)` --> integer word push
- **`i`**: use `movfi -(sp)` after `seti` --> word push from FPP
- **`l`**: use `movfi -(sp)` after `setl` --> double word push from FPP
- **`f`**: use `movf -(sp)` after `setf`  --> double word push from FPP
- **`d`**: use `movf -(sp)` after `setd`  --> quad word push from FPP

For debug purposes three additional `cmd` modes are available:
- **`r`**: uses `count` as an address and reads
- **`w`**: uses `count` as an address, reads and re-writes
- **`h`**: runs a `halt`

`stktst` prints the `sp` after alignment and after the stack pushes like
```
  stktst-I: before sp 177304 (0,  4,60); 177200 (0,  5,64);
  stktst-I: after  sp 177304 (0,  4,60); 177200 (0,  5,64); 167200 (0, 69,64);
```
and gives the `sp` value
- after `dotst.s` is called
- after alignments and offsets were applied
- after stack pushes were executed

and prints it in octal and broken down in segment, click and byte offset.
Because the stack is a downward growing segment, all offsets measure the
distance to the top of memory and increase when the `sp` decreases.

When a stack extension fails, the program will print the first line and abort.
