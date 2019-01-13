# $Id: util.tcl 1103 2019-01-04 13:18:54Z mueller $
#
# Copyright 2018-2019 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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
# 2019-01-04  1103   1.0.2  add defs for CNTL cmd field
# 2019-01-02  1101   1.0.1  test_rwait: add optional lena argument
# 2018-12-28  1096   1.0    Initial version
# 2018-12-24  1093   0.1    First draft
#

package provide tst_mig 1.0

package require rutiltpp
package require rutil
package require rlink

namespace eval tst_mig {
  # name space variables
  #
  variable mawidth -1;          # memory address width
  variable mwidth  -1;          # memory mask width (8 or 16 for 64 or 128 bit)
  variable iswide  -1;          # 128 bit interface
  variable initime -1;          # initial initime
  #
  # setup register descriptions for tst_mig core design ----------------------
  # 
  regdsc CNTL  {cmd 15 3 "s:WR:RD:F2:F3:F4:F5:F6:F7"} \
               {wren 12} {dwend 11} \
               {func 3 4 \
            "s:NOOP:RD:WR:PAT:REF:CAL:CMD:WREN:F8:F9:F10:F11:F12:F13:F14:F15"}
  regdsc STAT  {zqpend 6} {refpend 5} {rdend 4} \
               {uirst 3} {caco 2} {wrdy 1} {crdy 0}
  regdsc CONF  {mawidth 9 5} {mwidth 4 5}
  regdsc IRCNT {rstcnt 15 8} {inicnt 7 8}
  #
  # setup: amap definitions for tst_mig core design --------------------------
  # 
  proc setup {{base 0x0000}} {
    if {[rlc amap -testname mt.cntl $base]} {return}
    rlc amap -insert mt.cntl    [expr {$base + 0x00}]
    rlc amap -insert mt.stat    [expr {$base + 0x01}]
    rlc amap -insert mt.conf    [expr {$base + 0x02}]
    rlc amap -insert mt.mask    [expr {$base + 0x03}]
    rlc amap -insert mt.addrl   [expr {$base + 0x04}]
    rlc amap -insert mt.addrh   [expr {$base + 0x05}]
    rlc amap -insert mt.temp    [expr {$base + 0x06}]
    rlc amap -insert mt.dvalcnt [expr {$base + 0x07}]
    rlc amap -insert mt.crpat   [expr {$base + 0x08}]
    rlc amap -insert mt.wrpat   [expr {$base + 0x09}]
    rlc amap -insert mt.cwait   [expr {$base + 0x0a}]
    rlc amap -insert mt.rwait   [expr {$base + 0x0b}]
    rlc amap -insert mt.xwait   [expr {$base + 0x0c}]
    rlc amap -insert mt.ircnt   [expr {$base + 0x0d}]
    rlc amap -insert mt.rsttime [expr {$base + 0x0e}]
    rlc amap -insert mt.initime [expr {$base + 0x0f}]
    rlc amap -insert mt.datrd0  [expr {$base + 0x10}]
    rlc amap -insert mt.datrd1  [expr {$base + 0x11}]
    rlc amap -insert mt.datrd2  [expr {$base + 0x12}]
    rlc amap -insert mt.datrd3  [expr {$base + 0x13}]
    rlc amap -insert mt.datrd4  [expr {$base + 0x14}]
    rlc amap -insert mt.datrd5  [expr {$base + 0x15}]
    rlc amap -insert mt.datrd6  [expr {$base + 0x16}]
    rlc amap -insert mt.datrd7  [expr {$base + 0x17}]
    rlc amap -insert mt.datwr0  [expr {$base + 0x18}]
    rlc amap -insert mt.datwr1  [expr {$base + 0x19}]
    rlc amap -insert mt.datwr2  [expr {$base + 0x1a}]
    rlc amap -insert mt.datwr3  [expr {$base + 0x1b}]
    rlc amap -insert mt.datwr4  [expr {$base + 0x1c}]
    rlc amap -insert mt.datwr5  [expr {$base + 0x1d}]
    rlc amap -insert mt.datwr6  [expr {$base + 0x1e}]
    rlc amap -insert mt.datwr7  [expr {$base + 0x1f}]
  }
  #
  # checkconf: inspect conf and initime register -----------------------------
  # 
  proc checkconf {} {
    variable mawidth
    variable mwidth
    variable iswide
    variable initime
    
    if {$mwidth > 0} return ""
    
    rlc exec -rreg mt.conf    lconf \
             -rreg mt.initime linitime
    set mawidth [regget tst_mig::CONF(mawidth) $lconf]
    set mwidth  [regget tst_mig::CONF(mwidth)  $lconf]
    set initime linitime
    set iswide  [expr {$mwidth == 16}]
    return ""
  }
  #
  # iswide: 1 if 128 bit interface -------------------------------------------
  # 
  proc iswide {} {
    variable iswide
    if {$iswide < 0} { checkconf }
    return $iswide
  }
  #
  # getmwidth: return mask width ---------------------------------------------
  # 
  proc getmwidth {} {
    variable mwidth
    if {$mwidth < 0} { checkconf }
    return $mwidth
  }
  #
  # print: print registers ---------------------------------------------------
  # 
  proc print {} {
    set clist {}
    lappend clist -rreg mt.stat    stat
    lappend clist -rreg mt.mask    mask
    lappend clist -rreg mt.addrl   addrl
    lappend clist -rreg mt.addrh   addrh
    lappend clist -rreg mt.temp    temp
    lappend clist -rreg mt.dvalcnt dvalcnt
    lappend clist -rreg mt.crpat   crpat
    lappend clist -rreg mt.wrpat   wrpat
    lappend clist -rreg mt.cwait   cwait
    lappend clist -rreg mt.rwait   rwait
    lappend clist -rreg mt.xwait   xwait
    lappend clist -rreg mt.ircnt   ircnt
    lappend clist -rreg mt.rsttime rsttime
    lappend clist -rreg mt.initime initime
    lappend clist -rreg mt.datrd0  drd0
    lappend clist -rreg mt.datrd1  drd1
    lappend clist -rreg mt.datrd2  drd2
    lappend clist -rreg mt.datrd3  drd3
    lappend clist -rreg mt.datwr0  dwr0
    lappend clist -rreg mt.datwr1  dwr1
    lappend clist -rreg mt.datwr2  dwr2
    lappend clist -rreg mt.datwr3  dwr3
    if {[iswide]} {
      lappend clist -rreg mt.datrd4  drd4
      lappend clist -rreg mt.datrd5  drd5
      lappend clist -rreg mt.datrd6  drd6
      lappend clist -rreg mt.datrd7  drd7
      lappend clist -rreg mt.datwr4  dwr4
      lappend clist -rreg mt.datwr5  dwr5
      lappend clist -rreg mt.datwr6  dwr6
      lappend clist -rreg mt.datwr7  dwr7
    }
    
    rlc exec {*}$clist
    
    set rval    [format "\nstat:    %4.4x" $stat]
    append rval [format " zq:%d"   [regget tst_mig::STAT(zqpend)  $stat]]
    append rval [format " rp:%d"   [regget tst_mig::STAT(refpend) $stat]]
    append rval [format " rd:%d"   [regget tst_mig::STAT(rdend)   $stat]]
    append rval [format " rst:%d"  [regget tst_mig::STAT(uirst)   $stat]]
    append rval [format " cac:%d"  [regget tst_mig::STAT(caco)    $stat]]
    append rval [format " wrd:%d"  [regget tst_mig::STAT(wrdy)    $stat]]
    append rval [format " crd:%d"  [regget tst_mig::STAT(crdy)    $stat]]
    append rval [format "\naddr:    %4.4x %4.4x" $addrh $addrl]
 
    append rval [format "\nmask:    %4.4x  %s" $mask [pbvi b16 $mask]]
    append rval [format "\ndatwr:   "]
    if {[iswide]} {
      append rval [format "%4.4x %4.4x %4.4x %4.4x" $dwr7 $dwr6 $dwr5 $dwr4]
    }
    append rval [format "  %4.4x %4.4x %4.4x %4.4x" $dwr3 $dwr2 $dwr1 $dwr0]
    
    append rval [format "\ndatrd:   "]
    if {[iswide]} {
      append rval [format "%4.4x %4.4x %4.4x %4.4x" $drd7 $drd6 $drd5 $drd4]
    }
    append rval [format "  %4.4x %4.4x %4.4x %4.4x" $drd3 $drd2 $drd1 $drd0]
    
    append rval [format "\ncrpat:   %4.4x  %s"   $crpat [pbvi b16 $crpat]]
    append rval [format "\nwrpat:   %4.4x  %s"   $wrpat [pbvi b16 $wrpat]]
    append rval [format "\ncwait:   %4.4x  %6d"  $cwait $cwait]
    append rval [format "\nrwait:   %4.4x  %6d"  $rwait $rwait]
    append rval [format "\nxwait:   %4.4x  %6d"  $xwait $xwait]
    set rstcnt [regget tst_mig::IRCNT(rstcnt)    $ircnt]
    set inicnt [regget tst_mig::IRCNT(inicnt)    $ircnt]
    append rval [format "\nrstcnt:  %4.4x  %6d"  $rstcnt  $rstcnt]
    append rval [format "  rsttime: %4.4x  %6d"  $rsttime  $rsttime]
    append rval [format "\ninicnt:  %4.4x  %6d"  $inicnt  $inicnt]
    append rval [format "  initime: %4.4x  %6d"  $initime  $initime]
    append rval [format "\ndvalcnt: %4.4x  %6d"  $dvalcnt $dvalcnt]
    append rval [format "\ntemp:    %4.4x  %6.1f deg" $temp [conv_raw2t $temp]]
    return $rval
  }
  #
  # conv_raw2t: convert xadc temp value to degree celsius --------------------
  # 
  proc conv_raw2t {val} {
    return [expr {(($val / 4096.) * 503.975) - 273.14}]
  }
  #
  # write: memory write ------------------------------------------------------
  # 
  proc write {addr data {mask 0x0000}} {
    set clist {}
    lappend clist -wreg mt.mask    $mask
    lappend clist -wreg mt.addrl   [expr { $addr      & 0xffff}]
    lappend clist -wreg mt.addrh   [expr {($addr>>16) & 0xffff}]
    lappend clist -wreg mt.datwr0  [lindex $data 0]
    lappend clist -wreg mt.datwr1  [lindex $data 1]
    lappend clist -wreg mt.datwr2  [lindex $data 2]
    lappend clist -wreg mt.datwr3  [lindex $data 3]
    if {[iswide]} {
      lappend clist -wreg mt.datwr4  [lindex $data 4]
      lappend clist -wreg mt.datwr5  [lindex $data 5]
      lappend clist -wreg mt.datwr6  [lindex $data 6]
      lappend clist -wreg mt.datwr7  [lindex $data 7]
    }
    lappend clist -wreg mt.cntl [regbld tst_mig::CNTL {func "WR"}]

    rlc exec {*}$clist
    return ""
  }
  #
  # read: read ---------------------------------------------------------------
  # 
  proc read {addr} {
    set clist {}
    lappend clist -wreg mt.addrl   [expr { $addr      & 0xffff}]
    lappend clist -wreg mt.addrh   [expr {($addr>>16) & 0xffff}]
    lappend clist -wreg mt.cntl    [regbld tst_mig::CNTL {func "RD"}]
    lappend clist -rreg mt.datrd0  datrd0
    lappend clist -rreg mt.datrd1  datrd1
    lappend clist -rreg mt.datrd2  datrd2
    lappend clist -rreg mt.datrd3  datrd3
    if {[iswide]} {
      lappend clist -rreg mt.datrd4  datrd4
      lappend clist -rreg mt.datrd5  datrd5
      lappend clist -rreg mt.datrd6  datrd6
      lappend clist -rreg mt.datrd7  datrd7
    }

    rlc exec {*}$clist

    set rval [list $datrd0 $datrd1 $datrd2 $datrd3]
    if {[iswide]} {
      lappend rval $datrd4 $datrd5 $datrd6 $datrd7
    }

    return $rval
  }
  #
  # readck: read and check ---------------------------------------------------
  # 
  proc readck {addr data} {
    set clist {}
    lappend clist -wreg mt.addrl   [expr { $addr      & 0xffff}]
    lappend clist -wreg mt.addrh   [expr {($addr>>16) & 0xffff}]
    lappend clist -wreg mt.cntl    [regbld tst_mig::CNTL {func "RD"}]
    lappend clist -rreg mt.datrd0  -edata [lindex $data 0] 
    lappend clist -rreg mt.datrd1  -edata [lindex $data 1]
    lappend clist -rreg mt.datrd2  -edata [lindex $data 2]
    lappend clist -rreg mt.datrd3  -edata [lindex $data 3]
    if {[iswide]} {
      lappend clist -rreg mt.datrd4  -edata [lindex $data 4]
      lappend clist -rreg mt.datrd5  -edata [lindex $data 5]
      lappend clist -rreg mt.datrd6  -edata [lindex $data 6]
      lappend clist -rreg mt.datrd7  -edata [lindex $data 7]
    }

    rlc exec {*}$clist
    return ""
  }
  #
  # readpr: read and print ---------------------------------------------------
  # 
  proc readpr {addr {cnt 1} {inc 0}} {
    set rval ""
    if {$inc == 0} { set inc [getmwidth]}
    for {set i 0} {$i < $cnt} {incr i} {
      set data [read $addr]
      if {$i != 0} { append rval "\n"}
      append rval [format "%4.4x %4.4x: %4.4x %4.4x %4.4x %4.4x" \
                     [expr {($addr>>16) & 0xffff}] \
                     [expr { $addr      & 0xffff}] \
                     [lindex $data 0] [lindex $data 1] \
                     [lindex $data 2] [lindex $data 3]]
      if {[iswide]} {
        append rval [format "  %4.4x %4.4x %4.4x %4.4x" \
                       [lindex $data 4] [lindex $data 5] \
                       [lindex $data 6] [lindex $data 7]]
      }
      set addr [expr {$addr + $inc}]
    }
    return $rval
  }
  #
  # getpat: get test pattern based on address --------------------------------
  #   byte by byte signature; design to look nice in readpr
  #     a(7)0  a(6)1  a(5)2 ... a(7)7 ... a(7)8  a(6)9 ... a(0)f
  # 
  proc getpat {addr} {
    set a7 [expr {($addr >> 28) & 0x0f}]
    set a6 [expr {($addr >> 24) & 0x0f}]
    set a5 [expr {($addr >> 20) & 0x0f}]
    set a4 [expr {($addr >> 16) & 0x0f}]
    set a3 [expr {($addr >> 12) & 0x0f}]
    set a2 [expr {($addr >>  8) & 0x0f}]
    set a1 [expr {($addr >>  4) & 0x0f}]
    set a0 [expr { $addr        & 0x0f}]
    set rval [list [expr {($a7 << 12) | ($a6 << 4) | 0x0001}] \
                   [expr {($a5 << 12) | ($a4 << 4) | 0x0203}] \
                   [expr {($a3 << 12) | ($a2 << 4) | 0x0405}] \
                   [expr {($a1 << 12) | ($a0 << 4) | 0x0607}]
             ]
    if {[iswide]} {
    lappend rval [expr {($a7 << 12) | ($a6 << 4) | 0x0809}] \
                 [expr {($a5 << 12) | ($a4 << 4) | 0x0a0b}] \
                 [expr {($a3 << 12) | ($a2 << 4) | 0x0c0d}] \
                 [expr {($a1 << 12) | ($a0 << 4) | 0x0e0f}]
    }
    return $rval
  }
  #
  # writepat: write test pattern ---------------------------------------------
  # 
  proc writepat {addr {cnt 1} {inc 0}} {
    if {$inc == 0} { set inc [getmwidth]}
    for {set i 0} {$i < $cnt} {incr i} {
      write $addr [getpat $addr]
      set addr [expr {$addr + $inc}]
    }
    return ""
  }
  #
  # readckpat: read and check test pattern -----------------------------------
  # 
  proc readckpat {addr {cnt 1} {inc 0}} {
    if {$inc == 0} { set inc [getmwidth]}
    for {set i 0} {$i < $cnt} {incr i} {
      readck $addr [getpat $addr]
      set addr [expr {$addr + $inc}]
    }
    return ""
  }
  #
  # test_pat: test PAT function, analyse ready patterns ----------------------
  # 
  proc test_pat {{gcnt 16} {pcnt 4}} {
    set crdyzero 0
    set wrdyzero 0
    set rval "cmd rdy patterns after PAT function:"
    for {set i 0} { $i < $gcnt } {incr i} {
      rlc exec \
        -wreg mt.cntl  [regbld tst_mig::CNTL {func "PAT"}] \
        -rreg mt.crpat crpat0 \
        -rreg mt.wrpat wrpat0 \
        -wreg mt.cntl  [regbld tst_mig::CNTL {func "PAT"}] \
        -rreg mt.crpat crpat1 \
        -rreg mt.wrpat wrpat1 \
        -wreg mt.cntl  [regbld tst_mig::CNTL {func "PAT"}] \
        -rreg mt.crpat crpat2 \
        -rreg mt.wrpat wrpat2 \
        -wreg mt.cntl  [regbld tst_mig::CNTL {func "PAT"}] \
        -rreg mt.crpat crpat3 \
        -rreg mt.wrpat wrpat3
      if { $i < $pcnt } {
        append rval [format "\n  %s  %s  %s  %s" \
                       [pbvi b16 $crpat0] [pbvi b16 $crpat1] \
                       [pbvi b16 $crpat2] [pbvi b16 $crpat3] ]
      }
      incr crdyzero [zerocount $crpat0]
      incr crdyzero [zerocount $crpat1]
      incr crdyzero [zerocount $crpat2]
      incr crdyzero [zerocount $crpat3]
      incr wrdyzero [zerocount $wrpat0]
      incr wrdyzero [zerocount $wrpat1]
      incr wrdyzero [zerocount $wrpat2]
      incr wrdyzero [zerocount $wrpat3]
    }
    set tcnt [expr {4*16*$gcnt}]
    append rval [format "\n  crdy: bits: %4d  zero: %4d  frac: %6.1f%%" \
                   $tcnt $crdyzero [expr {100.*$crdyzero/$tcnt}]]
    append rval [format "\n  wrdy: bits: %4d  zero: %4d  frac: %6.1f%%" \
                   $tcnt $wrdyzero [expr {100.*$wrdyzero/$tcnt}]]
    return $rval
  }
  #
  # test_rwait: determine read latency with read commands --------------------
  # 
  proc test_rwait {addr {cnt 16} {inc 0x0} {lena 0}} {
    set cwaitlist {}
    set rwaitlist {}
    set addr0  $addr
    set addr1  [expr {$addr + 1*$inc}]
    set addr2  [expr {$addr + 2*$inc}]
    set addr3  [expr {$addr + 3*$inc}]

    for {set i 0} { $i < $cnt } {incr i} {
      if { $lena } {
        rlc exec \
          -wreg mt.addrl  [expr { $addr0      & 0xffff}] \
          -wreg mt.addrh  [expr {($addr0>>16) & 0xffff}] \
          -wreg mt.cntl   [regbld tst_mig::CNTL {func "RD"}] \
          -rreg mt.cwait  cwait0 \
          -rreg mt.rwait  rwait0 \
          -wreg mt.addrl  [expr { $addr1      & 0xffff}] \
          -wreg mt.addrh  [expr {($addr1>>16) & 0xffff}] \
          -wreg mt.cntl   [regbld tst_mig::CNTL {func "RD"}] \
          -rreg mt.cwait  cwait1 \
          -rreg mt.rwait  rwait1 \
          -wreg mt.addrl  [expr { $addr2      & 0xffff}] \
          -wreg mt.addrh  [expr {($addr0>>16) & 0xffff}] \
          -wreg mt.cntl   [regbld tst_mig::CNTL {func "RD"}] \
          -rreg mt.cwait  cwait2 \
          -rreg mt.rwait  rwait2 \
          -wreg mt.addrl  [expr { $addr3      & 0xffff}] \
          -wreg mt.addrh  [expr {($addr3>>16) & 0xffff}] \
          -wreg mt.cntl   [regbld tst_mig::CNTL {func "RD"}] \
          -rreg mt.cwait  cwait3 \
          -rreg mt.rwait  rwait3
        lappend cwaitlist $cwait0 $cwait1 $cwait2 $cwait3
        lappend rwaitlist $rwait0 $rwait1 $rwait2 $rwait3
      } else {
        rlc exec \
          -wreg mt.addrl  [expr { $addr0      & 0xffff}] \
          -wreg mt.addrh  [expr {($addr0>>16) & 0xffff}] \
          -wreg mt.cntl   [regbld tst_mig::CNTL {func "RD"}] \
          -rreg mt.cwait  cwait0 \
          -rreg mt.rwait  rwait0 
        lappend cwaitlist $cwait0
        lappend rwaitlist $rwait0
      }
    }
    set cwaitlist [lsort -integer $cwaitlist]
    set rwaitlist [lsort -integer $rwaitlist]
    set cwaitmin  [lindex $cwaitlist   0]
    set cwaitmax  [lindex $cwaitlist end]
    set rwaitmin  [lindex $rwaitlist   0]
    set rwaitmax  [lindex $rwaitlist end]
    set waitmax   [expr {max($cwaitmax,$rwaitmax)}]
    set cwaithist [lrepeat [expr {$waitmax+1}] 0]
    set rwaithist [lrepeat [expr {$waitmax+1}] 0]
    set tcnt      [llength $cwaitlist] 
    foreach cwait $cwaitlist {
      incr cwaitsum $cwait
      lset cwaithist $cwait [expr {1+[lindex $cwaithist $cwait]}]
    }
    foreach rwait $rwaitlist {
      incr rwaitsum $rwait
      lset rwaithist $rwait [expr {1+[lindex $rwaithist $rwait]}]
    }
    set rval ""
    append rval [format   "cwait: min: %3d  max: %3d  avr: %6.1f" \
                   $cwaitmin $cwaitmax [expr {$cwaitsum/(1.*$tcnt)}]]
    append rval [format "\nrwait: min: %3d  max: %3d  avr: %6.1f" \
                   $rwaitmin $rwaitmax [expr {$rwaitsum/(1.*$tcnt)}]]
    append rval "\ndistribution histogram:"
    append rval "\n time:  cwait  rwait"
    for {set i 0} { $i <= $waitmax } {incr i} {
      append rval [format "\n  %3d: %6d %6d" \
                     $i [lindex $cwaithist $i] [lindex $rwaithist $i] ]
    }
    return $rval
  }
  #
  # test_reqwait: determine REF and CAL latencies ----------------------------
  # 
  proc test_reqwait {{cnt 16} {pcnt 0}} {
    set refmin  1.e6
    set refmax  0
    set refsum  0
    set calmin  1.e6
    set calmax  0
    set calsum  0
    set rval ""
    
    for {set i 0} { $i < $cnt} {incr i} {
      rlc exec -wreg mt.cntl  [regbld tst_mig::CNTL {func "REF"}]
      rlc exec \
        -rreg mt.xwait xwait \
        -rreg mt.crpat crpat \
        -rreg mt.wrpat wrpat
      set refmin [expr {min($refmin,$xwait)}]
      set refmax [expr {max($refmax,$xwait)}]
      incr refsum $xwait
      if {$i < $pcnt} {
        append rval [format "\nREF wait: %3d crdy %s wrdy %s" \
                       $xwait [pbvi b16 $crpat] [pbvi b16 $wrpat] ]
      }
      rlc exec -wreg mt.cntl  [regbld tst_mig::CNTL {func "CAL"}]
      rlc exec \
        -rreg mt.xwait xwait \
        -rreg mt.crpat crpat \
        -rreg mt.wrpat wrpat
      set calmin [expr {min($calmin,$xwait)}]
      set calmax [expr {max($calmax,$xwait)}]
      incr calsum $xwait
      if {$i < $pcnt} {
        append rval [format "\nZQ  wait: %3d crdy %s wrdy %s" \
                       $xwait [pbvi b16 $crpat] [pbvi b16 $wrpat] ]
      }
    }
    append rval [format "\nREF_REQ:  min: %3d  max: %3d  avr: %6.1f" \
                   $refmin $refmax [expr {$refsum/(1.*$cnt)}]]
    append rval [format "\nZQ_REQ:   min: %3d  max: %3d  avr: %6.1f" \
                   $calmin $calmax [expr {$calsum/(1.*$cnt)}]]
    return $rval
  }
  #
  # zerocount ----------------------------------------------------------------
  # 
  proc zerocount {pat} {
    set cnt  0
    set mask 1
    for {set i 0} { $i < 16 } {incr i} {
      if { ($pat & $mask) == 0 } { incr cnt }
      set mask [expr { $mask << 1 } ]
    }
    return $cnt
  }
}
