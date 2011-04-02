# $Id: util.tcl 375 2011-04-02 07:56:47Z mueller $
#
# Copyright 2011- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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
# 2011-03-13   369   0.1    First draft
#

package provide rbmoni 1.0

package require rutil
package require rlink

namespace eval rbmoni {
  #
  # setup register descriptions for rbd_rbmon
  #
  regdsc CNTL {go 0}
  regdsc ALIM {hilim 15 8} {lolim 7 8}
  regdsc ADDR {wrap 15} {addr 10 11 "-"} {laddr 10 9} {waddr 1 2}
  #
  regdsc DAT3 {flags 15 8 "-"} {ack 15} {busy 14} {err 13} {nak 12} {tout 11} \
    {init 9} {we 8} {addr 7 8}
  regdsc DAT0 {ndlymsb 15 4} {nbusy 11 12}
  #
  # 'pseudo register', describes 1st word in return list element of rbmoni::read
  # must have same bit sequence as DAT3(flags)
  regdsc FLAGS {ack 7} {busy 6} {err 5} {nak 4} {tout 3} {init 1} {we 0} 
  #
  # setup: amap definitions for rbd_rbmon
  # 
  proc setup {{base 0x00fc}} {
    rlc amap -insert rm.cntl [expr $base + 0x00]
    rlc amap -insert rm.alim [expr $base + 0x01]
    rlc amap -insert rm.addr [expr $base + 0x02]
    rlc amap -insert rm.data [expr $base + 0x03]
  }
  #
  # init: reset rbd_rbmon (stop, reset alim)
  # 
  proc init {} {
    rlc exec \
      -wreg rm.cntl 0x0000 \
      -wreg rm.alim [regbld rbmoni::ALIM {hilim 0xff} {lolim 0x00}] \
      -wreg rm.addr 0x0000
  }
  #
  # start: start the rbmon
  #
  proc start {} {
    rlc exec -wreg rm.cntl [regbld rbmoni::CNTL go]
  }
  #
  # stop: stop the rbmon
  #
  proc stop {} {
    rlc exec -wreg rm.cntl 0x0000
  }
  #
  # read: read nent last entries (by default all)
  #
  proc read {{nent -1}} {
    set amax  [regget rbmoni::ADDR(laddr) -1]
    if {$nent == -1} { set nent $amax }

    rlc exec -rreg rm.addr raddr

    set laddr [regget rbmoni::ADDR(laddr) $raddr]
    set nval  $laddr
    if {[regget rbmoni::ADDR(wrap) $raddr]} { set nval $amax }

    if {$nent > $nval} {set nent $nval}
    if {$nent == 0} { return {} }

    set caddr [expr ( $laddr - $nent ) & $amax]
    rlc exec -wreg rm.addr [regbld rbmoni::ADDR [list laddr $caddr]]

    set rval {}

    while {$nent > 0} {
      set nblk [expr $nent << 2]
      if {$nblk > 256} {set nblk 256}
      rlc exec -rblk rm.data $nblk rawdat

      foreach {d0 d1 d2 d3} $rawdat {
        set eflag  [regget rbmoni::DAT3(flags) $d3]
        set eaddr  [regget rbmoni::DAT3(addr)  $d3]
        set edly   [expr ( [regget rbmoni::DAT0(ndlymsb) $d0] << 16 ) | $d1]
        set enbusy [regget rbmoni::DAT0(nbusy) $d0]
        lappend rval [list $eflag $eaddr $d2 $edly $enbusy]
      }

      set nent [expr $nent - ( $nblk >> 2 ) ]
    }

    rlc exec -wreg rm.addr $raddr

    return $rval
  }
  #
  # print: print rbmon data (optionally also read them)
  #
  proc print {{mondat -1}} {

    if {[llength $mondat] == 1} {
      set ele [lindex $mondat 0]
      if {[llength $ele] == 1} {
        set nent [lindex $ele 0]
        set mondat [read $nent]
      }
    }

    set rval {}

    set eind [expr 1 - [llength $mondat]]
    append rval " ind  addr       data  delay nbusy     ac bs er na to in we"

    foreach {ele} $mondat {
      foreach {eflag eaddr edata edly enbusy} $ele { break }
      set fack [regget rbmoni::FLAGS(ack)  $eflag]
      set fbsy [regget rbmoni::FLAGS(busy) $eflag]
      set ferr [regget rbmoni::FLAGS(err)  $eflag]
      set fnak [regget rbmoni::FLAGS(nak)  $eflag]
      set fto  [regget rbmoni::FLAGS(tout) $eflag]
      set fini [regget rbmoni::FLAGS(init) $eflag]
      set fwe  [regget rbmoni::FLAGS(we)   $eflag]
      set ename ""
      set comment ""
      if {$ferr} {append comment " err=1!"}
      if {$fini} {
        append comment " init"
      } else {
        if {$fnak} {append comment " nak=1!"}
      }
      if {$fto}  {append comment " tout=1!"}
      if {[rlc amap -testaddr $eaddr]} {set ename [rlc amap -name $eaddr]}
      append rval [format \
        "\n%4d  %-10s %4.4x %6d  %4d  %2.2x  %d  %d  %d  %d  %d  %d  %d %s" \
        $eind $ename $edata $edly $enbusy $eflag \
        $fack $fbsy $ferr $fnak $fto $fini $fwe $comment]
      incr eind
    }

    return $rval
  }

  #
  # raw_edata: prepare edata lists for raw data reads in tests
  #   args is list of {eflag eaddr edata enbusy} sublists

  proc raw_edata {edat emsk args} {
    upvar $edat uedat
    upvar $emsk uemsk
    set uedat {}
    set uemsk {}

    set m0 [expr 0xffff & ~[regget rbmoni::DAT0(nbusy) -1] ]
    set d1 0x0000
    set m1 0xffff
    set m3 0x0000

    foreach line $args {
      foreach {eflags eaddr edata enbusy} $line { break }
      set d0 [regbld rbmoni::DAT0 [list nbusy $enbusy]]
      if {$edata ne ""} {
        set m2 0x0000
        set d2 $edata
      } else {
        set m2 0xffff
        set d2 0x0000
      }
      set d3 [regbld rbmoni::DAT3 [list flags $eflags] [list addr $eaddr]]

      lappend uedat $d0 $d1 $d2 $d3
      lappend uemsk $m0 $m1 $m2 $m3
    }

    return ""
  }

  #
  # raw_check: check raw data against expect values prepared by raw_edata
  #
  proc raw_check {edat emsk} {

    rlc exec -estatdef 0x0 [regbld rlink::STAT {stat -1}] \
      -rreg rm.addr -edata [llength $edat] \
      -wreg rm.addr 0 \
      -rblk rm.data [llength $edat] -edata $edat $emsk \
      -rreg rm.addr -edata [llength $edat]
    return ""
  }
  
}
