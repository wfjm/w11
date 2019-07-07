# $Id: dmcmon.tcl 1177 2019-06-30 12:34:07Z mueller $
# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright 2015-2017 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
#
#  Revision History:
# Date         Rev Version  Comment
# 2017-04-23   885   2.0    revised interface, add suspend
# 2017-01-02   837   1.0.2  add procs cme,cml
# 2016-12-29   833   1.0.1  cm_print: protect against empty lists
# 2015-08-05   708   1.0    Initial version
# 2015-07-05   697   0.1    First draft
#

package provide rw11 1.0

package require rlink
package require rwxxtpp

namespace eval rw11 {
  #
  # setup dmcmon unit register descriptions for w11a -------------------------
  #
  regdsc CM_CNTL   {mwsup 5} {imode 4} {wstop 3} \
                   {func 2 3 "s:NOOP:NOOP1:NOOP2:NOOP3:STO:STA:SUS:RES"}
  regdsc CM_STAT   {bsize 15 3} {malcnt 12 4} {snum 8} {wrap 2} {susp 1} {run 0}
  regdsc CM_ADDR   {laddr 15 12} {waddr 3 4}
  regdsc CM_IADDR  {laddr 15 12}

  regdsc CM_FSNUM  {vmw 7} {err 3} {vec 2} {ins 1} {con 0} 
  
  regdsc CM_D8     {xnum 7 8} {req 15} {istart 9} {idone 8}
  regdsc CM_D8REQ  {wacc 14} {macc 13} {cacc 12} {bytop 11} {dspace 10}
  regdsc CM_D8ACK  {ack 14} {err 13} {tysv 12} {tmmu 11} {mwdrop 10}
  regdsc CM_D8ERR  {vmerr 12 3}

  regdsc CM_D7     {pc 15 15} {idec 0}

  # D5 has bit fields like rw11::PSW plus additional ones
  regdsc CM_D5     {cmode 15 2} {pmode 13 2} {rset 11} \
                     {pri 7 3 d} {tflag 4} {cc 3 4 "-"}  {n 3} {z 2} {v 1} {c 0} 
  regdsc CM_D5IM0  {dres_val 10} {ddst_we 9} {dsrc_we 8}
  regdsc CM_D5IM1  {vfetch 8}

  variable CM_D8_VMERR_ODD   01
  variable CM_D8_VMERR_MMU   02
  variable CM_D8_VMERR_NXM   03
  variable CM_D8_VMERR_IOBTO 04
  variable CM_D8_VMERR_RSV   05

  #
  # cm_start: start the dmcmon -----------------------------------------------
  #
  proc cm_start {{cpu "cpu0"} args} {
    args2opts opts { mwsup 0 imode 0 wstop 0 } {*}$args
    $cpu cp -wreg cm.cntl [regbldkv rw11::CM_CNTL func "STA" \
                             mwsup $opts(mwsup) \
                             imode $opts(imode) \
                             wstop $opts(wstop) ]
  }

  #
  # cm_stop: stop the dmcmon -------------------------------------------------
  #
  proc cm_stop {{cpu "cpu0"}} {
    $cpu cp -wreg cm.cntl [regbld rw11::CM_CNTL {func "STO"}]
  }

  #
  # suspend: suspend the dmcmon ----------------------------------------------
  #   returns 1 if already suspended
  #   that allows to implement nested suspend/resume properly
  #
  proc cm_susp {{cpu "cpu0"}} {
     $cpu cp -rreg cm.stat rstat \
             -wreg cm.cntl [regbld rw11::CM_CNTL {func "SUS"}]
    return [regget rw11::CM_STAT(susp) $rstat]
  }
  
  #
  # resume: resume the dmcmon ------------------------------------------------
  #
  proc cm_resu {{cpu "cpu0"}} {
    $cpu cp -wreg cm.cntl [regbld rw11::CM_CNTL {func "RES"}]
  }

