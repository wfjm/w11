# $Id: util.tcl 985 2018-01-03 08:59:40Z mueller $
#
# Copyright 2011-2017 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
#
# This program is free software; you may redistribute and/or modify it under
# the terms of the GNU General Public License as published by the Free
# Software Foundation, either version 3, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY, without even the implied warranty of MERCHANTABILITY
# or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
# for complete details.
#
#  Revision History:
# Date         Rev Version  Comment
# 2017-06-19   914   1.3    17bit support; use sstat(awidth); add isnarrow
# 2017-04-22   883   1.2.1  setup: now idempotent
# 2016-07-09   784   1.2    22bit support: mask sstat(wide); add iswide
# 2015-04-03   661   1.1    drop estatdef (stat err check default now)
# 2014-08-14   582   1.0.1  add srun* procs; add nscmd and tout variables
# 2014-08-10   581   1.0    Initial version
# 2011-07-03   387   0.1    Frist draft
#

package provide tst_sram 1.0

package require rutiltpp
package require rutil
package require rlink

namespace eval tst_sram {
  # name space variables
  #
  variable nscmd 0;             # length of current sequencer command list
  variable tout 10.;            # default time out
  variable iswide   -1;         # sstat.awidth=22 cache
  variable isnarrow -1;         # sstat.awidth=17 cache
  #
  # setup register descriptions for tst_sram core design ---------------------
  # 
  regdsc MCMD  {ld 14} {inc 13} {we 12} {be 11 4} {addrh 5 6}
  regdsc SSTAT {awidth 15 3} {wswap 9} {wloop 8} \
               {loop 7} {xord 6} {xora 5} {veri 4} {fail 1} {run 0}
  regdsc SCMD  {wait 31 4} {we 24} {be 23 4} {addr 17 18}
  #
  # setup: amap definitions for tst_sram core design -------------------------
  # 
  proc setup {{base 0x0000}} {
    if {[rlc amap -testname sr.mdih $base]} {return}
    rlc amap -insert sr.mdih   [expr {$base + 0x00}]
    rlc amap -insert sr.mdil   [expr {$base + 0x01}]
    rlc amap -insert sr.mdoh   [expr {$base + 0x02}]
    rlc amap -insert sr.mdol   [expr {$base + 0x03}]
    rlc amap -insert sr.maddrh [expr {$base + 0x04}]
    rlc amap -insert sr.maddrl [expr {$base + 0x05}]
    rlc amap -insert sr.mcmd   [expr {$base + 0x06}]
    rlc amap -insert sr.mblk   [expr {$base + 0x07}]
    rlc amap -insert sr.slim   [expr {$base + 0x08}]
    rlc amap -insert sr.saddr  [expr {$base + 0x09}]
    rlc amap -insert sr.sblk   [expr {$base + 0x0a}]
    rlc amap -insert sr.sblkc  [expr {$base + 0x0b}]
    rlc amap -insert sr.sblkd  [expr {$base + 0x0c}]
    rlc amap -insert sr.sstat  [expr {$base + 0x0d}]
    rlc amap -insert sr.sstart [expr {$base + 0x0e}]
    rlc amap -insert sr.sstop  [expr {$base + 0x0f}]
    rlc amap -insert sr.seaddr [expr {$base + 0x10}]
    rlc amap -insert sr.sedath [expr {$base + 0x11}]
    rlc amap -insert sr.sedatl [expr {$base + 0x12}]
  }
  #
  # init: reset tst_sram -----------------------------------------------------
  # 
  proc init {} {
    rlc exec \
      -wreg sr.sstop 1 \
      -wreg sr.sstat 0
  }
  #
  # checkawidth: inspect SSTAT(awidth) ---------------------------------------
  # 
  proc checkawidth {} {
    variable iswide
    variable isnarrow
    rlc exec -rreg sr.sstat sstat
    set awidth [regget tst_sram::SSTAT(awidth) $sstat]
    set iswide   [expr {$awidth + 16 == 22}]
    set isnarrow [expr {$awidth + 16 == 17}]
    return ""
  }
  #
  # iswide: 1 if 22bit system ------------------------------------------------
  # 
  proc iswide {} {
    variable iswide
    if {$iswide < 0} { checkawidth }
    return $iswide
  }
  #
  # isnarrow: 1 if 17bit system ----------------------------------------------
  # 
  proc isnarrow {} {
    variable isnarrow
    if {$isnarrow < 0} { checkawidth }
    return $isnarrow
  }
  #
  # scmd_write: write a scmd list --------------------------------------------
  # 
  proc scmd_write {scmdlist} {
    variable nscmd
    set buf {}
    set nscmd 0
    rlc exec -wreg sr.saddr 0

    foreach scmditem $scmdlist {
      set wait [lindex $scmditem 0]
      set wec  [lindex $scmditem 1]
      set bec  [lindex $scmditem 2]
      set addr [lindex $scmditem 3]
      set mval [lindex $scmditem 4]
      set we   [expr {($wec eq "w") ? 1 : 0}]
      set scmd [regbld tst_sram::SCMD \
                  [list wait $wait] \
                  [list we $we] \
                  [list be [bvi b $bec]] \
                  [list addr $addr] ]
      set scmdh [expr {($scmd>>16) & 0xffff}]
      set scmdl [expr { $scmd      & 0xffff}]
      set mvalh [expr {($mval>>16) & 0xffff}]
      set mvall [expr { $mval      & 0xffff}]
      lappend buf $scmdh $scmdl $mvalh $mvall
      if {[llength $buf] == 256} {
        rlc exec -wblk sr.sblk $buf
        set buf {}
      }
      incr nscmd
    }
    if {[llength $buf] > 0} {
      rlc exec -wblk sr.sblk $buf
    }
    return
  }

