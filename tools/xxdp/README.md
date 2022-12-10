This directory tree contains startup scripts and patch files for the
execution of `xxdp` test programs in w11, SimH and e11.

## Summary of available tests

| Test | Purpose |
| ---- | ------- |
| [ekbad0](ekbad0_README.md) | 11/70 cpu diagnostic part 1 |
| [ekbbf0](ekbbf0_README.md) | 11/70 cpu diagnostic part 2 |
| [ekbee1](ekbee1_README.md) | 11/70 memory management |
| [eqkce1](eqkce1_README.md) | 11/70 CPU exerciser |

The directory provides for each test platform-specific startup scripts
- `_test_run.tcl`: w11 startup script
- `_test_run.scmd`: SimH startup script (optional)
- `_test_run.ecmd`: e11 startup script (optional)

Typical usage is (replace xxxxxx with the test name):
```
ti_w11 -c7 @xxxxxx_run.tcl                      # w11 on GHDL, using cmoda7
ti_w11 -tuD,12M,break,xon @xxxxxx_run.tcl       # w11 on FPGA, arty as example
pdp11 xxxxxx_run.scmd                           # SimH simulator
e11 /initfile:xxxxxx_run.ecmd                   # e11  simulator
```
The tests run in an endless loop. To end them after some iterations use
```
.qq             # for w11
^E q            # for SimH (^E is the default break character)
^E q            # for e11  (^E is defined as break character)
```

## Logic of startup scripts and preparation of test binaries
Some `xxdp` test programs require patches for successful execution on
w11 or the SimH and e11 simulators, see next section for details.
The general workflow used by the startup scripts is therefore
- load a test program into memory
- apply patches to modify the memory image of the test
- execute the program

To support that workflow the relevant `xxdp` programs are exported from the
xxdp22 or xxdp25 oskit in _absolute binary loader_ format in a SimH session
with commands like
```
R UPD2
^E
att ptp ekbee1.lda
c
PIP PP0:=DL1:EKBEE1.BIC
```

The startup scripts expect these `.lda` files in the `to_lda` directory.
These files are for copyright reasons not part of the w11 project.

## Concept of _approved patches_ (APs)
The w11 is an as precise as feasible replica of an 11/70 KB11-C processor, but
has several differences to the real 11/70, see
[w11 differences](../../doc/w11a_known_differences.md).
The SimH and the e11 simulators also have a significant number of differences
to the real 11/70,
see [SimH differences](../../doc/simh_diff_summary.md)
and [e11 differences](../../doc/e11_diff_summary.md).
The `xxdp` test programs use in some cases _maintenance mode_ features that
are not available in w11 or the simulators, and in some cases are sensitive
to very implementation-specific behavior.
Last but not least, w11 and the simulators lack some features of a real 11/70
that are not essential for normal operation.
For these reasons, some `xxdp` test programs need some patches to execute on
w11 or the simulators. Each patch file is a commented sequence of `dep`
statements. Each patch section has a comment header that explains why the
modifications are required, what they do, and why this is a well-understood
and acceptable solution.