  #
  # cm_read: read nent last entries (by default all) -------------------------
  #   returns a list, 1st entry descriptor, rest 9-tuples in d0,..,d8 order
  #
  proc cm_read {{cpu "cpu0"} {nent -1}} {
    # suspend and get address and status
    $cpu cp -rreg cm.stat rstatpre \
            -wreg cm.cntl [regbld rw11::CM_CNTL {func "SUS"}] \
            -rreg cm.cntl rcntl \
            -rreg cm.addr raddr \
            -rreg cm.stat rstat

    set bsize [regget rw11::CM_STAT(bsize) $rstat]
    set amax  [expr {( 256 << $bsize ) - 1}]
    set nmax  [expr { $amax + 1 } ]
    if {$nent == -1}   { set nent $nmax }
    if {$nent > $nmax} { set nent $nmax }

    # determine number of available items (check wrap flag)
    set laddr [regget rw11::CM_ADDR(laddr) $raddr]
    set nval  $laddr
    if {[regget rw11::CM_STAT(wrap) $rstat]} { set nval $nmax }

    if {$nent > $nval} {set nent $nval}

    # if wstop set use first nent items, otherwise last nent items
    set caddr 0
    if {![regget rw11::CM_CNTL(wstop) $rcntl]} {
      set caddr [expr {( $laddr - $nent ) & $amax}]
    }
    $cpu cp -wreg cm.addr [regbld rw11::CM_ADDR [list laddr $caddr]]

    set rval {}
    lappend rval [list $rcntl $rstat 0x0000]

    set nrest $nent
    set nblkmax [rlc get bsizeprudent]
    set ngetmax [expr {$nblkmax / 9}]
    while {$nrest > 0} {
      set nget $nrest
      if {$nget > $ngetmax} {set nget $ngetmax}
      set nblk [expr {9 * $nget}]
      $cpu cp -rblk cm.data $nblk rawdat

      foreach {d0 d1 d2 d3 d4 d5 d6 d7 d8} $rawdat {
        lappend rval [list $d0 $d1 $d2 $d3 $d4 $d5 $d6 $d7 $d8]
      }
      set nrest [expr {$nrest - $nget }]
    }

    # restore address and resume
    #   resume only if not already suspended before
    set rfu [expr {[regget rw11::CM_STAT(susp) $rstatpre] ? "NOOP" : "RES"}]
    $cpu cp -wreg cm.addr $raddr \
            -wreg cm.cntl [regbldkv rw11::CM_CNTL func $rfu]

    return $rval
  }

