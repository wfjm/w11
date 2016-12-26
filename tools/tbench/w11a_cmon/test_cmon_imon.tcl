# $Id: test_cmon_imon.tcl 830 2016-12-26 20:25:49Z mueller $
#
# Copyright 2015- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
# License disclaimer see License.txt in $RETROBASE directory
#
# Revision History:
# Date         Rev Version  Comment
# 2015-07-18   701   1.0    Initial version
#
# Test register response 

# ----------------------------------------------------------------------------
rlc log "test_cmon_imon: test last instruction monitor -----------------------"

if {[$cpu get hascmon] == 0} {
  rlc log "  test_cmon_regs-W: no cmon unit found, test aborted"
  return
}

# reset cmon
$cpu cp -wreg cm.cntl [regbld rw11::CM_CNTL start stop] \
        -rreg cm.cntl -edata 0

# -- Section A ---------------------------------------------------------------
rlc log "  A: simple linear code, word access ------------------------"

# All src modes tested
#     mode    0    1    2    3    4    5    6    7
#   non-pc   I0   I6   I5   I8   I7   I9  I13  I14
#       pc             I3  I12            I10  I11

$cpu ldasm -lst lst -sym sym {
        . = 1000
start:  nop
I0:     clr     r0              ; m=0,rx; 
I1:     inc     r0              ; m=0,rx;
I2:     mov     r0,r1           ; m=0,rx;
I3:     mov     #a,r2           ; m=2,pc; r2->a
I4:     mov     #pa,r3          ; m=2,pc; r3->pa
I5:     mov     (r2)+,r4        ; m=2,rx; read a; r2->b
I6:     mov     (r2),r4         ; m=1,rx; read b;
I7:     mov     -(r2),r4        ; m=4,rx; read a; r2->a
I8:     mov     @(r3)+,r4       ; m=3,rx; read a; r3->pb
I9:     mov     @-(r3),r4       ; m=5,rx; read a; r3->pa
I10:    mov     a,r4            ; m=6,pc;
I11:    mov     @pb,r4          ; m=7,pc;
I12:    mov     @#a,r4          ; m=3,pc;
I13:    mov     2(r2),r4        ; m=6,rx; read b (r2->a)
I14:    mov     @2(r3),r4       ; m=7,rx; read b (r3->pa)
I15:    add     @px,@py         ; worst case, 7 accesses ...
I16:    halt
stop:
;
a:      .word   123
b:      .word   234
x:      .word   345
y:      .word   001             ; ! will be modified, re-init for 2nd pass !
pa:     .word   a
pb:     .word   b
px:     .word   x
py:     .word   y
}

# puts $lst

rlc log "    A1: run code ---------------------------------------"
$cpu cp -wma $sym(y) 1;         # re-init y !
rw11::asmrun  $cpu sym
rw11::asmwait $cpu sym 
rw11::asmtreg $cpu     r0 1 r1 1 r2 $sym(a) r3 $sym(pa) r4 0234
rw11::asmtmem $cpu $sym(y) {0346}

rlc log "    A2: test ipc,ireg ----------------------------------"

set edata {}
lappend edata $sym(start) 0000240;    # nop
lappend edata $sym(I0)    0005000;    # clr  r0
lappend edata $sym(I1)    0005200;    # inc  r0
lappend edata $sym(I2)    0010001;    # mov  r0,r1
lappend edata $sym(I3)    0012702;    # mov  #a,r2
lappend edata $sym(I4)    0012703;    # mov  #pa,r3
lappend edata $sym(I5)    0012204;    # mov  (r2)+,r4
lappend edata $sym(I6)    0011204;    # mov  (r2),r4
lappend edata $sym(I7)    0014204;    # mov  -(r2),r4
lappend edata $sym(I8)    0013304;    # mov  @(r3)+,r4
lappend edata $sym(I9)    0015304;    # mov  @-(r3),r4
lappend edata $sym(I10)   0016704;    # mov  a,r4
lappend edata $sym(I11)   0017704;    # mov  @pa,r4
lappend edata $sym(I12)   0013704;    # mov  @#a,r4
lappend edata $sym(I13)   0016204;    # mov  2(r2),r4
lappend edata $sym(I14)   0017304;    # mov  @2(r3),r4
lappend edata $sym(I15)   0067777;    # add  @pc,@pd

$cpu cp -wma $sym(y) 1;         # re-init y !
$cpu cp -stop -creset -wpc  $sym(start)

foreach {ipc ireg} $edata {
  $cpu cp -step \
          -rreg "cm.ipc"  -edata $ipc  \
          -rreg "cm.ireg" -edata $ireg
}

rlc log "    A3: test imal (memory access log) ------------------"

