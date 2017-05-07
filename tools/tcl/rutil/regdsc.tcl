# $Id: regdsc.tcl 895 2017-05-07 07:38:47Z mueller $
#
# Copyright 2011-2015 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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
# 2016-01-03   724   1.1.1  BUGFIX: regdsc: fix variable name in error msg
# 2015-07-24   705   1.1    add regbldkv,reggetkv; regtxt: add {all 0} arg
#                           add s:.. ptyp to support symbolic field values
# 2015-06-26   695   1.0    Initial version (with reg* procs from util.tcl)
#

package provide rutil 1.0

package require rutiltpp

namespace eval rutil {
  #
  # regdsc: setup a register descriptor --------------------------------------
  #
  proc regdsc {rdscName args} {
    upvar $rdscName rdsc
    set fbegmax -1
    set mskftot 0
    
    foreach arg $args {
      set nopt [llength $arg]
      if {$nopt < 2 || $nopt > 4} { 
        error "regdsc-E: wrong number of elements in field dsc \"$arg\"" 
      }
      set fnam [lindex $arg 0]
      set fbeg [lindex $arg 1]
      set flen [lindex $arg 2]
      if {$nopt < 3} { set flen 1 }
      set ptyp [lindex $arg 3]
      if {$nopt < 4} { set ptyp "b" }
      set popt {}
      set plen 0

      set mskb [expr {( 1 << $flen ) - 1}]
      set mskf [expr {$mskb << ( $fbeg - ( $flen - 1 ) )}]

      if {[string match "s:*" $ptyp]} {
        set popt [lrange [split $ptyp ":"] 1 end]
        set ptyp "s"
        if { [llength $popt] != ( 1 << $flen ) } {
          error "regdsc-E: bad value count for for \"$rdscName:$fnam\""
        }
        foreach nam $popt {
          if {![string match {[A-Za-z]*} $nam]} {
            error "regdsc-E: bad name \"$nam\" for for \"$rdscName:$fnam\""
          }
          set nlen [string length $nam]
          if {$nlen > $plen} {set plen $nlen}
        }
        lappend popt $plen

      } else {
        switch $ptyp {
          b       {}
          o       -
          x       {set plen [string length [format "%${ptyp}" $mskb]]
                   set popt "%${plen}.${plen}${ptyp}"}
          d       {set plen [string length [format "%d" $mskb]]
                   set popt "%${plen}d"}
          -       {}
          default {error "regdsc-E: bad ptyp \"$ptyp\" for \"$rdscName:$fnam\""}
        }
      }
      
      if {( $flen - 1 ) > $fbeg} {
        error "regdsc-E: bad field dsc \"$arg\": length > start position" 
      }
      
      set rdsc($fnam) [list $fbeg $flen $mskb $mskf $ptyp $popt]
      
      if {$fbegmax < $fbeg} {set fbegmax $fbeg}
      set mskftot [expr {$mskftot | $mskf}]
    }

    set rdsc(-n) [lsort -decreasing -command regdsc_sort \
                    [array names rdsc -regexp {^[^-]}] ]
    
    set rdsc(-w) [expr {$fbegmax + 1}]
    set rdsc(-m) $mskftot

    return
  }

  proc regdsc_sort {a b} {
    upvar rdsc urdsc
    return [expr {[lindex $urdsc($a) 0] - [lindex $urdsc($b) 0] }]
  }

  #
  # regdsc_print: print register descriptor ----------------------------------
  #
  proc regdsc_print {rdscName} {
    upvar $rdscName rdsc
    set rval ""
    if {! [info exists rdsc]} { 
      error "can't access \"$rdscName\": variable doesn't exist" 
    }

    set rsize $rdsc(-w)

    append rval "     field   bits  bitmask"

    foreach fnam $rdsc(-n) {
      set fdsc  $rdsc($fnam)
      set fbeg  [lindex $fdsc 0]
      set flen  [lindex $fdsc 1]
      set fmskf [lindex $fdsc 3]
      set ptyp  [lindex $fdsc 4]
      set popt  [lindex $fdsc 5]
      set line "  "
      append line [format "%8s" $fnam]
      if {$flen > 1} {
        append line [format "  %2d:%2d" $fbeg [expr {$fbeg - $flen + 1}]]
      } else {
        append line [format "     %2d" $fbeg]
      }
      append line "  "
      append line [pbvi "b${rsize}" $fmskf]
      if {$ptyp eq "s"} {
        append line " " [join [lrange $popt 0 end-1] ":"] 
      } else {
        if {$popt ne ""} {append line "  $popt"}
      }
      append rval "\n$line"
    }
    return $rval
  }