  #
  # cm_print: convert raw into human readable format -------------------------
  #
  proc cm_print {cmraw} {
    if {[llength $cmraw] <= 1} {return;}
    set rcntl [lindex $cmraw 0 0];        # get im.cntl
    set rstat [lindex $cmraw 0 1];        # get im.stat
    set imode [regget rw11::CM_CNTL(imode) $rcntl]
    set rsnum [regget rw11::CM_STAT(snum)  $rstat]
    set rval {}
    set line {}
    if {$imode} {
      append line " nc"
    } else {
      if {$rsnum} {
        append line "state         "
      } else {
        append line "c WS"
      }
    }

    if {$imode}  {
      append line " ....pc"
    } else {
      append line " ....pc "
      append line " ..ireg"
    }
    append line " cprptnzvc"
    append line " ..dsrc"
    append line " ..ddst"
    append line " ..dres"
    append line "      vmaddr"
    append line " vmdata"
    append rval $line 

    set first         1
    set cnum_last     0
    set vmracc_last   0
    set vmreq_pend    0
    set vmbytop       0
    set pc_last      -1
    set ireg_last    -1

    set snum2state [cm_get_snum2state]

    foreach item [lrange $cmraw 1 end] {
      set d0 [lindex $item 0]
      set d1 [lindex $item 1]
      set d2 [lindex $item 2]
      set d3 [lindex $item 3]
      set d4 [lindex $item 4]
      set d5 [lindex $item 5]
      set d6 [lindex $item 6]
      set d7 [lindex $item 7]
      set d8 [lindex $item 8]

      reggetkv rw11::CM_D8    $d8 "d8_" xnum req istart idone
      reggetkv rw11::CM_D8REQ $d8 "d8_" wacc macc cacc bytop dspace
      reggetkv rw11::CM_D8ACK $d8 "d8_" ack err tysv tmmu mwdrop
      reggetkv rw11::CM_D8ERR $d8 "d8_" vmerr
      reggetkv rw11::CM_D7    $d7 "d7_" pc idec
      set d7_pc [expr {$d7_pc << 1}]
      reggetkv rw11::CM_D5IM0 $d5 "d5_" dres_val ddst_we dsrc_we
      reggetkv rw11::CM_D5IM1 $d5 "d5_" vfetch

      set p_iflag " "
      if {$d8_istart}              {set p_iflag "-"}
      if {$d8_idone}               {set p_iflag "|"}
      if {$d8_istart && $d8_idone} {set p_iflag "+"}

      set p_vm    "    "
      if {$d8_req} {
        set vmbytop $d8_bytop
        set p_vmrw  [expr {$d8_wacc ? "w" : "r"}]
        set p_vmmmc " "
        if {$d8_macc} {set p_vmmmc "m"}
        if {$d8_cacc} {set p_vmmmc "c"}
        set p_vmbytop [expr {$d8_bytop  ? "b" : " "}]
        set p_vmspace [expr {$d8_dspace ? "d" : "i"}]
        set p_vm "${p_vmrw}${p_vmmmc}${p_vmbytop}${p_vmspace}"
      } elseif {$d8_ack} {
        set p_mwdrop " "
        set p_trap   "  "
        if {$d8_mwdrop} {set p_mwdrop "+"}
        if {$d8_tmmu}   {set p_trap   "mm"}
        if {$d8_tysv}   {set p_trap   "ys"}; # ysv has precedence
        set p_vm "a${p_mwdrop}${p_trap}"
      } elseif {$d8_err} {
        set p_err "   "
        if {$d8_vmerr == $rw11::CM_D8_VMERR_ODD}   {set p_err "odd"}
        if {$d8_vmerr == $rw11::CM_D8_VMERR_MMU}   {set p_err "mmu"}
        if {$d8_vmerr == $rw11::CM_D8_VMERR_NXM}   {set p_err "nxm"}
        if {$d8_vmerr == $rw11::CM_D8_VMERR_IOBTO} {set p_err "bto"}
        if {$d8_vmerr == $rw11::CM_D8_VMERR_RSV}   {set p_err "rsv"}
        set p_vm "E${p_err}"
      }

      set line "\n"
      if {$imode} {
        set ccnt [expr {$d8_xnum - $cnum_last}]
        if {$ccnt < 0} {set ccnt [expr {$ccnt + 256}]}
        if {$first}    {set ccnt 0}
        append line [format %3d $ccnt]
      } else {
        if {$rsnum} {
          set snam [lindex $snum2state $d8_xnum]
          append line [format %-14s $snam]
        } else {
          set snumcat "-"
          if {[regget rw11::CM_FSNUM(con) $d8_xnum]} {set snumcat "c"}
          if {[regget rw11::CM_FSNUM(ins) $d8_xnum]} {set snumcat "i"}
          if {[regget rw11::CM_FSNUM(vec) $d8_xnum]} {set snumcat "v"}
          if {[regget rw11::CM_FSNUM(err) $d8_xnum]} {set snumcat "e"}
          set snumvmw " "
          if {[regget rw11::CM_FSNUM(vmw) $d8_xnum]} {set snumvmw "W"}
          append line "$snumcat $snumvmw "
        }
      }

      if {$imode} {
        append line " [cm_print_coct $d7_pc 1 1]"
      } else {
        append line " [cm_print_coct $d7_pc $d7_idec 1]${p_iflag}"
        append line " [cm_print_coct $d6 $d7_idec 1]"
      }

      append line " [rw11::ps2txt $d5]"

      append line " [cm_print_coct $d4 [expr {$d5_dsrc_we  || $imode}] 1]"
      append line " [cm_print_coct $d3 [expr {$d5_ddst_we  || $imode}] 1]"
      append line " [cm_print_coct $d2 [expr {$d5_dres_val || $imode}] 0]"

      append line " ${p_vm}"
      append line " [cm_print_coct $d1 [expr {$d8_req || $imode}] $vmreq_pend]"
      set p_new [expr {( $d8_req && $d8_wacc )     || \
                       ( $d8_req==0 && $d8_ack && $vmracc_last ) || \
                         $imode }]
      append line " [cm_print_coct $d0 $p_new 0 $vmbytop]"

      if {$imode} {
        if {$d5_vfetch} {
          set vnam [string toupper [rw11::dasm_vec2txt $d1]]
          append line " !VFETCH [format %3.3o $d1] ${vnam}"
        } else {
          # if vmerr and same pc,ireg as previous entry suppress dasm line
          # that ensures that ifetch Eodd's will not give double dasm lines
          if {$d8_req==0 && $d8_err && $d7_pc==$pc_last && $d6==$ireg_last} {
            append line " !VMERR ${p_vm}"
          } else {
            append line " [dasm_ireg2txt $d6]"
          }
        }
      } else {
        if {$d7_idec} {append line " [dasm_ireg2txt $d6]"}
      }

      append rval $line

      set cnum_last  $d8_xnum
      if {$d8_req} {
        set vmracc_last [expr {!$d8_wacc}]
        set vmreq_pend 1
      } elseif {$d8_ack || $d8_err} {
        set vmreq_pend 0
      }
      set first 0
      set pc_last   $d7_pc
      set ireg_last $d6
    }
    return $rval
  }

