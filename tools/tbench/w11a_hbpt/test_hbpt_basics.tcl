# $Id: test_hbpt_basics.tcl 724 2016-01-03 22:53:53Z mueller $
#
# Copyright 2015-2016 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
# License disclaimer see LICENSE_gpl_v2.txt in $RETROBASE directory
#
# Revision History:
# Date         Rev Version  Comment
# 2016-01-02   724   1.0.2  use s: defs for CP_STAT(rust)
# 2015-12-30   721   1.0.1  BUGFIX: add missing wtcpu in mfpd/mtpd tests
# 2015-07-11   700   1.0    Initial version
#
# Test register response 

# ----------------------------------------------------------------------------
rlc log "test_hbpt_basics: basic tests with 1 unit ---------------------------"

set nbpt [$cpu get hashbpt]
if {$nbpt == 0} {
  rlc log "  test_hbpt_basics-W: no hbpt units found, test aborted"
  return
}

rlc log "  setup: clear all bpts"
for {set i 0} {$i<$nbpt} {incr i} {
  $cpu cp -wreg "hb${i}.cntl"  0 \
          -wreg "hb${i}.stat"  0
}

# -- Section A ---------------------------------------------------------------
rlc log "  A basic ir,dr,dw break tests ------------------------------"

$cpu ldasm -lst lst -sym sym {
        . = 1000
start:  nop
I0:     clr     r0
I1:     inc     r0
I2:     inc     r0
I3:     inc     r0
I4:     mov     a,r1
I5:     mov     @pb,r2
I6:     mov     r1,c
I7:     mov     r2,@pd
I8:     halt
stop:
;
a:      .word   123
b:      .word   234
c:      .word   0
d:      .word   0
pb:     .word   b
pd:     .word   d
}

rlc log "    A1: run code without breaks ------------------------"
rw11::asmrun  $cpu sym
rw11::asmwait $cpu sym 
rw11::asmtreg $cpu     r0 3 r1 0123 r2 0234
rw11::asmtmem $cpu $sym(c) {0123}
rw11::asmtmem $cpu $sym(d) {0234}

rlc log "    A2.1: ir break on single instruction ---------------"
# set ir break after 1st "inc r0"
rw11::hb_set cpu0 0 i $sym(I1)
rw11::asmrun  $cpu sym
$cpu wtcpu -reset $rw11::asmwait_tout
$cpu cp -rreg  "hb0.stat" -edata [regbld rw11::HB_STAT irseen] \
        -rstat -edata [regbld rw11::CP_STAT suspint {rust hbpt} susp go] \
        -rpc   -edata $sym(I2) \
        -rr0   -edata 1

rlc log "    A2.2: step after ir break --------------------------"
$cpu cp -step
$cpu cp -rreg  "hb0.stat" -edata [regbld rw11::HB_STAT irseen] \
        -rstat -edata [regbld rw11::CP_STAT suspint {rust step} susp go] \
        -rpc   -edata $sym(I3) \
        -rr0   -edata 2

rlc log "    A2.3: resume after ir break ------------------------"
$cpu cp -resume
rw11::asmwait $cpu sym 
rw11::asmtreg $cpu     r0 3 r1 0123 r2 0234

rlc log "    A3.1: ir break on range of instructions ------------"
# set ir break on 2nd and 3rd "inc r0"
rw11::hb_set cpu0 0 i $sym(I2) $sym(I3)
rw11::asmrun  $cpu sym
$cpu wtcpu -reset $rw11::asmwait_tout
$cpu cp -rreg  "hb0.stat" -edata [regbld rw11::HB_STAT irseen] \
        -rstat -edata [regbld rw11::CP_STAT suspint {rust hbpt} susp go] \
        -rpc   -edata $sym(I3) \
        -rr0   -edata 2

rlc log "    A3.2: resume, should re-break ----------------------"
$cpu cp -resume
$cpu wtcpu -reset $rw11::asmwait_tout
$cpu cp -rstat -edata [regbld rw11::CP_STAT suspint {rust hbpt} susp go] \
        -rpc   -edata $sym(I4) \
        -rr0   -edata 3

rlc log "    A3.3: resume, should run to end --------------------"
$cpu cp -resume
rw11::asmwait $cpu sym 
rw11::asmtreg $cpu     r0 3 r1 0123 r2 0234