  #
  # regbld: build a register value from list of keys or {key val} pairs ------
  #
  proc regbld {rdscName args} {
    upvar $rdscName rdsc
    set kvl {}
    foreach arg $args {
      set narg [llength $arg]
      if {$narg < 1 || $narg > 2} {
        error "regbld-E: field specifier \"$arg\": must be 'name \[val\]'"
      }
      set fnam [lindex $arg 0]
      if {! [info exists rdsc($fnam)] } {
        error "regbld-E: field specifier \"$arg\": field unknown"
      }

      set fval 1
      if {$narg == 1} {
        set flen [lindex $rdsc($fnam) 1]
        if {$flen > 1} {
          error "regbld-E: field specifier \"$arg\": no value and flen>1"
        }
      } else {
        set fval [lindex $arg 1]
      } 
      lappend kvl $fnam $fval
    }
    return [regbldkv rdsc {*}$kvl]
  }

  #
  # regbldkv: build a register value from key value list ---------------------
  #
  proc regbldkv {rdscName args} {
    upvar $rdscName rdsc
    if {[llength $args] % 2 != 0} {
      error "regbldkv-E: odd number of optional key value args"
    }

    set rval 0
    foreach {fnam fval} $args {
      if {! [info exists rdsc($fnam)] } {
        error "regbldkv-E: field specifier \"$fnam\": field unknown"
      }
      set fbeg [lindex $rdsc($fnam) 0]
      set flen [lindex $rdsc($fnam) 1]      
      set mskb [lindex $rdsc($fnam) 2]
      set ptyp [lindex $rdsc($fnam) 4]
      set popt [lindex $rdsc($fnam) 5]

      if {$ptyp eq "s" && ! [string is integer $fval]} {
        set nind [lsearch [lrange $popt 0 end-1] $fval]
        if {$nind < 0} {
          error "regbldkv-E: \"$fval\" unknown value name for \"$fnam\""
        }
        set fval $nind
      }

      if {$fval >= 0} {
        if {$fval > $mskb} {
          error "regbldkv-E: field specifier \"$fnam\": $fval > $mskb"
        }
      } else {
        if {$fval < [expr {- $mskb}]} {
          error "regbldkv-E: field specifier \"$fnam\": $fval < -$mskb]"
        }
        set fval [expr {$fval & $mskb}]
      }
      set rval [expr {$rval | $fval << ( $fbeg - ( $flen - 1 ) )}]

    }
    return $rval
  }

  #
  # regget: extract field from a register value ------------------------------
  #
  proc regget {fdscName val} {
    upvar $fdscName fdsc
    if {! [info exists fdsc] } {
      error "regget-E: field descriptor \"$fdscName\" unknown"
    }
    set fbeg [lindex $fdsc 0]
    set flen [lindex $fdsc 1]
    set mskb [lindex $fdsc 2]
    return [expr {( $val >> ( $fbeg - ( $flen - 1 ) ) ) & $mskb}]
  }

  #
  # reggetkv: extract multiple fields to variables ---------------------------
  #
  proc reggetkv {rdscName val pref args} {
    upvar $rdscName rdsc
    if {[llength $args] == 0} {set args "*"}
    foreach kpat $args {
      set nvar 0
      foreach key [array names rdsc $kpat] {
        if {[string match -* $key]} {continue}
        upvar "${pref}${key}" var
        set var [regget "rdsc($key)" $val]
        incr nvar
      }
      if {$nvar == 0} {
        error "reggetkv-E: no match for field name pattern \"$kpat\"" 
      }
    }
  }

  #
  # regtxt: convert register value to a text string --------------------------
  #   Note: mode currently only "" and "a" (show all fields) allowed
  #         maybe later also "th" (table head) and "tr" (table row)
  # 
  proc regtxt {rdscName val {mode ""}} {
    upvar $rdscName rdsc
    set rval ""

    foreach fnam $rdsc(-n) {
      set flen [lindex $rdsc($fnam) 1]
      set ptyp [lindex $rdsc($fnam) 4]
      set popt [lindex $rdsc($fnam) 5]
      set fval [regget rdsc($fnam) $val]

      if {$ptyp eq "-" || ($ptyp ne "s" && $fval == 0 && $mode eq "")} {continue}

      if {$rval ne ""} {append rval " "}
      append rval "${fnam}"
      if {$ptyp eq "b" && $flen == 1 && $mode eq ""} {continue}        
      append rval ":"

      if {$ptyp eq "s"} {
        set plen [lindex $popt end]
        append rval [format "%-${plen}s" [lindex $popt $fval]]
      } elseif {$ptyp eq "b"} {
        append rval [pbvi b${flen} $fval]
      } else {
        append rval [format "${popt}" $fval]
      }
    }
    return $rval
  }

  #
  # ! export reg... procs to global scope ------------------------------------
  #

  namespace export regdsc
  namespace export regdsc_print
  namespace export regbld
  namespace export regbldkv
  namespace export regget
  namespace export reggetkv
  namespace export regtxt
}

namespace import rutil::regdsc
namespace import rutil::regdsc_print
namespace import rutil::regbld
namespace import rutil::regbldkv
namespace import rutil::regget
namespace import rutil::reggetkv
namespace import rutil::regtxt
