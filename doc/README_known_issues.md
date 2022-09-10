# Known issues
Notes
- resolved issues are summarized in [resolved issues](README_resolved_issues.md)
- the case id indicates the release when the issue was first recognized.

### V0.791-3 {[issue #35](https://github.com/wfjm/w11/issues/35)} -- MMU: D space used instead of I space for PC deferred specifiers

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
'mmu trap enable' bit (bit 9 in mmr0) itself causes a trap.
The 11/70 documentation clearly describes this behavior.

This is the reason why test 063 of the `ekbee1` diagnostics currently fails.

Since the MMU trap mechanism is is only available on 11/45 and 11/70, but
not in the J11, it is not used by common operating systems.

Therefore this is considered a to be a minor deficit. Will be fixed in an
upcoming release.

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
systems never set up DMA transfers to/from non-existing memory. However, some
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