rlc log "    A4.1: dr break on direct read location -------------"
# set dr break on a, should break after "mov a,r1"
rw11::hb_set cpu0 0 r $sym(a)
rw11::asmrun  $cpu sym
$cpu wtcpu -reset $rw11::asmwait_tout
$cpu cp -rreg  "hb0.stat" -edata [regbld rw11::HB_STAT drseen] \
        -rstat -edata [regbld rw11::CP_STAT suspint {rust hbpt} susp go] \
        -rpc   -edata $sym(I5) \
        -rr1   -edata 0123

rlc log "    A4.2: dr break on pointer used in indirect write ---"
# set dr break on pd, should break after "mov r2,@pd"
rw11::hb_set cpu0 0 r $sym(pd)
$cpu cp -resume
$cpu wtcpu -reset $rw11::asmwait_tout
$cpu cp -rreg  "hb0.stat" -edata [regbld rw11::HB_STAT drseen] \
        -rstat -edata [regbld rw11::CP_STAT suspint {rust hbpt} susp go] \
        -rpc   -edata $sym(I8) \
        -rr2   -edata 0234

rlc log "    A5.1: dw break on direct written location ----------"
# set dw break on c, should break after "mov r1,c"
rw11::hb_set cpu0 0 w $sym(c)
rw11::asmrun  $cpu sym
$cpu wtcpu -reset $rw11::asmwait_tout
$cpu cp -rreg  "hb0.stat" -edata [regbld rw11::HB_STAT dwseen] \
        -rstat -edata [regbld rw11::CP_STAT suspint {rust hbpt} susp go] \
        -rpc   -edata $sym(I7) \
        -rr2   -edata 0234

rlc log "    A5.2: dw break on indirect write location ----------"
# set dw break on d, should break after "mov r2,@pd"
rw11::hb_set cpu0 0 w $sym(d)
$cpu cp -resume
$cpu wtcpu -reset $rw11::asmwait_tout
$cpu cp -rreg  "hb0.stat" -edata [regbld rw11::HB_STAT dwseen] \
        -rstat -edata [regbld rw11::CP_STAT suspint {rust hbpt} susp go] \
        -rpc   -edata $sym(I8) \
        -rr2   -edata 0234

# -- Section B ---------------------------------------------------------------
rlc log "  B specific ir tests ---------------------------------------"

$cpu ldasm -lst lst -sym sym {
        . = 1000
stack:
start:  nop
I0:     mov     #a,r0
I1:     mov     a,r1
I2:     mov     2(r0),r2
I3:     mfpi    c
I4:     mov     (sp)+,r3
I5:     halt
stop:
;
a:      .word   123
b:      .word   234
c:      .word   345
}

rlc log "    B1: run code without breaks ------------------------"
rw11::asmrun  $cpu sym
rw11::asmwait $cpu sym 
rw11::asmtreg $cpu     r0 $sym(a) r1 0123 r2 0234 r3 0345

rlc log "    B2: ensure that immediate fetch doesn't ir break ---"
# set ir break on immediate value of "mov #a,r0"
rw11::hb_set cpu0 0 i [expr $sym(I0)+2]
rw11::asmrun  $cpu sym
rw11::asmwait $cpu sym 

rlc log "    B3: ensure that index fetch (reg != pc) doesn't ir break ---"
# set ir break on index value of "mov a,r1"
rw11::hb_set cpu0 0 i [expr $sym(I1)+2]
rw11::asmrun  $cpu sym
rw11::asmwait $cpu sym 

rlc log "    B4: ensure that index fetch (reg == pc) doesn't ir break ---"
# set ir break on index value of "mov 2(r0),r2"
rw11::hb_set cpu0 0 i [expr $sym(I2)+2]
rw11::asmrun  $cpu sym
rw11::asmwait $cpu sym 

rlc log "    B5: ensure that mfpi doesn't ir break ---"
# set ir break on load value of "mfpi c"
rw11::hb_set cpu0 0 i [expr $sym(c)]
rw11::asmrun  $cpu sym
rw11::asmwait $cpu sym 

# -- Section C ---------------------------------------------------------------
rlc log "  C test mode logic and mfpd/mtpd ---------------------------"

