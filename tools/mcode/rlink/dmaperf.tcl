# $Id: dmaperf.tcl 1194 2019-07-20 07:43:21Z mueller $
# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright 2014-2023 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
#
# Revision History:
# Date         Rev Version  Comment
# 2023-02-01  1363   1.1    add more usage modes; mute CPU attn messages
# 2014-12-28   622   1.0    Initial version
#
# Simple w11 dma tester. Uses plain wblk
#
# Usage:
#   ti_rri --cuff --logl=2 --int --pack=rw11 -- rw11::setup_cpu
#
#     source dmaperf.tcl
#     dmaperf cpu0 1000
#

proc dmaperf {{cpu "cpu0"} {tmax 100} {bsize 0} {cmd ""} {code 0}} {
  # mute shell CPU attention messages
  if {[info exists rw11::shell_attnhdl_muted]} {
    set rw11::shell_attnhdl_muted 1
  }
  # stop CPU, compile and load code
  $cpu cp -stop
  $cpu ldasm -lst lst -sym sym [dmaperf_asmcode]

  # if tmax == 0 quit, if <0 just print listing and quit
  if {$tmax == 0} { return}
  if {$tmax < 0} {
    puts $lst
    return
  }

  # if bsize defined > 0, do a single run
  if {$bsize > 0} {
    set res [dmaperf_run $cpu sym $code $cmd $bsize $tmax]
    set dt  [lindex $res 0]
    set kb  [lindex $res 1]
    set cnt [lindex $res 2]
    puts [format "   dt: %5.2f  req/s: %5.0f  KB/s: %5.0f" \
                   $dt [expr {double($cnt)/$dt}] [expr {$kb/$dt}]]
    return
  }

  puts "    bsize=     256           512          1024          1536 wrd"
  puts "    code   blk/s  KB/s   blk/s  KB/s   blk/s  KB/s   blk/s  KB/s"
  foreach cmd {"wblk" "rblk"} {
    puts "$cmd"
    foreach code {-1 0 1 2 3} {
      set line [format "    %4d" $code]
      foreach bsize {256 512 1024 1536} {
        set res [dmaperf_run $cpu sym $code $cmd $bsize $tmax]
        set dt [lindex $res 0]
        set kb [lindex $res 1]
        set i  [lindex $res 2]
        append line [format "   %5.0f %5.0f" \
                       [expr {double($i)/$dt}] [expr {$kb/$dt}]]
      }
      puts $line
    }
  }
  $cpu cp -stop
}

proc dmaperf_run {cpu symName code cmd bsize tmax} {
  upvar  1 $symName sym
  $cpu cp -stop
  if {$code >= 0} {
    rw11::asmrun  $cpu sym r0 $code
  }

  set wbuf {}
  for {set i 0} {$i < $bsize} {incr i} {
    lappend wbuf $i
  }

  set tbeg [clock milliseconds]
  
  # FIXME: hack below, use rlc exec c0.al and c0.memi; no proper rlw cp available
  for {set i 1} {1} {incr i} {
    rlc exec -wreg c0.al $sym(bufdma)
    if {$cmd eq "wblk"} {
      rlc exec -wblk c0.memi $wbuf
    } else {
      rlc exec -rblk c0.memi $bsize
    }
    set trun [expr {[clock milliseconds] - $tbeg}]
    if {$trun > $tmax} { break }
  }

  set dt [expr { double($trun)/1000. } ]
  set kb [expr { double(2.*$bsize*$i) / 1024. }]
  return [list $dt $kb $i]
}

#
# w11 test code for dmaperf test
#
proc dmaperf_asmcode {} {
  return {
        .include  |lib/vec_cpucatch.mac|
        . = 1000
stack:  
ctbl:   .word   code0
        .word   code1
        .word   code2
        .word   code3
ctble:
pscnt:  .word   scnt
scnt:   .word   31.
;
        . = 2000
start:  cmp     r0,#<ctble-ctbl>/2
        blo     1$
        halt
1$:     asl     r0
        jmp     @ctbl(r0)
;
; code 0 - wait endless loop -------------------------------
code0:  wait
        br      code0
;
; code 1 - short instruction endless loop ------------------
code1:  inc     r1
        inc     r1
        inc     r1
        inc     r1
        inc     r1
        inc     r1
        inc     r1
        inc     r1
        br      code1
;
; code 2 - long instruction endless loop -------------------
code2:  ashc    @pscnt,r2
        ashc    @pscnt,r2
        ashc    @pscnt,r2
        ashc    @pscnt,r2
        ashc    @pscnt,r2
        ashc    @pscnt,r2
        ashc    @pscnt,r2
        ashc    @pscnt,r2
        br      code2
;
; code 3 - buffer copy endless loop ------------------------
; constanty copies the first 4kbyte from bufdma to bufcpy
code3:  mov     #bufdma,r2
        mov     #bufcpy,r3
        mov     #2048.,r4
1$:     mov     (r2)+,(r3)+
        mov     (r2)+,(r3)+
        mov     (r2)+,(r3)+
        mov     (r2)+,(r3)+
        sob     r4,1$
        br      code3
;
; buffers
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
