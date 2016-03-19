# $Id: util.tcl 742 2016-03-13 14:40:19Z mueller $
#
# Copyright 2016- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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
# 2016-03-13   742   1.0    Initial version
# 2016-03-12   741   0.1    First draft
#

package provide rbsysmon  1.0

package require rutil
package require rutiltpp

namespace eval rbsysmon {
  #
  # setup register descriptions for sysmon_rbus
  #
  regdsc CNTL {reset 15}
  regdsc STAT {jlock 3} {jmod 2} {jbusy 1} {ot 0}
  regdsc ALM  {vccddr 6} {vccpaux 5} {vccpint 4} \
                {vccbram 3} {vccaux 2} {vccint 1} {temp 0}

  #
  # sysmon/xadc register definitions
  #
  variable regdef_current {}
  #
  variable regdef_xadc_base {
    "0x00|sm.temp|t|cur temp"
    "0x01|sm.vint|vs|cur Vccint"
    "0x02|sm.vaux|vs|cur Vccaux"
    "0x04|sm.vrefp|vs|cur Vrefp"
    "0x05|sm.vrefn|vsb|cur Vrefn"
    "0x06|sm.vbram|vs|cur Vccbram"
    "0x08|sm.supaoff|v|supply A off"
    "0x09|sm.adcaoff|vb|ADC A off"
    "0x0a|sm.adcafac|g|ADC A gain"
    "0x20|sm.tempma|t|max temp"
    "0x21|sm.vintma|vs|max Vccint"
    "0x22|sm.vauxma|vs|max Vccaux"
    "0x23|sm.vbramma|vs|max Vccbram"
    "0x24|sm.tempmi|t|min temp"
    "0x25|sm.vintmi|vs|min Vccint"
    "0x26|sm.vauxmi|vs|min Vccaux"
    "0x27|sm.vbrammi|vs|min Vccbram"
    "0x3f|sm.flag|b|flag reg"
    "0x40|sm.conf0|b|conf 0"
    "0x41|sm.conf1|b|conf 1"
    "0x42|sm.conf2|b|conf 2"
    "0x48|sm.seq00|b|select 0"
    "0x49|sm.seq01|b|select 1"
    "0x4a|sm.seq02|b|average 0"
    "0x4b|sm.seq03|b|average 1"
    "0x4c|sm.seq04|b|mode 0"
    "0x4d|sm.seq05|b|mode 1"
    "0x4e|sm.seq06|b|time 0"
    "0x4f|sm.seq07|b|time 1"
    "0x50|sm.alm00|t|temp up"
    "0x51|sm.alm01|vs|ccint up"
    "0x52|sm.alm02|vs|ccaux up"
    "0x53|sm.alm03|t|ot limit"
    "0x54|sm.alm04|t|temp low"
    "0x55|sm.alm05|vs|ccint low"
    "0x56|sm.alm06|vs|ccaux low"
    "0x57|sm.alm07|t|ot reset"
    "0x58|sm.alm08|vs|ccbram up"
    "0x5c|sm.alm0c|vs|ccbram low"
    "0x78|sm.rcntl|b|rbus cntl"
    "0x79|sm.rstat|b|rbus stat"
    "0x7a|sm.ralmh|b|rbus almh"
    "0x7c|sm.rtemp|b|rbus temp"
    "0x7d|sm.ralm|b|rbus aml"
    "0x7f|sm.reos|d|rbus eos"
  }    
  variable regdef_xadc_arty {
    "0x11|sm.v01|v|cur Vaux[1]"
    "0x12|sm.v02|v|cur Vaux[2]"
    "0x19|sm.v09|v|cur Vaux[9]"
    "0x1a|sm.v10|v|cur Vaux[10]"
  }    

  #
  # setup_xadc
  # 
  proc setup_xadc_base {{base 0xfb00}} {
    variable regdef_current
    set regdef_current $rbsysmon::regdef_xadc_base
    setup_gen $base
  }

