# Known issues

The issues of the w11 CPU are listed in a separate document
[w11a_known_issues.md](w11a_known_issues.md).

This file descibes general issues.

The case id indicates the release when the issue was first recognized.

### V0.50-10 {[issue #20](https://github.com/wfjm/w11/issues/20)} -- DL11: output chars lost when device polling used
Part of the console output can be lost when `xxdp` test `eqkce1` is
run on FPGA, also some kernel messages during the 2.11bsd boot sequence.
In both cases very simple polling output routines are used. Most likely
cause is that device ready polls timeout before the rlink interface can
serve the output request.

Will be overcome by a DL11 controller with more buffering and improved
interrupt rate control.

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

### V0.76-2 {[issue #17](https://github.com/wfjm/w11/issues/17)} -- Help wanted: Testing with Arty S7 appreciated
The w11a design for Arty S7 (50 die size), see rtl/sys_gen/w11a/artys7,
was provided to support also an up-to-date Spartan-7 based board. Turned
out that speed is equivalent to Artix-7. It is so far only simulation tested.

Testing done with a real Arty S7, would be highly appreciated. Please double
check the pin assignments (see _mig_a.prj and artys7*.xdc_) with the
documentation of your board to avoid potential damage.

Looking forward to receive test reports.

### V0.76-1 {[issue #16](https://github.com/wfjm/w11/issues/16)} -- Help wanted: Testing with Nexys4 DDR appreciated
The w11a design for Nexys4 DDR, see rtl/sys_gen/w11a/nexys4d, was provided
to support also an up-to-date Nexys4 board. It is so far only simulation tested.

Testing done with a real Nexyx4 DDR, or a newer Nexys A7-100T, would be highly
appreciated. Please double check the pin assignments
(see _mig_a.prj and nexys4d*.xdc_) with the documentation of your board
to avoid potential damage.

Looking forward to receive test reports.

### V0.742-1 {[issue #14](https://github.com/wfjm/w11/issues/14)} -- SEGFAULT core dump after detach
The detach of a `tcp` type virtual terminal or a `tap` type virtual
ethernet device can lead to a SEGFAULT core dump, e.g. after a
`cpu0ttb0 det` command.
This is caused by a race condition between the detach run-down and the
implementation of `ReventLoop::RemovePollHandler()`.

### V0.73-2 {[issue #10](https://github.com/wfjm/w11/issues/10)} -- Many post-synthesis simulations fail
Many post-synthesis functional and especially post-routing timing 
simulations currently fail due to startup and initialization problems. 
Cause is MMCM/PLL startup, which is not properly reflected in the test 
bench. Will be resolved in an upcoming release.

### V0.73-1 {[issue #9](https://github.com/wfjm/w11/issues/9)} -- Vivado xelab sometimes extremely slow
as of vivado 2016.2 `xelab` shows sometimes extremely long build times,
especially for generated post-synthesis vhdl models. But also building a 
behavioral simulation for a w11a design can take 25 min. Even though 
post-synthesis or post-routing models are now generated in verilog working 
with `xsim` is cumbersome and time consuming.

### V0.66-1 {[issue #8](https://github.com/wfjm/w11/issues/8)} -- TM11 controller doesn't support odd transfer size
the TM11 controller transfers data byte wise (all disk do it 16bit 
word wise) and allows for odd byte length transfers. Odd length transfers
are currently not supported and rejected as invalid command. Odd byte 
length records aren't used by OS, so in practice this limitation 
isn't relevant.

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

### V0.64-1 {[issue #3](https://github.com/wfjm/w11/issues/3)} -- Bad throughput for DL11 emulation for low speed links
The large default transfer size for disk accesses leads to bad
throughput in the DL11 emulation for low speed links, like the
460kBaud the S3board is limited to. Will be overcome by a DL11
controller with more buffering.

### V0.62-2 {[issue #2](https://github.com/wfjm/w11/issues/2)} -- rlink v4 error recovery not yet implemented, will crash on error
rlink v4 error recovery not yet implemented, will crash on error.

### V0.62-1 {[issue #1](https://github.com/wfjm/w11/issues/1)} -- rlink command lists aren't split to fit in retransmit buffer size
rlink command lists aren't split to fit in retransmit buffer size.

_{the last two issues are not relevant for w11 backend over USB usage because
the backend produces proper command lists and the USB channel is usually error
free}_

## Resolved Issues
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
The 'state number generator' code in `pdp11_sequencer` causes in vivado
2016.1 (and .2) that the main FSM isn't re-coded anymore, which has high 
impact on achievable clock rate. The two optional debug units depending on 
the state number, `dmscnt` and `dmcmon`, are therefore currently deactivated in
all Artix based systems (but are available on all Spartan based systems).
#### Fix
At least mitigated with [d14626c](https://github.com/wfjm/w11/commit/d14626c)
which allows to use `dmcmon` without the full state number generation logic
in `pdp11_sequencer`. Reintroduced `dmcmon` in `sys_w11a_n4` again. `dmscnt` is
still deconfigured for vivado designs, but this has much less practical impact.
