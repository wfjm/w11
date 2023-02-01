# $Id: rk11perf.tcl 1362 2023-01-31 18:16:17Z mueller $
# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright 2017-2023 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
#
# Revision History:
# Date         Rev Version  Comment
# 2023-01-31  1362   1.1    add more usage modes; mute CPU attn messages
# 2019-03-09  1120   1.0.1  use -wal
# 2017-05-07   895   1.0    Initial version
#
# Simple rk11 I/O performance tester
#
# Usage:
#   ti_rri --cuff --logl=2 --int --pack=rw11 -- rw11::setup_sys
#
#     source rk11perf.tcl
#     rk11perf cpu0 1000;                # full mode,nblk,code scan
#     rk11perf cpu0 1000 1;              # single run with nblk=1
#     rk11perf cpu0 -1;                  # print code and quit

proc rk11perf {{cpu cpu0} {tmax 1000} {nblk 0} {mode 0} {code 0}} {
  # mute shell CPU attention messages
  if {[info exists rw11::shell_attnhdl_muted]} {
    set rw11::shell_attnhdl_muted 1
  }
  # stop CPU and attach RAM disk image
  $cpu cp -stop
  ${cpu}rka0 att {ram:?pat=test}

  # compile and load code
  $cpu ldasm -lst lst -sym sym [rk11perf_asmcode]

  # if tmax == 0 quit, if <0 just print listing and quit
  if {$tmax == 0} { return}
  if {$tmax < 0} {
    puts $lst
    return
  }

  # if nblk defined > 0, do a single run
  if {$nblk > 0} {
    set res [rk11perf_run $cpu sym $code $mode $nblk $tmax]
    set dt  [lindex $res 0]
    set kb  [lindex $res 1]
    set cnt [lindex $res 2]
    puts [format "   dt: %5.2f  req/s: %5.0f  KB/s: %5.0f" \
                   $dt [expr {double($cnt)/$dt}] [expr {$kb/$dt}]]
    return
  }

  # otherwise, loop over mode,nblk,code and print table
  puts "     code=   'wait'       'inc r1'     'ashc ...'     'mov ...'"
  puts "    nblk   req/s  KB/s   req/s  KB/s   req/s  KB/s   req/s  KB/s"

  foreach mode {0 1} {
    puts [expr { $mode ? "write" : "read" }]
    foreach nblk {1 2 4 6 8 12 16 24 32} {
      set line [format "    %4d" $nblk]
      foreach code {0 1 2 3} {
        set res [rk11perf_run $cpu sym $code $mode $nblk $tmax]
        set dt  [lindex $res 0]
        set kb  [lindex $res 1]
        set cnt [lindex $res 2]
        append line [format "   %5.0f %5.0f" \
                       [expr {double($cnt)/$dt}] [expr {$kb/$dt}]]
      }
      puts $line
    }
  }

  $cpu cp -stop
  return
}

proc rk11perf_run {cpu symName {code 0} {mode 0} {nblk 1} {tmax 1000}} {
  upvar  1 $symName sym
  set tbeg [clock milliseconds]
  rw11::asmrun  $cpu sym r0 $code r1 $mode r2 $nblk
  after $tmax
  $cpu cp -wal $sym(t.stop) -wm 1
  $cpu wtcpu [expr $tmax/10.]
  set trun [expr {[clock milliseconds] - $tbeg}]
  $cpu cp -rpc rpc -wal $sym(t.stat) -rm rstat
  if {$rpc != $sym(stop) || $rstat != 0 } {
    error [format "rk11perf-E: abort at pc=%6.6o stat=%6.6o" $rpc $rstat]
  }
  $cpu cp -stop
  $cpu cp -wal  $sym(t.tcnt) -rmi rtcnt
  set dt [expr { double($trun)/1000. } ]
  set kb [expr { double(512.*$nblk*$rtcnt) / 1024. }]
  return [list $dt $kb $rtcnt]
}

