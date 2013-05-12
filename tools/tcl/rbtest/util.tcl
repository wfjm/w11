# $Id: util.tcl 516 2013-05-05 21:24:52Z mueller $
#
# Copyright 2011-2013 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
#
# This program is free software; you may redistribute and/or modify it under
# the terms of the GNU General Public License as published by the Free
# Software Foundation, either version 2, or at your option any later version.
#
# This program is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY, without even the implied warranty of MERCHANTABILITY
# or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
# for complete details.
#
#  Revision History:
# Date         Rev Version  Comment
# 2011-03-27   374   1.0    Initial version
# 2011-03-13   369   0.1    Frist draft
#

package provide rbtest 1.0

package require rutiltpp
package require rutil
package require rlink

namespace eval rbtest {
  #
  # setup register descriptions for rbd_tester
  # 
  regdsc CNTL {nofifo 15} {stat 14 3} {nbusy 9 10}
  regdsc INIT {fifo 2} {data 1} {cntl 0}
  #
  # setup: amap definitions for rbd_tester
  # 
  proc setup {{base 0x00f0}} {
    rlc amap -insert te.cntl [expr {$base + 0x00}]
    rlc amap -insert te.data [expr {$base + 0x01}]
    rlc amap -insert te.fifo [expr {$base + 0x02}]
    rlc amap -insert te.attn [expr {$base + 0x03}]
  }
  #
  # init: reset rbd_tester (clear via init)
  # 
  proc init {} {
    rlc exec -init te.cntl [regbld rbtest::INIT fifo data cntl]
  }
  #
  # nbusymax: returns maximal nbusy value not causing timeout
  # 
  proc nbusymax {} {
    set esdmsk [regbld rlink::STAT {stat -1} attn]
    rlc exec -estatdef 0 $esdmsk \
      -rreg te.cntl sav_cntl \
      -wreg te.cntl [regbld rbtest::CNTL {nbusy -1}] \
      -rreg te.data -estat [regbld rlink::STAT rbnak] $esdmsk \
      -rreg te.attn ncyc
    rlc exec -estatdef 0 $esdmsk \
      -wreg te.cntl $sav_cntl
    return [expr {$ncyc - 1}]
  }
  #
  # probe: determine rbd_tester environment (max nbusy, stat and attn wiring)
  #
  proc probe {} {
    set esdval    0x00
    set esdmsk    [regbld rlink::STAT {stat -1}]
    set esdmsknak [regbld rlink::STAT {stat -1} rbnak]
    set esdmskatt [regbld rlink::STAT {stat -1} attn]
    set rbusy {}
    set rstat {}
    set rattn {}
    #
    # probe max nbusy for write and read
    #
    set wrerr {}
    set rderr {}
    for {set i 3} { $i < 8 } {incr i} {
      set nbusy0 [expr {( 1 << $i )}]
      for {set j -1} { $j <= 1 } {incr j} {
        set nbusy [expr {$nbusy0 + $j}]
        set valc  [regbld rbtest::CNTL [list nbusy $nbusy]]
        rlc exec \
          -wreg te.cntl $valc  -estat $esdval $esdmsk\
          -wreg te.data 0x0000 statwr -estat $esdval $esdmsknak \
          -rreg te.data dummy  statrd -estat $esdval $esdmsknak
        if {[llength $wrerr] == 0 && [regget rlink::STAT(rbnak) $statwr] != 0} {
          lappend wrerr $i $j $nbusy
        }
        if {[llength $rderr] == 0 && [regget rlink::STAT(rbnak) $statrd] != 0} {
          lappend rderr $i $j $nbusy
        }
      }
    }
    rlc exec -init te.cntl [regbld rbtest::INIT fifo data cntl]
    lappend rbusy $wrerr $rderr
    #
    # probe stat wiring
    #
    for {set i 0} { $i < 3 } {incr i} {
      set valc [regbld rbtest::CNTL [list stat [expr {1 << $i}]]]
      rlc exec -estatdef $esdval $esdmsk \
        -wreg te.cntl $valc \
        -rreg te.data dummy statrd
      lappend rstat [list $i [regget rlink::STAT(stat) $statrd]]
    }
    rlc exec -init te.cntl [regbld rbtest::INIT fifo data cntl]
    #
    # probe attn wiring
    #
    rlc exec -attn
    for {set i 0} { $i < 16 } {incr i} {
      rlc exec -estatdef $esdval $esdmskatt \
        -wreg te.attn [expr {1 << $i}] \
        -attn attnpat
      lappend rattn [list $i $attnpat]
    }
    rlc exec -attn
    #
    return [list $rbusy $rstat $rattn]
  }
  #
  # probe_print: print probe results
  #
  proc probe_print {{plist {}}} {
    set rval {}

    if {[llength $plist] == 0} {
      set plist [probe]
    }

    set rbusy [lindex $plist 0]
    set rstat [lindex $plist 1]
    set rattn [lindex $plist 2]
    #
    append rval \
      "nbusy: write max [lindex $rbusy 0 2] --> WIDTH=[lindex $rbusy 0 0]"
    append rval \
      "\nnbusy:  read max [lindex $rbusy 1 2] --> WIDTH=[lindex $rbusy 1 0]"
    #
    for {set i 0} { $i < 3 } {incr i} {
      set rcvpat [lindex $rstat $i 1]
      set rcvind [print_bitind $rcvpat]
      append rval [format "\nstat:  te.cntl line %2d --> design %2d %s" \
            $i $rcvind [pbvi b3 $rcvpat]]
    }
    #
    for {set i 0} { $i < 16 } {incr i} {
      set rcvpat [lindex $rattn $i 1]
      set rcvind [print_bitind $rcvpat]
      append rval [format "\nattn:  te.attn line %2d --> design %2d %s" \
            $i $rcvind [pbvi b16 $rcvpat]]
    }
    return $rval
  }

  #
  # print_bitind: helper for probe_print:
  #
  proc print_bitind {pat} {
    for {set i 0} { $i < 16 } {incr i} {
      if {[expr {$pat & [expr {1 << $i}] }] } { return $i}
    }
    return -1
  }
}
