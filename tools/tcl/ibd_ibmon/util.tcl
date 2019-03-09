# $Id: util.tcl 1116 2019-03-03 08:24:07Z mueller $
#
# Copyright 2015-2019 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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
# 2019-03-01  1116   2.1.1  streamline raw_check; bugfix in raw_edata
# 2019-02-23  1115   2.1    revised iface, busy 10->8, delay 14->16 bits
# 2017-04-22   883   2.0.1  setup: now idempotent; move out imap_reg2addr
# 2017-04-16   880   2.0    revised interface, add suspend and repeat collect
# 2017-01-02   837   1.1.1  add procs ime,imf
# 2016-12-30   833   1.1    add proc filter
# 2015-12-28   721   1.0.2  add regmap_add defs; add symbolic register dump
# 2015-07-25   704   1.0.1  start: use args and args2opts
# 2015-04-25   668   1.0    Initial version
#

package provide ibd_ibmon 1.0

package require rutil
package require rlink
package require rw11
package require rw11util

namespace eval ibd_ibmon {
  #
  # setup register descriptions for ibd_ibmon
  #
  regdsc CNTL {rcolw 8} {rcolr 7} {wstop 6} \
              {conena 5} {remena 4} {locena 3} \
              {func 2 3 "s:NOOP:NOOP1:NOOP2:NOOP3:STO:STA:SUS:RES"}
  regdsc STAT {bsize 15 3} {wrap 2} {susp 1} {run 0}
  regdsc ADDR {laddr 15 14} {waddr 1 2}
  #
  regdsc DAT3 {burst 15} {tout 14} {nak 13} {ack 12} \
              {busy 11} {we 9} {rmw 8} {nbusy 7 8}
  regdsc DAT0 {be1 15} {be0 14} {racc 13} {addr 12 12} {cacc 0}
  #
  # 'pseudo register', describes 1st word in return list element of read proc
  #  all flag bits from DAT3 and DAT0;
  #  use short names to keep tb code compact
  #    burst->bu tout->to; busy->bsy; cacc->ca; racc->ra
  regdsc FLAGS {bu 11} {to 10} {nak 9} {ack 8} \
               {bsy 7} {ca 5} {ra 4} {rmw 3} {be1 2} {be0 1} {we 0}   
  #
  rw11util::regmap_add ibd_ibmon im.cntl {r? CNTL}
  rw11util::regmap_add ibd_ibmon im.stat {r? STAT}
  rw11util::regmap_add ibd_ibmon im.addr {r? ADDR}

