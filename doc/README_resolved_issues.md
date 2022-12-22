# Resolved issues

### V0.50-3 {[issue #27](https://github.com/wfjm/w11/issues/27)} -- CPU: no mmu trap when instruction which clears trap enable itself causes a trap

#### Original Issue
The MMU should issue an mmu trap if the instruction clearing the
'mmu trap enable' bit (bit 9 in mmr0) itself causes a trap.
The 11/70 documentation clearly describes this behavior.

This is the reason why test 063 of the `ekbee1` diagnostics currently fails.

Since the MMU trap mechanism is is only available on 11/45 and 11/70, but
not in the J11, it is not used by common operating systems.

Therefore this is considered a to be a minor deficit. Will be fixed in an
upcoming release.

#### Reason for closure on 2020-12-08
Not fixed, documented as [known difference](https://github.com/wfjm/w11/blob/master/doc/w11a_diff_70_mmu_trap_suppression.md).

### V0.50-1 {[issue #23](https://github.com/wfjm/w11/issues/23)} -- CPU: several deficits in trap logic

#### Original Issue
The current w11a implementation has several deficits in the handling of
traps and interrupts which lead to non-conforming behavior when multiple
trap, fault and interrupt conditions occur simultaneously, for example
- bad stack frame when `IOT` trigger stack violation (TCK-003)
- bad stack frame when interrupt triggers stack violation (TCK-004)
- no yellow stack abort when `jsr` triggers a stack violation (TCK-006)
- no odd address trap when `EMT` is executed with odd `SP` (TCK-007)
- no yellow stack abort for `mov (sp),(sp)` (TCK-028)

These situations never occur during the execution of operation systems, and
in case they do, the operating system will crash anyway. Thus there is no
impact in normal usage, but diagnostics programs do complain. Will be fixed
in an upcoming release.

#### Fix
Fixed with commit [40608e3](https://github.com/wfjm/w11/commit/40608e3),
see [ECO-035](ECO-035-stklim-tbit-fixes.md).

### V0.791-4 {[issue #36](https://github.com/wfjm/w11/issues/36)} -- MMU trap delayed when prefetch in s_idecode

#### Original Issue
The s_idecode prefetch logic checks only for tflag and int_pending, but not
for pending MMU traps.

If the instruction read of a RR instruction, like ROR R0 or ADD R0,R1 causes
an MMU trap, this trap will not executed. In fact, it's not even queued,
it's lost.

Detected in a code review.  
No practical consequences, MMU traps are not used by any OS.  
But clearly a BUG, such cases should trigger an MMU trap.  

#### Fix
Fixed with commit [85f1854](https://github.com/wfjm/w11/commit/85f1854),
see [ECO-035](ECO-035-stklim-tbit-fixes.md).

### V0.791-3 {[issue #35](https://github.com/wfjm/w11/issues/35)} -- MMU: D space used instead of I space for PC deferred specifiers

#### Original Issue
Test 072 of `ekbee1` fails with
```
    D-SPACE ENABLE CIRCUITRY HAS FAILED
    ERROR   AUTOI/D VIRTUAL
    REGISTR REGISTR ADDRESS TESTNO  PC AT ABORT
    100027  000000  060410  000072  060412
    100027  000027  060416  000072  060422
```
The test does
```
    060410: tst  (pc)
    060416: cmp  #240,(pc)
```
and expects that these accesses are done to I space.  
They are done to D space instead.

The w11 uses D space only for `(pc)+` and `@(pc)+` specifiers.  
Clearly a bug.  
Wasn't detected so far because this access mode has no practical value  
and this therefore not used in normal software.

#### Fix
Fixed with commit [278d2e2](https://github.com/wfjm/w11/commit/278d2e2),
see [ECO-034](ECO-034-MMU_d-space-pc.md).

### V0.791-2 {[issue #34](https://github.com/wfjm/w11/issues/34)} -- MMU: ACF=1 traps on any access

#### Original Issue
Test 055 of `ekbee1` fails with
```
    MEMORY MANAGEMENT TRAP OR ABORT HAD INCORRECT CONDITION
    EXPECTD ERROR   AUTOI/D VIRTUAL
    CONDITN REGISTR REGISTR ADDRESS TESTNO  PC AT ABORT
    020011  030011  013427  054032  000055  054040
```
This is caused by a bug in pdp11_mmu. For ACF=1 a trap is taken for any access,
it should be taken only for read accesses.

#### Fix
Fixed with commit [1644863](https://github.com/wfjm/w11/commit/1644863),
see [ECO-033](ECO-033-MMU_AFC-1_PDR-A.md).

### V0.791-1 {[issue #33](https://github.com/wfjm/w11/issues/33)} -- MMU: PDR A bit is set for every access

#### Original Issue
The `PDR` `A` bit is described in the Technical Manual as
>  A bit (bit 7) - This bit is used by software to determine whether or not  
>  any accesses to this page met the trap condition specified by the Access  
>  Control Field (ACF). (A = I is affirmative). The A bit is used in the  
>  process of gathering Memory Management statistics.

It is set when the page `ACF` enables an MMU trap, thus for
-  ACF=1 and read access
-  ACF=4 and any access
-  ACF=5 and write access

The w11 currently sets the 'A' bit on any non-aborted access regardless of the ACF value.

No practical impact, the 'A' bit in `PDR` is a 11/45 11/70 only feature and not used in OS software.

#### Fix
Fixed with commit [1644863](https://github.com/wfjm/w11/commit/1644863),
see [ECO-033](ECO-033-MMU_AFC-1_PDR-A.md).

### V0.50-6 {[issue #26](https://github.com/wfjm/w11/issues/26)} -- CPU: MMR0 trap bit set when access aborted

#### Original Issue
The MMU should set the 'trap bit' in `MMR0` only when the access is not
aborted. The current pdp11_mmu implementation sets the bit even when the
access is aborted.

This is the reason why test 064 of the `ekbee1` diagnostics currently fails.

Since the MMU trap mechanism is is only available on 11/45 and 11/70, but
not in the J11, it is not used by common operating systems.

Therefore this is considered a to be a minor deficit. Will be fixed in an
upcoming release.

#### Fix
Fixed with commit [1644863](https://github.com/wfjm/w11/commit/1644863),
see [ECO-033](ECO-033-MMU_AFC-1_PDR-A.md).

### V0.50-5 {[issue #25](https://github.com/wfjm/w11/issues/25)} -- CPU: The AIB bit in MMU PDR register set independant of ACF field

#### Original Issue
The MMU should set the AIB A bit in the the PDR only when _"trap condition is
met by the Access Control Field (ACF)"_. Thus for
```
   ACF=001 read-only  trap on read
   ACF=100 read/write trap on read or write
   ACF=101 read/write trap on write
```
The current pdp11_mmu implementation always sets the bit, the logic is simply
```
    if doabort = '0' then
      AIB_SETA <= '1';
      AIB_SETW <= CNTL.wacc or CNTL.macc;
    end if;
```

Since the MMU trap mechanism is is only available on 11/45 and 11/70, but not
in the J11, it is not used by common operating systems.

Therefore this is considered a to be a minor deficit. Will be fixed in an
upcoming release.

#### Fix
Fixed with commit [1644863](https://github.com/wfjm/w11/commit/1644863),
see [ECO-033](ECO-033-MMU_AFC-1_PDR-A.md).

### V0.79-2 {[issue #30](https://github.com/wfjm/w11/issues/30)} -- SimH scmd files fail on current 4.* version; only 3.* supported

#### Original Issue
The SimH scmd scripts were originally developed for SimH 3.8, and worked for
SimH 3.9 and later releases. The SimH 4.* development team decided not to
provide releases anymore, and over time this version became incompatible with
the scmd scripts used for w11. That is most pronounced for the RT11 V4.3 oskit.
A simple
```
  cd $RETROBASE/tools/oskit/rt11-53_rl
  console_starter -s -d DL0  &
  pdp11 rt11-53_rl_boot.scmd
```
works fine for SimH V3.9, V3.10 and V3.11-1, but fails
- for pdp11-4.0-beta1 with core dump
- for pdp11-2016-12-26-5ced037b with signal SIGSEGV in pdp11_xu
- for pdp11-2019-07-28-2f707ffc with signal SIGSEGV in pdp11_xu
- for pdp11-2020-03-26-261abfc3 with signal SIGSEGV in pdp11_xu
- for pdp11-2021-08-22-64b12234 with signal SIGSEGV in pdp11_xu
- for pdp11-2022-04-17-d3f1ee09 with with errors like
  - Device auto configuration is now disabled
  - Command not allowed (for set rha enabled)
  - container incompatible with the RL device

Bottom line:
- the provided scmd scripts work only with SimH V3.9, V3.10 or V3.11-1
- an update to the SimH V4.* has low priority

#### Fix
Fixed with commit [35453c4](https://github.com/wfjm/w11/commit/35453c4)

### V0.50-4 {[issue #24](https://github.com/wfjm/w11/issues/24)} -- CPU: src+dst deltas summed in mmr1 if register identical

#### Original Issue
Test 12 of maindec `ekbee1` fails because it expects after a
```
        mov    #100000,@#mmr0
```
which sets an error bit in `mmr0` and thus freezes `mmr0`, that `mmr1` contains
```
  013427 (00010 111 00010 111) (+2,r7;+2,r7)
```
while w11a gives
```
  000047 (00000 000 00100 111) (--,--;+4,r7)
```
The `mmr1` content is _different_ compared to the original 11/70 behavior,
but is _logically correct_, fault recovery in OS (like in 211bsd) will work
correctly.  Therefore this is considered a to be a _minor deficit_.

The 11/70 documentation clearly states that there is an additional state bit
that counts the write accesses to `mmr1`. This ensures that each of the two
logged accesses end in separate bytes (byte 0 filled first).

The w11a only uses byte 1 when the register number differs.

#### Fix
Fixed with commit [3bd23c9](https://github.com/wfjm/w11/commit/3bd23c9),
see [ECO-032](ECO-032-MMR1_fix.md).

### V0.79-1 {[issue #29](https://github.com/wfjm/w11/issues/29)} -- migrate from Travis to GitHub actions

#### Original Issue
Travis is now defunct and has been removed in
[6b8c063](https://github.com/wfjm/w11/commit/6b8c063).
So it's time to migrate CI/CD to GitHub actions.

#### Fix
GitHub Actions fully implemented with commit
[db7556a4](https://github.com/wfjm/w11/commit/db7556a4), fine tuned with commit
[66f3f5d0](https://github.com/wfjm/w11/commit/66f3f5d0).

### V0.76-1 {[issue #16](https://github.com/wfjm/w11/issues/16)} -- Help wanted: Testing with Nexys4 DDR appreciated
#### Original Issue
The w11a design for Nexys4 DDR, see
[rtl/sys_gen/w11a/nexys4d](https://github.com/wfjm/w11/tree/master/rtl/sys_gen/w11a/nexys4d),
was provided to support also an up-to-date Nexys4 board. It is so far only
simulation tested.

Testing done with a real Nexyx4 DDR, or a newer Nexys A7-100T, would be highly
appreciated. Please double check the pin assignments
(see _mig_a.prj and nexys4d*.xdc_) with the documentation of your board
to avoid potential damage.

Looking forward to receive test reports.

#### Fix
The Nexys4 _(classic, with 16 MByte PSRAM)_ board, on which most of the recent
w11 was done, broke in late July 2019
(see [blog](https://wfjm.github.io/blogs/w11/2019-07-27-nexys4-obituary.html))
and a Nexys A7 was ordered as replacement.

Basic tests with the test designs
[sys_tst_serloop2](https://github.com/wfjm/w11/blob/master/rtl/sys_gen/tst_serloop/nexys4d/sys_tst_serloop2_n4d.vhd) and
[sys_tst_rlink_n4d](https://github.com/wfjm/w11/blob/master/rtl/sys_gen/tst_rlink/nexys4d/sys_tst_rlink_n4d.vhd)
and the BRAM-only w11 design
[sys_w11a_br_n4d](https://github.com/wfjm/w11/blob/master/rtl/sys_gen/w11a/nexys4d_bram/sys_w11a_br_n4d.vhd) worked fine.

But all tests involving the DDR2 memory interface failed. The culprit was
quickly found, it was a mistake in the MIG configuration
[mig_a.prj](https://github.com/wfjm/w11/blob/master/rtl/bplib/nexys4d/mig_a.prj),
the polarity of the `SYS_RST` signal was `ACTIVE LOW` instead of `ACTIVE HIGH`.
After fixing this, the test designs
[sys_tst_mig_n4d](https://github.com/wfjm/w11/blob/master/rtl/sys_gen/tst_mig/nexys4d/sys_tst_mig_n4d.vhd) and
[sys_tst_sram_n4d](https://github.com/wfjm/w11/blob/master/rtl/sys_gen/tst_sram/nexys4d/sys_tst_sram_n4d.vhd)
as well as the w11 implementation
[sys_w11a_n4d](https://github.com/wfjm/w11/blob/master/rtl/sys_gen/w11a/nexys4d/sys_w11a_n4d.vhd) worked right away.

The [tst_sram](https://github.com/wfjm/w11/tree/master/rtl/sys_gen/tst_sram)
designs show nicely that the DDR2 on the Nexys A7 board is slightly slower
than the DDR3 on the Arty A7 board
```
   Board     test time   clock period     UI_CLK
  Nexys A7     37.36 s        3333 ps   75.0 MHz 
  Arty A7      35.77 s        3000 ps   83.3 MHz
```

Closed with commit
[563e230](https://github.com/wfjm/w11/commit/563e230).

### V0.66-1 {[issue #8](https://github.com/wfjm/w11/issues/8)} -- TM11 controller doesn't support odd transfer size
#### Original Issue
The TM11 controller transfers data byte wise (all disk do it 16bit 
word wise) and allows for odd byte length transfers. Odd length transfers
are currently not supported and rejected as invalid command. Odd byte 
length records aren't used by OS, so in practice this limitation 
isn't relevant.
#### Fix
Odd record length support added with commit
[5b52e54](https://github.com/wfjm/w11/commit/5b52e54).

### V0.742-1 {[issue #14](https://github.com/wfjm/w11/issues/14)} -- SEGFAULT core dump after detach
#### Original Issue
The detach of a `tcp` type virtual terminal or a `tap` type virtual
ethernet device can lead to a SEGFAULT core dump, e.g. after a
`cpu0ttb0 det` command.
This is caused by a race condition between the detach run-down and the
implementation of `ReventLoop::RemovePollHandler()`.
#### Fix
The culprit was a design error in the `RemovePollHandler` flow, which
allowed that `DoPoll` returned while poll list updates were still pending
and the subsequent execution of `DoCall` called removed handlers.
`DoPoll` now loops until there are no pending poll list updates and
`DoCall` quits processing poll change notifications when it detects
pending poll list updates.

Fixed with commit [6f56f29](https://github.com/wfjm/w11/commit/6f56f29).

### V0.64-1 {[issue #3](https://github.com/wfjm/w11/issues/3)} -- Bad throughput for DL11 emulation for low speed links
#### Original Issue
The large default transfer size for disk accesses leads to bad
throughput in the DL11 emulation for low speed links, like the
460kBaud the S3board is limited to. Will be overcome by a DL11
controller with more buffering.
#### Fix
Fixed Resolved with buffered DL11 in commit
[1c9dbeb](https://github.com/wfjm/w11/commit/1c9dbeb).

### V0.50-10 {[issue #20](https://github.com/wfjm/w11/issues/20)} -- DL11: output chars lost when device polling used
#### Original Issue
Part of the console output can be lost when `xxdp` program `eqkce1` is
run on FPGA, also some kernel messages during the 2.11bsd boot sequence.
In both cases very simple polling output routines are used. Most likely
cause is that device ready polls timeout before the rlink interface can
serve the output request.
#### Fix
Is overcome with buffered DL11 controller with much higher throughput and
improved interrupt rate control.

Fixed with commit [1c9dbeb](https://github.com/wfjm/w11/commit/1c9dbeb).

### V0.77-1 {[issue #19](https://github.com/wfjm/w11/issues/19)} -- tcl getters accessing a const reference crash with a SIGSEGV
#### Original Issue
tcl commands like
```
  cpu0 get type
  cpu0rka get class
  rlc get timeout
```
crash with a `SIGSEGV`. Apparently all getters which internally return a
const reference are affected. Observed with gcc 5.4.0. Unclear whether this
is a coding bug introduced when `boost::bind` was replaced by lambdas
(in commit [1620ee3](https://github.com/wfjm/w11/commit/1620ee3)) or a
compiler issue.
#### Fix
The culprit was that automatic return type determination for the getter
lambdas was used. This fails when the called method returns a reference of
an object. The deduced lambda return type will the object, not a reference.
Unfortunately this doesn't lead to a compile time error but to a run time error.

Bottom lime is
- automatic return type detection for lambda's can be error prone
- it is safer and also more compact to use `std:bind` as method forwarder

Fixed with commit [6024dce](https://github.com/wfjm/w11/commit/6024dce).

### V0.73-3 {[issue #11](https://github.com/wfjm/w11/issues/11)} -- dmscnt and dmcmon disabled in Vivado based flows
#### Original Issue
The 'state number generator' code in `pdp11_sequencer` causes in Vivado
2016.1 (and .2) that the main FSM isn't re-coded anymore, which has high 
impact on achievable clock rate. The two optional debug units depending on 
the state number, `dmscnt` and `dmcmon`, are therefore currently deactivated in
all Artix based systems (but are available on all Spartan based systems).
#### Fix
At least mitigated with [d14626c](https://github.com/wfjm/w11/commit/d14626c)
which allows to use `dmcmon` without the full state number generation logic
in `pdp11_sequencer`. Reintroduced `dmcmon` in `sys_w11a_n4` again. `dmscnt` is
still deconfigured for Vivado designs, but this has much less practical impact.

## Closed issues

### V0.73-1 {[issue #9](https://github.com/wfjm/w11/issues/9)} -- Vivado xelab sometimes extremely slow
#### Original Issue
as of Vivado 2016.2 `xelab` shows sometimes extremely long build times,
especially for generated post-synthesis VHDL models. But also building a
behavioral simulation for a w11a design can take 25 min. Even though
post-synthesis or post-routing models are now generated in Verilog working
with `xsim` is cumbersome and time consuming.

#### Reason for closure on 2022-07-05
Re-checked with Vivado 2022.1.
Building models with `xelab` is now quite fast.
The issue disappeared somewhere between Vivado 2016.3 and 2022.1.

### V0.76-2 {[issue #17](https://github.com/wfjm/w11/issues/17)} -- Help wanted: Testing with Arty S7 appreciated
#### Original Issue
The w11a design for Arty S7 (50 die size), see rtl/sys_gen/w11a/artys7,
was provided to support also an up-to-date Spartan-7 based board. Turned
out that speed is equivalent to Artix-7. It is so far only simulation tested.

Testing done with a real Arty S7, would be highly appreciated. Please double
check the pin assignments (see _mig_a.prj and artys7*.xdc_) with the
documentation of your board to avoid potential damage.

Looking forward to receive test reports.

#### Reason for closure on 2020-04-20
Apparently nobody invested into an Arty S7.
The sys_w11a_as7 will be marked untested, removed from the default build
and test flows, but kept in the repository.
