# $Id: dmhbpt.tcl 883 2017-04-22 11:57:38Z mueller $
#
# Copyright 2015-2017 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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
# 2017-04-22   833   1.0.1  hb_set: use imap_range2addr, allow regnam and range
# 2015-07-17   701   1.0    Initial version
# 2015-07-05   697   0.1    First draft
#

package provide rw11 1.0

package require rlink
package require rwxxtpp

namespace eval rw11 {
  #
  # setup dmhbpt unit register descriptions for w11a -------------------------
  #
  regdsc HB_CNTL {mode 5 2} {irena 2} {dwena 1} {drena 0}
  regdsc HB_STAT {irseen 2} {dwseen 1} {drseen 0}

  #
  # hb_set: set breakpoint
  #
  proc hb_set {cpu unit type lo {hi ""} } {
    hb_ucheck $cpu $unit
    if {![regexp {^[ksu]?[rwi]+$} $type]} {
      error "hb_set-E: bad type '$type', only ksu and iwr allowed"
    }
    set irena [string match *i* $type]
    set dwena [string match *w* $type]
    set drena [string match *r* $type]
    set mode 2
    if {[string match *k* $type]} {set mode 0}
    if {[string match *s* $type]} {set mode 1}
    if {[string match *u* $type]} {set mode 3}

    set aran [rw11::imap_range2addr $cpu $lo $hi]
    set lolim [lindex $aran 0]
    set hilim [lindex $aran 1]
    
    $cpu cp -wreg "hb${unit}.cntl" \
                 [regbld rw11::HB_CNTL [list mode  $mode] \
                                       [list irena $irena] \
                                       [list dwena $dwena] \
                                       [list drena $drena] ] \
            -wreg "hb${unit}.stat"  0      \
            -wreg "hb${unit}.hilim" $hilim \
            -wreg "hb${unit}.lolim" $lolim
    return ""
  }

  #
  # hb_remove: remove breakpoint
  #
  proc hb_remove {cpu {unit -1}} {
    if {$unit >= 0} {
      hb_ucheck $cpu $unit
      set ulist [list $unit]
    } else {
      set ulist {}
      set nmax [$cpu get hashbpt]
      for {set i 0} {$i<$nmax} {incr i} {lappend ulist $i}
    }
    set clist {}
    foreach i $ulist {
      lappend clist -wreg "hb${i}.cntl"  0 
      lappend clist -wreg "hb${i}.stat"  0
      lappend clist -wreg "hb${i}.hilim" 0
      lappend clist -wreg "hb${i}.lolim" 0
    }
    $cpu cp {*}$clist
    return ""
  }

  #
  # hb_clear: clear breakpoint status
  #
  proc hb_clear {cpu {unit -1}} {
    if {$unit >= 0} {
      hb_ucheck $cpu $unit
      $cpu cp -wreg "hb${unit}.stat"  0
    } else {
      set nbpt [$cpu get hashbpt]
      if {$nbpt > 0} {
        set clist {}
        for {set i 0} {$i < $nbpt} {incr i} {
          lappend clist -wreg "hb${i}.stat"  0
        }
        $cpu cp {*}$clist
      }
    }
    return ""
  }

  #
  # hb_list: list breakpoints
  #
  proc hb_list {cpu {unit -1}} {
    set nmax [$cpu get hashbpt]
    set rval ""
    for {set i 0} {$i<$nmax} {incr i} {
      if {$i>0} {append rval "\n"}
      append rval "hb${i}: "
      append rval [hb_show $cpu $i]
    }
    return $rval
  }

  #
  # hb_show: show single breakpoint
  #
  proc hb_show {cpu unit} {
    hb_ucheck $cpu $unit
    $cpu cp -rreg "hb${unit}.cntl"  cntl  \
            -rreg "hb${unit}.stat"  stat  \
            -rreg "hb${unit}.hilim" hilim \
            -rreg "hb${unit}.lolim" lolim
    set p_cntl [lindex {"k" "s" " " "u"} [regget rw11::HB_CNTL(mode) $cntl] ]
    if {[regget rw11::HB_CNTL(irena) $cntl]} {append p_cntl "i"}
    if {[regget rw11::HB_CNTL(dwena) $cntl]} {append p_cntl "w"}
    if {[regget rw11::HB_CNTL(drena) $cntl]} {append p_cntl "r"}
    set p_stat ""
    if {[regget rw11::HB_STAT(irseen) $stat]} {append p_stat "i"}
    if {[regget rw11::HB_STAT(dwseen) $stat]} {append p_stat "w"}
    if {[regget rw11::HB_STAT(drseen) $stat]} {append p_stat "r"}
    set rval ""
    if {$cntl == 0} {
      append rval "type: off"
    } else {
      append rval [format   "type: %-4s" $p_cntl]
      append rval [format "  seen: %-3s" $p_stat]
      append rval [format "  lim: %6.6o" $lolim]
      if {$lolim!=$hilim} {append rval [format " : %6.6o" $hilim]}
    }
    return $rval
  }

  #
  # hb_check: check for valid unit number
  #
  proc hb_ucheck {cpu unit} {
    if {$unit < 0 || $unit >= [$cpu get hashbpt]} {
      error "hb_..-E: '$unit' out of range"
    }
    return ""
  }
}