  #
  # setup: amap definitions for ibd_ibmon ------------------------------------
  # 
  proc setup {{cpu "cpu0"} {base 0160000}} {
    if {[$cpu imap -testname im.cntl $base]} {return}
    $cpu imap -insert im.cntl  [expr {$base + 000}]
    $cpu imap -insert im.stat  [expr {$base + 002}]
    $cpu imap -insert im.hilim [expr {$base + 004}]
    $cpu imap -insert im.lolim [expr {$base + 006}]
    $cpu imap -insert im.addr  [expr {$base + 010}]
    $cpu imap -insert im.data  [expr {$base + 012}]
  }
  #
  # init: reset ibd_ibmon (stop, reset alim) ---------------------------------
  # 
  proc init {{cpu "cpu0"}} {
    $cpu cp \
      -wibr im.cntl [regbld ibd_ibmon::CNTL {func "STO"}] \
      -wibr im.hilim  0177776 \
      -wibr im.lolim  0160000 \
      -wibr im.addr 0x0000
  }
  #
  # filter: setup filter window ----------------------------------------------
  #
  proc filter {{cpu "cpu0"} {lolim 0160000} {hilim 0177776}} {
    if {$lolim < 0160000 || $hilim < 0160000} {
      error "filter-E: bad lolim or hilim, must be >= 0160000"
    }
    if {$lolim > $hilim} {
      error "filter-E: bad lolim.hilim, must be lolim <= hilim"
    }
    $cpu cp -wibr im.lolim $lolim \
            -wibr im.hilim $hilim
  }
  #
  # start: start the ibmon ---------------------------------------------------
  #
  proc start {{cpu "cpu0"} args} {
    args2opts opts {rcolw 0 rcolr 0 wstop 0 conena 1 remena 1 locena 1} {*}$args
    $cpu cp -wibr im.cntl [regbld ibd_ibmon::CNTL {func "STA"} \
                              [list  rcolw $opts(rcolw)] \
                              [list  rcolr $opts(rcolr)] \
                              [list  wstop $opts(wstop)] \
                              [list locena $opts(locena)] \
                              [list remena $opts(remena)] \
                              [list conena $opts(conena)] \
                             ]
  }
  #
  # stop: stop the ibmon -----------------------------------------------------
  #
  proc stop {{cpu "cpu0"}} {
    $cpu cp -wibr im.cntl [regbld ibd_ibmon::CNTL {func "STO"}]
  }
  #
  # suspend: suspend the ibmon -----------------------------------------------
  #   returns 1 if already suspended
  #   that allows to implement nested suspend/resume properly
  #
  proc suspend {{cpu "cpu0"}} {
     $cpu cp -ribr im.stat rstat \
             -wibr im.cntl [regbld ibd_ibmon::CNTL {func "SUS"}]
    return [regget ibd_ibmon::STAT(susp) $rstat]
  }
  #
  # resume: resume the ibmon -------------------------------------------------
  #
  proc resume {{cpu "cpu0"}} {
    $cpu cp -wibr im.cntl [regbld ibd_ibmon::CNTL {func "RES"}]
  }
  #
  # read: read nent last entries (by default all) ----------------------------
  #
  proc read {{cpu "cpu0"} {nent -1}} {
    # suspend and get address and status
    $cpu cp -rreg im.stat rstatpre \
            -wibr im.cntl [regbld ibd_ibmon::CNTL {func "SUS"}] \
            -ribr im.cntl rcntl \
            -ribr im.addr raddr \
            -ribr im.stat rstat

    # determine max number items
    set bsize [regget ibd_ibmon::STAT(bsize) $rstat]
    set amax  [expr {( 512 << $bsize ) - 1}]
    set nmax  [expr { $amax + 1 } ]
    if {$nent == -1}   { set nent $nmax }
    if {$nent > $nmax} { set nent $nmax }

    # determine number of available items (check wrap flag)
    set laddr [regget ibd_ibmon::ADDR(laddr) $raddr]
    set nval  $laddr
    if {[regget ibd_ibmon::STAT(wrap) $rstat]} { set nval $nmax }

    if {$nent > $nval} {set nent $nval}

    # if wstop set use first nent items, otherwise last nent items
    set caddr 0
    if {![regget ibd_ibmon::CNTL(wstop) $rcntl]} {
      set caddr [expr {( $laddr - $nent ) & $amax}]
    }
    $cpu cp -wibr im.addr [regbld ibd_ibmon::ADDR [list laddr $caddr]]

    set rval {}
    set nblkmax [expr {( [rlc get bsizemax] >> 2 ) << 2}]; # ensure multiple of 4
    set nrest $nent
    
    while {$nrest > 0} {
      set nblk [expr {$nrest << 2}]
      if {$nblk > $nblkmax} {set nblk $nblkmax}
      set iaddr [$cpu imap im.data]
      $cpu cp -rbibr $iaddr $nblk rawdat

      foreach {d0 d1 d2 d3} $rawdat {
        set d3burst [regget ibd_ibmon::DAT3(burst) $d3]
        set d3tout  [regget ibd_ibmon::DAT3(tout)  $d3]
        set d3nak   [regget ibd_ibmon::DAT3(nak)   $d3]
        set d3ack   [regget ibd_ibmon::DAT3(ack)   $d3]
        set d3busy  [regget ibd_ibmon::DAT3(busy)  $d3]
        set d3we    [regget ibd_ibmon::DAT3(we)    $d3]
        set d3rmw   [regget ibd_ibmon::DAT3(rmw)   $d3]
        set d0be1   [regget ibd_ibmon::DAT0(be1)   $d0]
        set d0be0   [regget ibd_ibmon::DAT0(be0)   $d0]
        set d0racc  [regget ibd_ibmon::DAT0(racc)  $d0]
        set d0addr  [regget ibd_ibmon::DAT0(addr)  $d0]
        set d0cacc  [regget ibd_ibmon::DAT0(cacc)  $d0]

        set eflag   [regbld ibd_ibmon::FLAGS \
                       [list bu   $d3burst] \
                       [list to   $d3tout]  \
                       [list nak  $d3nak]   \
                       [list ack  $d3ack]   \
                       [list bsy  $d3busy]  \
                       [list ca   $d0cacc]  \
                       [list ra   $d0racc]  \
                       [list rmw  $d3rmw]   \
                       [list be1  $d0be1]   \
                       [list be0  $d0be0]   \
                       [list we   $d3we]    \
                    ]

        set enbusy [regget ibd_ibmon::DAT3(nbusy) $d3]
        set edelay $d2
        set edata  $d1
        set eaddr  [expr {0160000 | ($d0addr<<1)}]
        lappend rval [list $eflag $eaddr $edata $edelay $enbusy]
      }

      set nrest [expr {$nrest - ( $nblk >> 2 ) }]
    }

    # restore address and resume
    #   resume only if not already suspended before
    set rfu [expr {[regget ibd_ibmon::STAT(susp) $rstatpre] ? "NOOP" : "RES"}]
    $cpu cp -wibr im.addr $raddr \
            -wibr im.cntl [regbldkv ibd_ibmon::CNTL func $rfu]
    
    return $rval
  }
  #
  # print: print ibmon data (optionally also read them) ----------------------
  #
  proc print {{cpu "cpu0"} {mondat -1}} {

    if {[llength $mondat] == 1} {
      set ele [lindex $mondat 0]
      if {[llength $ele] == 1} {
        set nent [lindex $ele 0]
        set mondat [read $cpu $nent]
      }
    }

    set rval {}
    set edlymax 65535

    set eind [expr {1 - [llength $mondat] }]
    append rval \
      "  ind  addr         data  delay nbsy  btnab-crm10w  acc-mod"

    set mtout  [regbld ibd_ibmon::FLAGS to   ]
    set mnak   [regbld ibd_ibmon::FLAGS nak  ]
    set mack   [regbld ibd_ibmon::FLAGS ack  ]
    set mbusy  [regbld ibd_ibmon::FLAGS bsy  ]
    set mcacc  [regbld ibd_ibmon::FLAGS ca   ]
    set mracc  [regbld ibd_ibmon::FLAGS ra   ]
    set mrmw   [regbld ibd_ibmon::FLAGS rmw  ]
    set mbe1   [regbld ibd_ibmon::FLAGS be1  ]
    set mbe0   [regbld ibd_ibmon::FLAGS be0  ]
    set mwe    [regbld ibd_ibmon::FLAGS we   ]

    foreach {ele} $mondat {
      foreach {eflag eaddr edata edly enbusy} $ele { break }

      set ftout  [expr {$eflag & $mtout} ]
      set fnak   [expr {$eflag & $mnak}  ]
      set fack   [expr {$eflag & $mack}  ]
      set fbusy  [expr {$eflag & $mbusy} ]
      set fcacc  [expr {$eflag & $mcacc} ]
      set fracc  [expr {$eflag & $mracc} ]
      set frmw   [expr {$eflag & $mrmw}  ]
      set fbe1   [expr {$eflag & $mbe1}  ]
      set fbe0   [expr {$eflag & $mbe0}  ]
      set fwe    [expr {$eflag & $mwe}   ]

      set prw    "r"
      set pmod   " "
      set pwe1   " "
      set pwe0   " "

      if {$fwe } { 
        set prw   "w"
        set pwe1  "0"
        set pwe0  "0"
        if {$fbe1} { set pwe1 "1"}
        if {$fbe0} { set pwe0 "1"}
      }
      if {$frmw} { set pmod "m"}

      set prmw   "$pmod$prw$pwe1$pwe0"
      set pacc   "loc"
      if {$fcacc} { set pacc "con"}
      if {$fracc} { set pacc "rem"}

      set pedly [expr {$edly!=$edlymax ? [format "%5d" $edly] : "   --"}]

      set ename  [format "%6.6o" $eaddr]
      set etext  ""
      if {[$cpu imap -testaddr $eaddr]} {
        set ename [$cpu imap -name $eaddr]
        set eam   "l${prw}"
        if {$fracc} { set eam "r${prw}"}
        # mask out high/low byte for byte writes for regmap_txt
        set edatamsk $edata
        if {$pwe1 eq "0"} {set edatamsk [expr { $edatamsk & 0x00ff } ]}
        if {$pwe0 eq "0"} {set edatamsk [expr { $edatamsk & 0xff00 } ]}
        set etext [rw11util::regmap_txt $ename $eam $edatamsk]
      }

      set comment ""
      if {$fnak}   {append comment " NAK=1!"}
      if {$ftout}  {append comment " TOUT=1!"}

      append rval [format \
      "\n%5d  %-10s %6.6o  %5s %4d  %s %s %s" \
        $eind $ename $edata $pedly $enbusy [pbvi b12 $eflag] \
        $prmw $pacc]
      if {$etext ne ""}   {append rval "  $etext"}
      if {$comment ne ""} {append rval "  $comment"}
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

    set m3 0xffff
    set m2 0x0000;              # ignore ndly
    set m1 0xffff
    set m0 0xffff

    foreach line $args {
      foreach {eflags eaddr edata enbusy} $line { break }
      set d3 [regbldkv ibd_ibmon::DAT3 \
                burst  [regget ibd_ibmon::FLAGS(bu)  $eflags] \
                tout   [regget ibd_ibmon::FLAGS(to)  $eflags] \
                nak    [regget ibd_ibmon::FLAGS(nak) $eflags] \
                ack    [regget ibd_ibmon::FLAGS(ack) $eflags] \
                busy   [regget ibd_ibmon::FLAGS(bsy) $eflags] \
                we     [regget ibd_ibmon::FLAGS(we)  $eflags] \
                rmw    [regget ibd_ibmon::FLAGS(rmw) $eflags] \
                nbusy  $enbusy ]
      set d2 0x0000
      if {$edata ne ""} {
        set m1 0xffff
        set d1 $edata
      } else {
        set m1 0x0000
        set d1 0x0000
      }
      set d0 [regbldkv ibd_ibmon::DAT0 \
                be1    [regget ibd_ibmon::FLAGS(be1) $eflags] \
                be0    [regget ibd_ibmon::FLAGS(be0) $eflags] \
                racc   [regget ibd_ibmon::FLAGS(ra)  $eflags] \
                addr   [expr { ($eaddr>>1) & 0x0fff }] \
                cacc   [regget ibd_ibmon::FLAGS(ca)  $eflags] ]

      lappend uedat $d0 $d1 $d2 $d3
      lappend uemsk $m0 $m1 $m2 $m3
    }

    return
  }

  #
  # raw_check: check raw data against expect values prepared by raw_edata ----
  #
  proc raw_check {{cpu "cpu0"} edat emsk} {
    set ledat [llength $edat]
    if {$ledat == 0} { return }
    
    $cpu cp \
      -ribr  im.addr -edata $ledat \
      -wibr  im.addr        0 \
      -rbibr im.data $ledat -edata $edat $emsk \
      -ribr  im.addr        -edata $ledat
    return
  }

  #
  # === high level procs: compact usage (also by rw11:shell) =================
  #
  # ime: ibmon enable --------------------------------------------------------
  # 
  proc ime {{cpu "cpu0"} {mode "lrc"}} {
    if {![regexp {^[lrcnRW]*$} $mode]} {
      error "ime-E: bad mode '$mode', use \[lrc\]* and \[nRW\]*"
    }
    set locena [string match *l* $mode]
    set remena [string match *r* $mode]
    set conena [string match *c* $mode]
    if {$locena == 0 && $remena == 0 && $conena == 0} {
      set locena 1
      set remena 1
      set conena 1
    }
    set wstop  [string match *n* $mode]
    set rcolr  [string match *R* $mode]
    set rcolw  [string match *W* $mode]
    
    ibd_ibmon::start $cpu \
      locena $locena remena $remena conena $conena \
      wstop $wstop rcolr $rcolr rcolw $rcolw
    return
  }

  #
  # imf: ibmon filter --------------------------------------------------------
  # 
  proc imf {{cpu "cpu0"} {lo ""} {hi ""}} {
    set lolim 0160000
    set hilim 0177776

    if {$lo ne ""} {
      set aran [rw11::imap_range2addr $cpu $lo $hi]
      set lolim [lindex $aran 0]
      set hilim [lindex $aran 1]
    }

    ibd_ibmon::filter $cpu $lolim $hilim
  }

}