$cpu ldasm -lst lst -sym sym {
        .include  |lib/defs_cpu.mac|
        . = 1000
stack:
start:  nop
        mov     #<cp.cmu+cp.pmu>,@#cp.psw   ;cm=pm=user
I1:     mov     a,r0
I2:     mov     r0,b
I3:     nop
        mov     #cp.pmu,@#cp.psw            ;cm=kernel,pm=user
I4:     mfpd    c
I5:     mov     (sp),r1
I6:     mtpd    d
I7:     nop
        halt
stop:
;
a:      .word   123
b:      .word   0
c:      .word   234
d:      .word   0
}

rlc log "    C1: run code without breaks ------------------------"
rw11::asmrun  $cpu sym
rw11::asmwait $cpu sym 
rw11::asmtreg $cpu     r0 0123 r1 0234
rw11::asmtmem $cpu $sym(b) {0123}
rw11::asmtmem $cpu $sym(d) {0234}

rlc log "    C2.1: kernel dr break on user mode read -> no bpt --"
# set k mode dr break on value of "mov a,r0"
rw11::hb_set cpu0 0 kr [expr $sym(a)]
rw11::asmrun  $cpu sym
rw11::asmwait $cpu sym 

rlc log "    C2.2: super dr break on user mode read -> no bpt ---"
# set s mode dr break on value of "mov a,r0"
rw11::hb_set cpu0 0 sr [expr $sym(a)]
rw11::asmrun  $cpu sym
rw11::asmwait $cpu sym 

rlc log "    C2.3: user dw break on user mode write ->  bpt -----"
# set u mode dw break on value of "mov r0,b"
rw11::hb_set cpu0 0 uw [expr $sym(b)]
rw11::asmrun  $cpu sym

$cpu wtcpu -reset $rw11::asmwait_tout
$cpu cp -rreg  "hb0.stat" -edata [regbld rw11::HB_STAT dwseen] \
        -rstat -edata [regbld rw11::CP_STAT suspint {rust hbpt} susp go] \
        -rpc   -edata $sym(I3)

rlc log "    C3.1: kernel dr break on mfpd (pm=user) -> no bpt --"
# set k mode dr break on target of "mfpd c"
rw11::hb_set cpu0 0 kr [expr $sym(c)]
rw11::asmrun  $cpu sym
rw11::asmwait $cpu sym 

rlc log "    C3.2: super  dr break on mfpd (pm=user) -> no bpt --"
# set s mode dr break on target of "mfpd c"
rw11::hb_set cpu0 0 sr [expr $sym(c)]
rw11::asmrun  $cpu sym
rw11::asmwait $cpu sym 

rlc log "    C3.3: user   dr break on mfpd (pm=user) -> bpt -----"
# set u mode dr break on target of "mfpd c"
rw11::hb_set cpu0 0 ur [expr $sym(c)]
rw11::asmrun  $cpu sym
$cpu wtcpu -reset $rw11::asmwait_tout
$cpu cp -rreg  "hb0.stat" -edata [regbld rw11::HB_STAT drseen] \
        -rstat -edata [regbld rw11::CP_STAT suspint {rust hbpt} susp go] \
        -rpc   -edata $sym(I5)

rlc log "    C4.1: kernel dw break on mtpd (pm=user) -> no bpt --"
# set k mode dw break on target of "mtpd d"
rw11::hb_set cpu0 0 kw [expr $sym(d)]
rw11::asmrun  $cpu sym
rw11::asmwait $cpu sym 

rlc log "    C4.2: super  dw break on mtpd (pm=user) -> no bpt --"
# set s mode dw break on target of "mtpd d"
rw11::hb_set cpu0 0 sw [expr $sym(d)]
rw11::asmrun  $cpu sym
rw11::asmwait $cpu sym 

rlc log "    C4.3: user   dw break on mtpd (pm=user) -> bpt -----"
# set u mode dw break on target of "mtpd d"
rw11::hb_set cpu0 0 uw [expr $sym(d)]
rw11::asmrun  $cpu sym
$cpu wtcpu -reset $rw11::asmwait_tout
$cpu cp -rreg  "hb0.stat" -edata [regbld rw11::HB_STAT dwseen] \
        -rstat -edata [regbld rw11::CP_STAT suspint {rust hbpt} susp go] \
        -rpc   -edata $sym(I7)

