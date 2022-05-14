# Known issues

The case id indicates the release when the issue was first recognized.

### V0.79-2 {[issue #30](https://github.com/wfjm/w11/issues/30)} -- SimH scmd files fail on current 4.* version; only 3.* supported

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

### V0.50-2 {[issue #28](https://github.com/wfjm/w11/issues/28)} -- RK11: write protect action too slow

Some simple RK11 drivers, especially in test codes, don't poll for completion
of a write protect command. Due to the emulated I/O this can cause errors.

One example is the boot sequence of RK based XXDP, as seen for example for
the `dzzza` disk. On SimH the disk is immediately switched to write protect
mode, on w11 it is not. The pertinent part of the code is
```
    000214  B003:  mov	#000017,@#rk.cs   ; #rk.fwl+rk.go;  func=write_lock
    000222         bic	#017777,r2      
    000226         clc	
    000230         rol	r2
    000232         rol	r2
    000234         rol	r2
    000236         rol	r2
    000240         mov	r2,D040
    000244         mov	#000001,@#rk.cs   ; #rk.go;         func=control reset
```
The monitor does two writes to the RK11 CSR without busy polling and just a
few instructions in between. In the w11 implementation the first write will
set func=write_lock and cause an attn request. But before the attn can be
serviced the CSR is overwritten with func=creset. The write lock is lost,
only the creset is executed.

Can be resolved by handling write lock locally. Normal OS always do
a busy poll before starting a function, therefore this is considered
a minor deficit. Might be fixed in an upcoming release.

### V0.50-3 {[issue #27](https://github.com/wfjm/w11/issues/27)} -- CPU: no mmu trap when instruction which clears trap enable itself causes a trap

The MMU should issue an mmu trap if the instruction clearing the
'mmu trap enable' bit (bit 9 in ssr0) itself causes a trap. 
The 11/70 documentation clearly describes this behavior.

This is the reason why test 063 of the `ekbee1` diagnostics currently fails.

Since the MMU trap mechanism is is only available on 11/45 and 11/70, but
not in the J11, it is not used by common operating systems.

Therefore this is considered a to be a minor deficit. Will be fixed in an
upcoming release.

### V0.50-6 {[issue #26](https://github.com/wfjm/w11/issues/26)} -- CPU: SSR0 trap bit set when access aborted

The MMU should set the 'trap bit' in `SSR0` only when the access is not
aborted. The current pdp11_mmu implementation sets the bit even when the
access is aborted.

This is the reason why test 064 of the `ekbee1` diagnostics currently fails.

Since the MMU trap mechanism is is only available on 11/45 and 11/70, but
not in the J11, it is not used by common operating systems.

Therefore this is considered a to be a minor deficit. Will be fixed in an
upcoming release.

### V0.50-5 {[issue #25](https://github.com/wfjm/w11/issues/25)} -- CPU: The AIB bit in MMU SDR register set independant of ACF field

The MMU should set the AIB A bit in the the SDR only when _"trap condition is 
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

### V0.50-4 {[issue #24](https://github.com/wfjm/w11/issues/24)} -- CPU: src+dst deltas summed in ssr1 if register identical

Test 12 of maindec `ekbee1` fails because it expects after a
```
        mov    #100000,@#ssr0
```
which sets an error bit in `ssr0` and thus freezes `ssr0`, that `ssr1` contains
```
  013427 (00010 111 00010 111) (+2,r7;+2,r7)
```
while w11a gives
```
  000047 (00000 000 00100 111) (--,--;+4,r7)
```
The `ssr1` content is _different_ compared to the original 11/70 behavior,
but is _logically correct_, fault recovery in OS (like in 211bsd) will work
correctly.  Therefore this is considered a to be a _minor deficit_.

The 11/70 documentation clearly states that there is an additional state bit
that counts the write accesses to `ssr1`. This ensures that each of the two
logged accesses end in separate bytes (byte 0 filled first).

The w11a only uses byte 1 when the register number differs.

### V0.50-1 {[issue #23](https://github.com/wfjm/w11/issues/23)} -- CPU: several deficits in trap logic

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

### V0.50-8 {[issue #21](https://github.com/wfjm/w11/issues/21)} -- RK11,RL11: no proper NXM check in 18bit systems

No `NXM` error is generated when a UNIBUS device DMA transfer reaches the top
of memory in 18 bit addressing. Seen originally for RK11, but RL11 and DEUNA
are also affected.

In normal operation is minor non-conformity is not relevant because operating
systems never setup DMA transfers to/from non-existing memory. However, some
highly space optimized crash dump routines use this to detect end-of-memory
and might endless loop. Also maindec's might test this border case and fail.