#
# w11 test code for rk11perf test
#
proc rk11perf_asmcode {} {
  return {
;
; definitions ----------------------------------------------
;
        .include  |lib/defs_cpu.mac|
        .include  |lib/defs_rk.mac|
;
; vector area ----------------------------------------------
;
        .include  |lib/vec_cpucatch.mac|
        .include  |lib/vec_devcatch.mac|

        . = v..rk
        .word   vh.rk
        .word   cp.ars+cp.pr7   ; PR7 and use alternate registers
;
; stack area -----------------------------------------------
;
        . = 1000
stack:  
;
; data area ------------------------------------------------
;
t.code: .word   0               ; background code
t.mode: .word   0               ; mode (0=read, 1=write)
t.nblk: .word   1               ; number of blocks
t.stop: .word   0               ; stop word
t.stat: .word   0               ; return status
t.tcnt: .word   0,0             ; transfer counter
;
dach:   .word   0               ; cyc/hd disk address
;
ctbl:   .word   code0
        .word   code1
        .word   code2
        .word   code3
ctble:
cstart: .word   0
                                ;
; code area ------------------------------------------------
;
        . = 2000
start:  spl     7               ; lockout interrupts
        mov     r0,t.code       ; setup code
        mov     r1,t.mode       ; setup mode
        mov     r2,t.nblk       ; setup nblk
        clr     t.stop          ; clear stop word
        clr     t.stat          ; clear return status
        clr     t.tcnt          ; clear transfer counter
        clr     t.tcnt+2

        mov     #177777,@#cp.dsr ; sdreg: start phase marker

        tstb    @#rk.cs         ; is controller ready
        bmi     1$
        mov     #1,t.stat       ; if not, halt with stat = 1
        halt

1$:     mov     #rk.go,@#rk.cs  ; do control reset
2$:     tstb    rk.cs
        bpl     2$

        mov     #0,@#rk.da      ; select drive 0
        tstb    @#rk.ds         ; is drive ready ?
        bmi     3$
        mov     #2,t.stat       ; if not, halt with stat = 2
        halt

3$:     clr     dach
        call    rkstrt          ; start 1st transfer
        clr     @#cp.dsr        ; sdreg: end of start phase

        mov     t.code,r0       ; determine background code
        cmp     r0,#<ctble-ctbl>/2
        blo     4$
        mov     #3,t.stat       ; if not, halt with stat = 3
        halt
4$:     asl     r0
        mov     ctbl(r0),cstart
        spl     0               ; allow interrupts
                
        jmp     @cstart         ; and start background
;
; rk11 interrupt vector handler ----------------------------
;
vh.rk:  tst     @#rk.er         ; test drive error
        beq     1$
        mov     #4,t.stat       ; if any bit set, halt with stat = 4
        halt

1$:     tst     t.stop          ; test stop flag set ?
        bne     99$             ; if yes, stop (with stat = 0)
        
        inc     dach            ; increment cyl/hdr address
        cmp     dach,#620       ; beyond end of disk ? 
                                ; last cyl/hd is 0625, to allow 32 block I/Os
                                ; covering 3 cyl (with 12 sec) stop at 0620
        blos    2$              ; restart from beginning
        clr     dach
2$:     call    rkstrt
        rti

99$:    halt
stop:   halt
;
; start next rk11 io ---------------------------------------
;
rkstrt: mov     dach,r0         ; get cyl/hdr disk address
        ash     #4,r0           ; convert to chs (use sector = 0)
        mov     r0,@#rk.da

        mov     #bufdma,@#rk.ba

        mov     t.nblk,r0       ; get number of blocks 
        ash     #8.,r0          ; -> word count
        neg     r0              ; 2's complement
        mov     r0,rk.wc

        mov     #rk.ie+rk.go,r0 ; prepare command
        tst     t.mode
        bne     1$
        bis     #rk.frd,r0      ; mode==0: use read
        br      2$
1$:     bis     #rk.fwr,r0      ; mode!=0: use write
2$:     mov     r0,@#rk.cs      ; start request

        add     #1,t.tcnt       ; inc transfer count
        adc     t.tcnt+2
        mov     t.tcnt,@#cp.dsr ; show transfer count in display register
        return
;
; code 0 - wait endless loop -------------------------------
;
nwait:  .word   0
;
code0:  clr     nwait
1$:     wait
        inc     nwait
        br      1$
;
; code 1 - short instruction endless loop ------------------
;
code1:  mov     #cp.cmu,@#cp.psw  ; switch user mode PRI=0
1$:     inc     r1
        inc     r1
        inc     r1
        inc     r1
        inc     r1
        inc     r1
        inc     r1
        inc     r1
        br      1$
;
; code 2 - long instruction endless loop -------------------
;
pscnt:  .word   scnt
scnt:   .word   31.
;
code2:  mov     #cp.cmu,@#cp.psw  ; switch user mode PRI=0
1$:     ashc    @pscnt,r2
        ashc    @pscnt,r2
        ashc    @pscnt,r2
        ashc    @pscnt,r2
        ashc    @pscnt,r2
        ashc    @pscnt,r2
        ashc    @pscnt,r2
        ashc    @pscnt,r2
        br      1$
;
; code 3 - buffer copy endless loop ------------------------
; constanty copies from bufdma to bufcpy
;
code3:  mov     #cp.cmu,@#cp.psw  ; switch user mode PRI=0
1$:     mov     #bufdma,r2
        mov     #bufcpy,r3
        mov     t.nblk,r4       ; get number of blocks
        ash     #6.,r4          ; -> word count / 4 !!
2$:     mov     (r2)+,(r3)+
        mov     (r2)+,(r3)+
        mov     (r2)+,(r3)+
        mov     (r2)+,(r3)+
        sob     r4,2$
        br      1$
;
; buffers --------------------------------------------------
; Notes on buffer placement
; - w11a cache size is 8k bytes (020000)
; - the buffers are 16k bytes (040000) --> allow up to 32 block transfers
; - the dma buffer start on 044000 to avoid cache conflicts with code which
;   resides in first 004000 bytes
; - the dma and cpy buffer are separated by 16k to cause maximal cache conflict
;
        . = 044000
bufdma: .blkb 040000
bufcpy: .blkb 040000
bufend:
}
}