  #
  # scmd_read:  read a scmd list ---------------------------------------------
  # 
  proc scmd_read {length} {
    set scmdlist {}
    if {$length == 0} {return $scmdlist}

    rlc exec -rreg sr.saddr saddr_save \
             -wreg sr.saddr 0
    while {$length > 0} {
      set chunk $length
      if {$chunk > 64} {set chunk 64}
      set length [expr {$length - $chunk}]
      rlc exec -rblk sr.sblk [expr {4*$chunk}] buf
      foreach {scmdh scmdl mvalh mvall} $buf {
        set scmd [expr {($scmdh<<16) | $scmdl}]
        set mval [expr {($mvalh<<16) | $mvall}]
        set wait [regget tst_sram::SCMD(wait) $scmd]
        set we   [regget tst_sram::SCMD(we)   $scmd]
        set be   [regget tst_sram::SCMD(be)   $scmd]
        set addr [regget tst_sram::SCMD(addr) $scmd]
        set wec  [expr {($we) ? "w" : "r"}]
        set bec  [pbvi b4 $be]
        lappend scmdlist [list $wait $wec $bec $addr $mval]
      }
    }
    rlc exec -wreg sr.saddr $saddr_save
    return $scmdlist
  }

  #
  # scmd_print:  print a scmd list -------------------------------------------
  # 
  proc scmd_print {scmdlist} {
    set rval " ind: dly we   be      addr        mval"
    set ind 0
   foreach scmditem $scmdlist {
     set wait [lindex $scmditem 0]
     set wec  [lindex $scmditem 1]
     set bec  [lindex $scmditem 2]
     set addr [lindex $scmditem 3]
     set mval [lindex $scmditem 4]
     append rval "\n"
     append rval [format "%4d:  %2d  %s %s  0x%6.6x  0x%8.8x" \
                    $ind $wait $wec $bec $addr $mval]
     incr ind
    }
    return $rval
  }

  #
  # srun: single pass run of sequencer ---------------------------------------
  # 
  proc srun {mdih mdil maddrh maddrl {tout 0.}} {
    variable nscmd
    if {$tout == 0}  {set tout $tst_sram::tout}
    if {$nscmd == 0} {error "no or empty scmd list loaded"}
    set sm [rutil::com16 [regbld tst_sram::SSTAT {awidth -1}]]
    rlc exec -init 0 1
    rlc exec -wreg sr.sstat [regbld tst_sram::SSTAT xord xora veri] \
             -wreg sr.mdih   $mdih \
             -wreg sr.mdil   $mdil \
             -wreg sr.maddrh $maddrh \
             -wreg sr.maddrl $maddrl \
             -wreg sr.slim   [expr {$nscmd-1}] \
             -wreg sr.sstart 0x0000
    rlc wtlam $tout
    rlc exec -attn -edata 0x0001
    rlc exec -rreg sr.sstat  -edata [regbld tst_sram::SSTAT xord xora veri] $sm \
             -rreg sr.seaddr -edata 0x0000 \
             -rreg sr.sedath -edata 0x0000 \
             -rreg sr.sedatl -edata 0x0000
    return
  }
  #
  # srun_lists: call srun for mdi and maddr lists ----------------------------
  # 
  proc srun_lists {lmdi lmaddr {tout 0.}} {
    foreach {maddrh maddrl} $lmaddr {
      foreach {mdih mdil} $lmdi {
        srun $mdih $mdil $maddrh $maddrl $tout
      }
    }
    return
  }
  #
  # srun_loop: full maddr* loop of sequencer ---------------------------------
  # 
  proc srun_loop {mdih mdil maddrh maddrl {wide 0} {tout 0.}} {
    variable nscmd
    if {$tout == 0}  {set tout $tst_sram::tout}
    if {$nscmd == 0} {error "no or empty scmd list loaded"}
    set sm [rutil::com16 [regbld tst_sram::SSTAT {awidth -1}]]
    set sstat [regbldkv tst_sram::SSTAT wswap $wide wloop $wide loop 1 \
                                        xord 1 xora 1 veri 1]
    rlc exec -init 0 1
    rlc exec -wreg sr.sstat  $sstat  \
             -wreg sr.mdih   $mdih   \
             -wreg sr.mdil   $mdil   \
             -wreg sr.maddrh $maddrh \
             -wreg sr.maddrl $maddrl \
             -wreg sr.slim   [expr {$nscmd-1}] \
             -wreg sr.sstart 0x0000

    set tbeg [clock milliseconds]
    rlc wtlam $tout
    set tend [clock milliseconds]

    rlc exec -attn -edata 0x0001
    rlc exec -rreg sr.sstat  -edata $sstat $sm \
             -rreg sr.seaddr -edata 0x0000 \
             -rreg sr.sedath -edata 0x0000 \
             -rreg sr.sedatl -edata 0x0000

    set trun [expr {($tend-$tbeg)/1000.}]
    set line [format "loop done maddr=%2.2x %4.4x mdi=%4.4x %4.4x in %7.2f s" \
                $maddrh $maddrl $mdih $mdil $trun]
    rlc log $line
    return
  }
}