### V0.76-3 {[issue #18](https://github.com/wfjm/w11/issues/18)} -- w11 clock rate limited by CACHE-to-CACHE false path
So far all Series-7 w11a systems ran with 80 MHz clock. The sys_w11_arty
design (with DDR memory support via MIG) also achieves timing closure under
Vivado 2017.2, but fails (with a small negative slack) under Vivado 2018.3.

The failing data path has
```
  Source:      SYS70/CACHE/CMEM_DAT1/sv_ram_reg_0/DOADO[1]
  Destination: SYS70/CACHE/CMEM_DAT3/sv_ram_reg_0/DIADI[1]
  via            VMBOX->SEQ->OUNIT->SEQ->DPATH->SEQ->VMBOX
```
The connectivity of the multiplexers in `pdp_dpath` in principle allows such
a data flow, but `pdp11_sequencer` will never configure the multiplexers in
such a way. So technically this is a false path.

It seems that the placer strategy changed from Vivado 2017.2 to 2018.3 and
that 2018.3 is less tolerant to the sub-optimal w11a design.

This will be fixed in a future release, either by setting up an appropriate
false_path constraint, or by changing the data path structure.

### V0.73-2 {[issue #10](https://github.com/wfjm/w11/issues/10)} -- Many post-synthesis simulations fail
Many post-synthesis functional and especially post-routing timing 
simulations currently fail due to startup and initialization problems. 
Cause is MMCM/PLL startup, which is not properly reflected in the test 
bench. Will be resolved in an upcoming release.

### V0.73-1 {[issue #9](https://github.com/wfjm/w11/issues/9)} -- Vivado xelab sometimes extremely slow
as of Vivado 2016.2 `xelab` shows sometimes extremely long build times,
especially for generated post-synthesis VHDL models. But also building a 
behavioral simulation for a w11a design can take 25 min. Even though 
post-synthesis or post-routing models are now generated in Verilog working 
with `xsim` is cumbersome and time consuming.

### V0.65-2 {[issue #7](https://github.com/wfjm/w11/issues/7)} -- Some exotic RH70/RP/RM features not implemented
some exotic RH70/RP/RM features and conditions not implemented yet
- last block transfered flag (in DS)
- `CS2.BAI` currently ignored and not handled
- read or write 'with header' gives currently `ILF`

All this isn't used by any OS, so in practice not relevant.

### V0.65-1 {[issue #6](https://github.com/wfjm/w11/issues/6)} -- ti_rri crashes in normal rundown in very rare cases
`ti_rri` sometimes crashes in normal rundown (exit or ^D) when
a `cuff:` type rlink is active. One gets
```
      terminate called after throwing an instance of 'Retro::Rexception'
        what():  RlinkPortCuff::Cleanup(): driver thread failed to stop
```
Doesn't affect normal operation, will be fixed in upcoming release.

### V0.64-6 {[issue #5](https://github.com/wfjm/w11/issues/5)} -- IO delays still unconstraint in Vivado
IO delays still unconstraint in Vivado. All critical IOs use
explicitly IOB flops, thus timing well defined.

### V0.64-2 {[issue #4](https://github.com/wfjm/w11/issues/4)} -- rlink throughput on basys3/nexys4 limited by serial port stack round trip times
rlink throughput on basys3/nexys4 limited by serial port stack 
round trip times. Will be overcome by libusb based custom driver.

### V0.62-2 {[issue #2](https://github.com/wfjm/w11/issues/2)} -- rlink v4 error recovery not yet implemented, will crash on error
rlink v4 error recovery not yet implemented, will crash on error.

### V0.62-1 {[issue #1](https://github.com/wfjm/w11/issues/1)} -- rlink command lists aren't split to fit in retransmit buffer size
rlink command lists aren't split to fit in retransmit buffer size.

_{the last two issues are not relevant for w11 backend over USB usage because
the backend produces proper command lists and the USB channel is usually error
free}_

## Resolved Issues

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
Part of the console output can be lost when `xxdp` test `eqkce1` is
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

### V0.76-2 {[issue #17](https://github.com/wfjm/w11/issues/17)} -- Help wanted: Testing with Arty S7 appreciated
#### Original Issue
The w11a design for Arty S7 (50 die size), see rtl/sys_gen/w11a/artys7,
was provided to support also an up-to-date Spartan-7 based board. Turned
out that speed is equivalent to Artix-7. It is so far only simulation tested.

Testing done with a real Arty S7, would be highly appreciated. Please double
check the pin assignments (see _mig_a.prj and artys7*.xdc_) with the
documentation of your board to avoid potential damage.

Looking forward to receive test reports.

#### Reason for closure
Apparently nobody invested into an Arty S7.
The sys_w11a_as7 will be marked untested, removed from the default build
and test flows, but kept in the repository.