  proc cm_print_coct {data new valid {bytop 0}} {
    if {$new}   {
      if {$bytop == 0} {
        return [format %6.6o $data]
      } else {
        return [format "   %3.3o" [expr {$data & 0xff}]]
      }
    }
    if {$valid} {return "   ..."}
    return "     ."
  }

  #
  # cm_raw2txt: converts raw data list into a storable text format -----------
  #
  proc cm_raw2txt {cmraw} {
    set len [llength $cmraw]
    if {$len == 0} {return}
    set rval [format "# cntl,stat,type: %6.6o %6.6o %6.6o" \
                [lindex $cmraw 0 0] [lindex $cmraw 0 1] [lindex $cmraw 0 2]]
    append rval "\n# d8 ....pc ..ireg ...psw ..dsrc ..ddst ..dres vmaddr vmdata" 
    for {set i 1} {$i < $len} {incr i} {
      append rval [format \
        "\n%4.4x %6.6o %6.6o %6.6o %6.6o %6.6o %6.6o %6.6o %6.6o"  \
          [lindex $cmraw $i 8] [lindex $cmraw $i 7] [lindex $cmraw $i 6] \
          [lindex $cmraw $i 5] [lindex $cmraw $i 4] [lindex $cmraw $i 3] \
          [lindex $cmraw $i 2] [lindex $cmraw $i 1] [lindex $cmraw $i 0] ]
    }
    return $rval
  }

  #
  # cm_txt2raw: converts storable text format back in raw data list ----------
  #
  proc cm_txt2raw {text} {
    set rval {}
    set first 1
    foreach line [split $text "\n"] {
      set flist [split $line]
      if {$first} {
        lappend rval [lrange $flist 2 end]
        set first 0
        continue
      }
      if {[string match "#*" $line]} {continue}
      set d8 "0x[lindex $flist 0]"
      set d7  "0[lindex $flist 1]"
      set d6  "0[lindex $flist 2]"
      set d5  "0[lindex $flist 3]"
      set d4  "0[lindex $flist 4]"
      set d3  "0[lindex $flist 5]"
      set d2  "0[lindex $flist 6]"
      set d1  "0[lindex $flist 7]"
      set d0  "0[lindex $flist 8]"
      lappend rval [list $d0 $d1 $d2 $d3 $d4 $d5 $d6 $d7 $d8]
    }
    return $rval
  }

  #
  # cm_get_snum2state --------------------------------------------------------
  #
  proc cm_get_snum2state {} {
    set retrobase $::env(RETROBASE)
    set fname "$retrobase/rtl/w11a/pdp11_sequencer.vhd"
    set fd [open $fname r]
    
    set act  0
    set smax 0 
    while {[gets $fd line] >= 0} {
      if {[regexp -- {^\s*-- STATE2SNUM mapper begin} $line]} {
        set act 1
        continue
      }
      if {!$act} {continue}
      if {[regexp -- {^\s*-- STATE2SNUM mapper end} $line]} {break}
      if {[regexp -- {^\s*$} $line]} {continue}
      #puts $line
      set r [regexp -- {^\s+when\s+(\w+)\s+=>.*:=\s*x"(.*)";} $line dummy m1 m2]
      if {$r} {
        set snum "0x$m2"
        set snam [string range $m1 2 end]; # strip leading s_
        set snam2snum($snam) $snum
        if {$snum > $smax} {set smax $snum}
      }
    }
    set rval {}
    for {set i 0} {$i <= $smax} {incr i} {lappend rval {}}
    foreach key [array names snam2snum] {
      lset rval $snam2snum($key) $key
    }

    close $fd
    return $rval
  }

  #
  # cm_read_lint: read lint (last instruction) context -----------------------
  #   returns list of lists
  #   1. stat,ipc,ireg
  #   2. mal list (CM_STAT.malcnt entries)
  #   3. regs list ps,r0,...,pc  (optional if $regs != 0)
  #
  proc cm_read_lint {{cpu "cpu0"} {regs 0}} {
    set clist {}
    lappend clist -rreg cm.stat rstat
    lappend clist -rreg cm.ipc  ripc
    lappend clist -rreg cm.ireg rireg
    lappend clist -rblk cm.imal 16 rimal
    if {$regs} {
      foreach reg {ps r0 r1 r2 r3 r4 r5 sp pc} {lappend clist -r${reg} ${reg} }
    }

    $cpu cp {*}$clist

    set malcnt [regget rw11::CM_STAT(malcnt) $rstat]
    set rimal  [lreplace $rimal [expr {$malcnt + 1}] end]; # keep only defined

    set rval list [list $rstat $ripc $rireg] $rimal
    if {$regs} {lappend rval [list $rps $rr0 $rr1 $rr2 $rr3 $rr4 $rr5 $rsp $rpc]}

    return $rval
  }

