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
# 2017-04-22   883   4.0.1  setup: now idempotent; add procs filter,rme,rmf
# 2017-04-13   873   4.0    revised interface, add suspend and repeat collect
# 2015-04-03   661   3.1    drop estatdef; invert mask in raw_edata
# 2014-12-23   619   3.0    rbd_rbmon reorganized, supports now 16 bit addresses
# 2014-11-09   603   2.0    use rlink v4 address layout
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
  regdsc CNTL {rcolw 5} {rcolr 4} {wstop 3} \
              {func 2 3 "s:NOOP:NOOP1:NOOP2:NOOP3:STO:STA:SUS:RES"}
  regdsc STAT {bsize 15 3} {wrap 2} {susp 1} {run 0}
  regdsc ADDR {laddr 15 14} {waddr 1 2}
  #
  regdsc DAT3 {flags 15 8 "-"} {burst 15} {tout 14} {nak 13} {ack 12} \
              {busy 11} {err 10} {we 9} {init 8} {ndlymsb 7 8}
  regdsc DAT2 {ndlylsb 15 6} {nbusy  9 10}
  #
  # 'pseudo register', describes 1st word in return list element of rbmoni::read
  # same bits as DAT3(flags) (but shifted positions) plus bnext
  regdsc FLAGS {bnext 8} {burst 7} {tout 6} {nak 5} {ack 4} \
               {busy 3} {err 2} {we 1} {init 0}
  #
  # setup: amap definitions for rbd_rbmon ------------------------------------
  # 
  proc setup {{base 0xffe8}} {
    if {[rlc amap -testname rm.cntl $base]} {return}
    rlc amap -insert rm.cntl  [expr {$base + 0x00}]
    rlc amap -insert rm.stat  [expr {$base + 0x01}]
    rlc amap -insert rm.hilim [expr {$base + 0x02}]
    rlc amap -insert rm.lolim [expr {$base + 0x03}]
    rlc amap -insert rm.addr  [expr {$base + 0x04}]
    rlc amap -insert rm.data  [expr {$base + 0x05}]
  }
  #
  # init: reset rbd_rbmon (stop, reset alim) ---------------------------------
  # 
  proc init {} {
    rlc exec \
      -wreg rm.cntl [regbld rbmoni::CNTL {func "STO"}] \
      -wreg rm.hilim  0xfffb \
      -wreg rm.lolim  0x0000 \
      -wreg rm.addr 0x0000
  }
  #
  # start: setup filter window -----------------------------------------------
  #
  proc filter {{lolim 0160000} {hilim 0177776}} {
    rlc exec \
      -wreg rm.lolim $lolim \
      -wreg rm.hilim $hilim
  }
  #
  # start: start the rbmon ---------------------------------------------------
  #
  proc start {args} {
    args2opts opts {rcolw 0 rcolr 0 wstop 0} {*}$args
    rlc exec -wreg rm.cntl [regbld rbmoni::CNTL {func "STA"} \
                              [list  rcolw $opts(rcolw)] \
                              [list  rcolr $opts(rcolr)] \
                              [list  wstop $opts(wstop)] \
                            ]
  }
  #
  # stop: stop the rbmon -----------------------------------------------------
  #
  proc stop {} {
    rlc exec -wreg rm.cntl [regbld rbmoni::CNTL {func "STO"}]
  }
  #
  # suspend: suspend the rbmon -----------------------------------------------
  #   returns 1 if already suspended
  #   that allows to implement nested suspend/resume properly
  #
  proc suspend {} {
    rlc exec -rreg rm.stat rstat \
             -wreg rm.cntl [regbld rbmoni::CNTL {func "SUS"}]
    return [regget rbmoni::STAT(susp) $rstat]
  }
  #
  # resume: resume the rbmon -------------------------------------------------
  #
  proc resume {} {
    rlc exec -wreg rm.cntl [regbld rbmoni::CNTL {func "RES"}]
  }
  #
  # read: read nent last entries (by default all) ----------------------------
  #
  proc read {{nent -1}} {
    rlc exec -rreg rm.stat rstatpre \
             -wreg rm.cntl [regbld rbmoni::CNTL {func "SUS"}] \
             -rreg rm.cntl rcntl \
             -rreg rm.addr raddr \
             -rreg rm.stat rstat

    # determine max number items
    set bsize [regget rbmoni::STAT(bsize) $rstat]
    set amax  [expr {( 512 << $bsize ) - 1}]
    set nmax  [expr { $amax + 1 } ]
    if {$nent == -1}   { set nent $nmax }
    if {$nent > $nmax} { set nent $nmax }

    # determine number of available items (check wrap flag)
    set laddr [regget rbmoni::ADDR(laddr) $raddr]
    set nval  $laddr
    if {[regget rbmoni::STAT(wrap) $rstat]} { set nval $nmax }

    if {$nent > $nval} {set nent $nval}

    # if wstop set use first nent items, otherwise last nent items
    set caddr 0
    if {![regget rbmoni::CNTL(wstop) $rcntl]} {
      set caddr [expr {( $laddr - $nent ) & $amax}]
    }
    rlc exec -wreg rm.addr [regbld rbmoni::ADDR [list laddr $caddr]]
    
    set rval {}
    set nblkmax [expr {( [rlc get bsizemax] >> 2 ) << 2}]; # ensure multiple of 4
    set nrest $nent
    
    while {$nrest > 0} {
      set nblk [expr {$nrest << 2}]
      if {$nblk > $nblkmax} {set nblk $nblkmax}
      rlc exec -rblk rm.data $nblk rawdat

      foreach {d0 d1 d2 d3} $rawdat {
        set eflag  [regget rbmoni::DAT3(flags) $d3]
        set edelay [expr {( [regget rbmoni::DAT3(ndlymsb) $d3] << 6 ) | 
                            [regget rbmoni::DAT2(ndlylsb) $d2] }]
        set enbusy [regget rbmoni::DAT2(nbusy) $d2]
        set edata  $d1
        set eaddr  $d0
        lappend rval [list $eflag $eaddr $edata $edelay $enbusy]
      }

      set nrest [expr {$nrest - ( $nblk >> 2 ) }]
    }

    # restore address and resume
    #   resume only if not already suspended before
    set rfu [expr {[regget rbmoni::STAT(susp) $rstatpre] ? "NOOP" : "RES"}]
    rlc exec -wreg rm.addr $raddr \
             -wreg rm.cntl [regbldkv rbmoni::CNTL func $rfu]

    set mbnext [regbld rbmoni::FLAGS bnext]
    set mburst [regbld rbmoni::FLAGS burst]

    # now set bnext flag when burst is set in following entry
    for {set i 1} {$i < $nent} {incr i} {
      if {[lindex $rval $i 0] & int($mburst)} {
        set i1 [expr {$i - 1} ]
        lset rval $i1 0 [expr {[lindex $rval $i1 0] | $mbnext}]
      }
    }

    return $rval
  }
  #
  # print: print rbmon data (optionally also read them) -----------------------
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
    set edlymax 16383

    set eind [expr {1 - [llength $mondat] }]
    append rval \
      "  ind  addr        data  delay nbsy     flags  bu to na ac bs er mode"

    set mbnext [regbld rbmoni::FLAGS bnext]
    set mburst [regbld rbmoni::FLAGS burst]
    set mtout  [regbld rbmoni::FLAGS tout ]
    set mnak   [regbld rbmoni::FLAGS nak  ]
    set mack   [regbld rbmoni::FLAGS ack  ]
    set mbusy  [regbld rbmoni::FLAGS busy ]
    set merr   [regbld rbmoni::FLAGS err  ]
    set mwe    [regbld rbmoni::FLAGS we   ]
    set minit  [regbld rbmoni::FLAGS init ]
    set mblk   [expr {$mbnext | $mburst}]

    foreach {ele} $mondat {
      foreach {eflag eaddr edata edly enbusy} $ele { break }

      set fburst [expr {$eflag & $mburst}]
      set ftout  [expr {$eflag & $mtout} ]
      set fnak   [expr {$eflag & $mnak}  ]
      set fack   [expr {$eflag & $mack}  ]
      set fbusy  [expr {$eflag & $mbusy} ]
      set ferr   [expr {$eflag & $merr}  ]
      set fwe    [expr {$eflag & $mwe}   ]
      set finit  [expr {$eflag & $minit} ]

      set pburst [expr {$fburst ? "bu" : "  "}]
      set ptout  [expr {$ftout  ? "to" : "  "}]
      set pnak   [expr {$fnak   ? "na" : "  "}]
      set pack   [expr {$fack   ? "ac" : "  "}]
      set pbusy  [expr {$fbusy  ? "bs" : "  "}]
      set perr   [expr {$ferr   ? "er" : "  "}]
      set pmode  "????"
      if {$finit} {
        set pmode  "init"
      } else {
        if {$fwe} {
          set pmode  [expr {$eflag & $mblk ? "wblk" : "wreg"}]
        } else {
          set pmode  [expr {$eflag & $mblk ? "rblk" : "rreg"}]
        }
      }

      set pedly [expr {$edly!=$edlymax ? [format "%5d" $edly] : "   --"}]
      set ename  [format "%4.4x" $eaddr]
      set comment ""
      if {$ferr}            {append comment " ERR=1!"}
      if {!$finit && $fnak} {append comment " NAK=1!"}
      if {$ftout}           {append comment " TOUT=1!"}
      if {[rlc amap -testaddr $eaddr]} {set ename [rlc amap -name $eaddr]}
      append rval [format \
      "\n%5d  %-11s %4.4x  %5s %4d  %s  %s %s %s %s %s %s %s  %s" \
        $eind $ename $edata $pedly $enbusy [pbvi b8 $eflag] \
        $pburst $ptout $pnak $pack $pbusy $perr $pmode $comment]
      incr eind
    }

    return $rval
  }

  #
  # raw_edata: prepare edata lists for raw data reads in tests ---------------
  #   args is list of {eflag eaddr edata enbusy} sublists

  proc raw_edata {edat emsk args} {
    upvar $edat uedat
    upvar $emsk uemsk
    set uedat {}
    set uemsk {}

    set m3 [rutil::com16 [regbld rbmoni::DAT3 {ndlymsb -1}]]; # all but ndlymsb
    set m2 [rutil::com16 [regbld rbmoni::DAT2 {ndlylsb -1}]]; # all but ndlylsb
    set m1 0xffff
    set m0 0xffff

    foreach line $args {
      foreach {eflags eaddr edata enbusy} $line { break }
      set d3 [regbld rbmoni::DAT3 [list flags $eflags]]
      set d2 [regbld rbmoni::DAT2 [list nbusy $enbusy]]
      if {$edata ne ""} {
        set m1 0xffff
        set d1 $edata
      } else {
        set m1 0x0000
        set d1 0x0000
      }
      set d0 $eaddr

      lappend uedat $d0 $d1 $d2 $d3
      lappend uemsk $m0 $m1 $m2 $m3
    }

    return
  }

  #
  # raw_check: check raw data against expect values prepared by raw_edata ----
  #
  proc raw_check {edat emsk} {

    rlc exec \
      -rreg rm.addr -edata [llength $edat] \
      -wreg rm.addr 0 \
      -rblk rm.data [llength $edat] -edata $edat $emsk \
      -rreg rm.addr -edata [llength $edat]
    return
  }
  #
  # === high level procs: compact usage (also by rw11:shell) =================
  #
  # rme: rbmon enable --------------------------------------------------------
  # 
  proc rme {{mode ""}} {
    if {![regexp {^[nRW]*$} $mode]} {
      error "rme-E: bad mode '$mode', use \[nRW\]*"
    }
    set wstop  [string match *n* $mode]
    set rcolr  [string match *R* $mode]
    set rcolw  [string match *W* $mode]
    
    rbmoni::start wstop $wstop rcolr $rcolr rcolw $rcolw
    return
  }

  #
  # rmf: rbmon filter --------------------------------------------------------
  # 
  proc rmf {{lo ""} {hi ""}} {
    set lolim 0
    set hilim 0177773

    if {$lo ne ""} {
      set lolist [split $lo "/"]
      if {[llength $lolist] > 2} {
        error "imf-E: bad lo specifier '$lo', use val or val/len"
      }
      set lolim [rlink::amap_reg2addr [lindex $lolist 0]]
      set hilim $lolim
      if {[llength $lolist] == 2} {
        set hilim [expr {$lolim + ([lindex $lolist 1]-1)}]
      }
    }

    if {$hi ne ""} {
      set hilim [rlink::amap_reg2addr $hi]
    }

    if {$lolim > $hilim} {error "rmf-E: hilim must be >= lolim"}

    rbmoni::filter $lolim $hilim
  }
  
}