  #
  # setup_arty
  # 
  proc setup_xadc_arty {{base 0xfb00}} {
    variable regdef_current
    set regdef_current [lsort [concat $rbsysmon::regdef_xadc_base \
                                      $rbsysmon::regdef_xadc_arty]]
    setup_gen $base
  }

  #
  # setup_gen: amap definitions for sysmon_rbus
  # 
  proc setup_gen {base} {
    variable regdef_current
    foreach def $regdef_current {
      set defp [split $def "|"]
      set off  [lindex $defp 0]
      set nam  [lindex $defp 1]
      rlc amap -insert $nam [expr {$base + $off}]
    }
  }

  #
  # reset: reset xadc/sysmon
  # 
  proc reset {} {
    rlc exec -wreg sm.rcntl [regbld rbsysmon::CNTL reset]
  }

  #
  # print_raw: show all sysmon/xadc registers
  # 
  proc print_raw {} {
    variable regdef_current
    set rval "name        description         :  hex  other"
    foreach def $regdef_current {
      set defp [split $def "|"]
      set nam  [lindex $defp 1]
      set fmt  [lindex $defp 2]
      set txt  [lindex $defp 3]
      rlc exec -rreg $nam val
      set line [format "%-10s  %-20s: %4.4x  " $nam $txt $val]
      switch $fmt {
        b       { append line [pbvi b16 $val]}
        d       { append line [format "%6d" $val]}
        t       { append line [format "%6.1f   deg" [conv_raw2t  $val]]}
        vs      { append line [format "%8.3f V"  [conv_raw2vs  $val]]}
        vsb     { append line [format "%8.3f V"  [conv_raw2vsb $val]]}
        v       { append line [format "%8.3f V"  [conv_raw2v   $val]]}
        vb      { append line [format "%8.3f V"  [conv_raw2vb  $val]]}
        g       { append line [format "%8.3f %%" [conv_raw2g   $val]]}
        default { append line "? $fmt ?" }
      }
      append rval "\n$line"
    }
    return $rval
  }