  #
  # cm_print_lint: print lint (last instruction) context ---------------------
  #
  proc cm_print_lint {cmlraw} {
    set stat [lindex $cmlraw 0 0]
    set ipc  [lindex $cmlraw 0 1]
    set ireg [lindex $cmlraw 0 2]
    set mal  [lindex $cmlraw 1]
    set nmal [llength $mal]

    set bwf   "w"
    set aclist {}
    set dsc [dasm_getdsc $ireg]
    if {[llength $dsc] != 0} {
      set acinf [lindex $dsc 4]
      set bwf   [lindex $dsc 5]
      foreach acmod $acinf {
        set actyp [string range $acmod 0 0]
        if {$actyp eq "s"} {
          set regmod [expr {($ireg >> 6) & 077}]
          lappend aclist {*}[dasm_acmod2aclist $acmod $regmod]
        } elseif {$actyp eq "d"} {
          set regmod [expr { $ireg       & 077}]
          lappend aclist {*}[dasm_acmod2aclist $acmod $regmod]
        } else {
          lappend aclist $acmod
        }
      }
      
      set rilist   {}
      set line2    ""
      foreach {ma md} $mal {
        set acmod  [lindex $aclist 0]
        set aclist [lreplace $aclist 0 0]
        switch $acmod {
          ri      {lappend rilist $md}
          ra      {append line2 [format "%6.6o->" $ma]}
          rd      {append line2 [format "%6.6o->%6.6o; " $ma $md]}
          wd      {append line2 [format "%6.6o<-%6.6o; " $ma $md]}
          md      {set line2 [string range $line2 0 end-2]
                   append line2 [format "<-%6.6o; " $md]}
          default {append line2 [format "%s:%6.6o:%6.6o; " $acmod $ma $md]}
        }
      }

      set itxt [dasm_iline $ireg $dsc $rilist]
      set rval [format "pc: %6.6o ireg: %6.6o na:%2d  %s" $ipc $ireg $nmal $itxt]
      if {$line2 ne ""} {append rval "\n  $line2"}

    } else {
      set rval [format "pc: %6.6o ireg: %6.6o na:%2d" $ipc $ireg $na]
      foreach {ma mv} $mal {
        append rval [format "\n  %6.6o : " $ma]
        if {$mv ne ""} append rval [format "%6.6o" $mv]
      }
    }

    if {[llength $cmlraw] > 2} {
      append regs [lindex $cmlraw 2]
      append rval "\n  ps: [rw11::ps2txt [lindex $regs 0]]" 
      append rval [format " rx: %6.6o %6.6o %6.6o %6.6o %6.6o %6.6o" \
                     [lindex $regs 1] [lindex $regs 2] [lindex $regs 3]
                     [lindex $regs 4] [lindex $regs 5] [lindex $regs 6]]
      set rpc [lindex $regs 8]
      set p_br "";              # FIXME !!
      append vval [format "  %6.6o %6.6o%s" \
                     [lindex $regs 7] $rpc $p_br]
    }

    return $rval
  }

  #
  # === high level procs: compact usage (also by rw11:shell) =================
  #
  # cme: dmcmon enable -------------------------------------------------------
  #
  proc cme {{cpu "cpu0"} {mode ""}} {
    if {![regexp {^n?[isS]?$} $mode]} {
      error "cme-E: bad mode '$mode', only n plus [isS] allowed"
    }

    set wstop [string match *n* $mode]
    set imode 1
    set mwsup 0
    if {[string match *s* $mode]} {set imode 0; set mwsup 1}
    if {[string match *S* $mode]} {set imode 0; set mwsup 0}

    rw11::cm_start $cpu imode $imode mwsup $mwsup wstop $wstop
    return
  }

  #
  # cml: dmcmon list ---------------------------------------------------------
  #
  proc cml {{cpu "cpu0"} {nent -1}} {
    return [rw11::cm_print [rw11::cm_read $cpu $nent]]
  }

}