set edata {}
lappend edata $sym(start) {};                                   # nop
lappend edata $sym(I0)  {};                                     # clr  r0
lappend edata $sym(I1)  {};                                     # inc  r0
lappend edata $sym(I2)  {};                                     # mov  r0,r1
lappend edata $sym(I3)  [list [expr {$sym(I3)+2}] $sym(a)];     # mov  #a,r2
lappend edata $sym(I4)  [list [expr {$sym(I4)+2}] $sym(pa)];    # mov  #pa,r3
lappend edata $sym(I5)  [list $sym(a)   0123];                  # mov  (r2)+,r4
lappend edata $sym(I6)  [list $sym(b)   0234];                  # mov  (r2),r4
lappend edata $sym(I7)  [list $sym(a)   0123];                  # mov  -(r2),r4
lappend edata $sym(I8)  [list $sym(pa)  $sym(a) $sym(a)  0123]; # mov  @(r3)+,r4
lappend edata $sym(I9)  [list $sym(pa)  $sym(a) $sym(a)  0123]; # mov  @-(r3),r4
lappend edata $sym(I10) [list [expr {$sym(I10)+2}] \
                              [expr {$sym(a) - ($sym(I10)+4)}] \
                              $sym(a)   0123];                  # mov  a,r4
lappend edata $sym(I11) [list [expr {$sym(I11)+2}] \
                              [expr {$sym(pb) - ($sym(I11)+4)}] \
                              $sym(pb) $sym(b) \
                              $sym(b)   0234];                  # mov  @pa,r4
lappend edata $sym(I12) [list [expr {$sym(I12)+2}] $sym(a) \
                              $sym(a)   0123];                  # mov  @#a,r4
lappend edata $sym(I13) [list [expr {$sym(I13)+2}] 0002 \
                              $sym(b)   0234];                  # mov  2(r2),r4
lappend edata $sym(I14) [list [expr {$sym(I14)+2}] 0002 \
                              $sym(pb) $sym(b) $sym(b) 0234];   # mov  @2(r3),r4
lappend edata $sym(I15) [list [expr {$sym(I15)+2}] \
                              [expr {$sym(px) - ($sym(I15)+4)}] \
                              $sym(px) $sym(x)  $sym(x)   0345 \
                              [expr {$sym(I15)+4}] \
                              [expr {$sym(py) - ($sym(I15)+6)}] \
                              $sym(py) $sym(y)  $sym(y)   0001 \
                              $sym(y)   0346];                 # add  @px,@py

$cpu cp -wma $sym(y) 1;         # re-init y !
$cpu cp -stop -creset -wpc $sym(start)

# read ipc (to clear read pointer!)
foreach {ipc mal} $edata {
  set malcnt [llength $mal]
  set clist {}
  lappend clist -step
  lappend clist -rreg "cm.ipc"  -edata $ipc
  lappend clist -rreg "cm.stat" \
                -edata [regbldkv rw11::CM_STAT malcnt $malcnt]
  if {$malcnt > 0} {
    lappend clist -rblk "cm.imal" $malcnt -edata $mal
  }
  $cpu cp {*}$clist
}

# -- Section B ---------------------------------------------------------------
rlc log "  B: simple linear code, byte access ------------------------"

$cpu ldasm -lst lst -sym sym {
        . = 1000
start:  nop
I0:     movb    a0,r0
I1:     movb    a1,r1
I2:     movb    r0,b0
I3:     movb    r1,b1
I4:     incb    c0
I5:     incb    c1
I6:     halt
stop:
;
a0:     .byte   ^x05
a1:     .byte   ^x0a
b0:     .byte   0
b1:     .byte   0
c0:     .byte   ^x55
c1:     .byte   ^xaa
}

# puts $lst

rlc log "    B1: test imal (memory access log) ------------------"

set edata {}
lappend edata $sym(start) {};                                   # nop

lappend edata $sym(I0)  [list [expr {$sym(I0)+2}] \
                              [expr {$sym(a0) - ($sym(I0)+4)}] \
                              $sym(a0)   0x0005];               # movb a0,r0

lappend edata $sym(I1)  [list [expr {$sym(I1)+2}] \
                              [expr {$sym(a1) - ($sym(I1)+4)}] \
                              $sym(a1)   0x000a];               # movb a1,r1

lappend edata $sym(I2)  [list [expr {$sym(I2)+2}] \
                              [expr {$sym(b0) - ($sym(I2)+4)}] \
                              $sym(b0)   0x0005];               # movb r0,b0

lappend edata $sym(I3)  [list [expr {$sym(I3)+2}] \
                              [expr {$sym(b1) - ($sym(I3)+4)}] \
                              $sym(b1)   0x000a];               # movb r1,b1

lappend edata $sym(I4)  [list [expr {$sym(I4)+2}] \
                              [expr {$sym(c0) - ($sym(I4)+4)}] \
                              $sym(c0)   0x0055 \
                              $sym(c0)   0x0056];               # incb c0

lappend edata $sym(I5)  [list [expr {$sym(I5)+2}] \
                              [expr {$sym(c1) - ($sym(I5)+4)}] \
                              $sym(c1)   0x000aa \
                              $sym(c1)   0x000ab];              # incb c1

$cpu cp -stop -creset -wpc  $sym(start)

# read ipc (to clear read pointer!)
foreach {ipc data} $edata {
  set malcnt [llength $data]
  set clist {}
  lappend clist -step
  lappend clist -rreg "cm.ipc"  -edata $ipc
  lappend clist -rreg "cm.stat" \
                -edata [regbldkv rw11::CM_STAT malcnt $malcnt]
  if {$malcnt > 0} {
    lappend clist -rblk "cm.imal" $malcnt -edata $data
  }
  $cpu cp {*}$clist
}