  #
  # print: nicely formatted summary
  # 
  proc print {} {
    rlc exec \
      -rreg sm.ralmh    r_almh   \
      -rreg sm.ralm     r_alm 

    set rval "Value     cur val     min val   max val   low lim  high lim  alarm"
    rlc exec \
      -rreg sm.temp     r_val   \
      -rreg sm.tempma   r_valma \
      -rreg sm.tempmi   r_valmi \
      -rreg sm.alm00    r_valup \
      -rreg sm.alm04    r_vallo 
    append rval \
      [format "\ntemp     %6.1f   d  %6.1f    %6.1f    %6.1f    %6.1f    %s" \
         [conv_raw2t  $r_val]   \
         [conv_raw2t  $r_valmi] \
         [conv_raw2t  $r_valma] \
         [conv_raw2t  $r_vallo] \
         [conv_raw2t  $r_valup] \
         [print_fmt_alm temp $r_alm $r_almh] ]

    rlc exec \
      -rreg sm.vint     r_val   \
      -rreg sm.vintma   r_valma \
      -rreg sm.vintmi   r_valmi \
      -rreg sm.alm01    r_valup \
      -rreg sm.alm05    r_vallo 
    append rval \
      [format "\nVccint   %8.3f V  %8.3f  %8.3f  %8.3f  %8.3f  %s" \
         [conv_raw2vs $r_val]   \
         [conv_raw2vs $r_valmi] \
         [conv_raw2vs $r_valma] \
         [conv_raw2vs $r_vallo] \
         [conv_raw2vs $r_valup] \
         [print_fmt_alm vccint $r_alm $r_almh] ]
              
    rlc exec \
      -rreg sm.vaux     r_val   \
      -rreg sm.vauxma   r_valma \
      -rreg sm.vauxmi   r_valmi \
      -rreg sm.alm02    r_valup \
      -rreg sm.alm06    r_vallo 
    append rval \
      [format "\nVccaux   %8.3f V  %8.3f  %8.3f  %8.3f  %8.3f  %s" \
         [conv_raw2vs $r_val]   \
         [conv_raw2vs $r_valmi] \
         [conv_raw2vs $r_valma] \
         [conv_raw2vs $r_vallo] \
         [conv_raw2vs $r_valup] \
         [print_fmt_alm vccaux $r_alm $r_almh] ]
              
    rlc exec \
      -rreg sm.vbram    r_val   \
      -rreg sm.vbramma  r_valma \
      -rreg sm.vbrammi  r_valmi \
      -rreg sm.alm08    r_valup \
      -rreg sm.alm0c    r_vallo 
    append rval \
      [format "\nVccbram  %8.3f V  %8.3f  %8.3f  %8.3f  %8.3f  %s" \
         [conv_raw2vs $r_val]   \
         [conv_raw2vs $r_valmi] \
         [conv_raw2vs $r_valma] \
         [conv_raw2vs $r_vallo] \
         [conv_raw2vs $r_valup] \
         [print_fmt_alm vccbram $r_alm $r_almh] ]
    
    if {[rlc amap -testname sm.v01]} {
      rlc exec \
        -rreg sm.v01  r_v01   \
        -rreg sm.v02  r_v02   \
        -rreg sm.v09  r_v09   \
        -rreg sm.v10  r_10
      append rval \
        [format "\nV 5V0    %8.3f V" \
           [expr { 5.99 * [conv_raw2v $r_v01]} ] ]
      append rval \
        [format "\nV VU     %8.3f V" \
           [expr { 16.0 * [conv_raw2v $r_v02]} ] ]
      append rval \
        [format "\nA 5V0    %8.3f A" \
           [expr { 4.0  * [conv_raw2v $r_v09]} ] ]
      append rval \
        [format "\nA 0V95   %8.3f A" \
           [expr { 2.0  * [conv_raw2v $r_v09]} ] ]
    }
              
    return $rval
  }

  #
  # helper for print
  #
  proc print_fmt_alm {chan alm almh} {
    set cval [regget rbsysmon::ALM($chan) $alm]
    set hval [regget rbsysmon::ALM($chan) $almh]
    set cstr [expr {$cval ? "C!" : "  "}]
    set hstr [expr {$cval ? "H!" : "  "}]
    return "$cstr $hstr"
  }

  #
  # conversion procedures
  # 
  proc conv_raw2t {val} {
    return [expr {(($val / 65536.) * 503.975) - 273.14}]
  }
  proc conv_raw2vs {val} {
    return [expr {($val / 65536.) * 3.}]
  }
  proc conv_raw2vsb {val} {
    set val [rutil::sxt16 $val]
    return [expr {($val / 65536.) * 3.}]
  }
  proc conv_raw2v {val} {
    return [expr {$val / 65536.}]
  }
  proc conv_raw2vb {val} {
    set val [rutil::sxt16 $val]
    return [expr {$val / 65536.}]
  }
  proc conv_raw2g {val} {
    set gmag [expr {$val & 0x3f}]; # get 6 lsbs
    set gsig [expr {$val & 0x40}]; # get sign bit
    set gain [expr {$gmag * 0.1}]; # unit is 0.1 %
    if {$gsig == 0} {set gain [expr {-$gain}] }
    return $gain
  }

  #
  # eosrate: returns eos rate (in Hz)
  # 
  proc eosrate {} {
    rlc exec -rreg sm.reos r_eosbeg
    set tbeg [clock microseconds]
    after 100
    rlc exec -rreg sm.reos r_eosend
    set tend [clock microseconds]
    set deos [expr {$r_eosend - $r_eosbeg}]
    if {$deos < 0} {set deos [expr {$deos + 65536}]}
    set dt [expr {($tend - $tbeg) * 1.e-6} ]
    return [expr {$deos / $dt}]
  }
}
