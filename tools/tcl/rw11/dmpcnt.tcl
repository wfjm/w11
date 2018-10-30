# $Id: dmpcnt.tcl 1058 2018-10-21 21:46:26Z mueller $
#
# Copyright 2018- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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
# 2018-10-21  1058   1.1    add logger, pc_l* commands
# 2018-10-13  1055   1.0    Initial version
# 2018-09-23  1050   0.1    First draft
#

package provide rw11 1.0

package require rlink
package require rwxxtpp

namespace eval rw11 {
  #
  # setup dmpcnt unit register descriptions for w11a -------------------------
  #
  regdsc PC_CNTL {ainc 15} {caddr 13 5} \
                 {func 2 3 "s:NOOP:NOOP1:NOOP2:NOOP3:STO:STA:CLR:LOA"}
  regdsc PC_STAT {ainc 15} {caddr 13 5} {waddr 8} {run 0}

   # preliminary handling of counter names, hack in first version
  variable pcnt_cnames [list cpu_cpbusy cpu_km_prix cpu_km_pri0 cpu_km_wait \
                             cpu_sm cpu_um cpu_idec cpu_pcload \
                             cpu_vfetch cpu_irupt ca_rd ca_wr \
                             ca_rdhit ca_wrhit ca_rdmem ca_wrmem \
                             ca_rdwait ca_wrwait ib_rd ib_wr \
                             ib_busy rb_rd rb_wr rb_busy \
                             ext_rdrhit ext_wrrhit ext_wrflush ext_rlrxact \
                             ext_rlrxback ext_rltxact ext_rltxback ext_udec]
  variable pcnt_cindex
  set tmp_ind 0
  foreach {nam} $pcnt_cnames {
    set pcnt_cindex($nam) $tmp_ind
    incr tmp_ind
  }
  unset tmp_ind

  variable pcnt_timesta  0
  variable pcnt_timenext 0
  variable pcnt_logaftid 0
  variable pcnt_logchan  0
    
  #
  # pc_setup: rmap definitions for dmpcnt
  # 
  proc pc_setup {{cpu "cpu0"}} {
    set base [$cpu get base]
    if {[$cpu rmap -testname pc.cntl [expr {$base + 0x60}]]} {return}
    $cpu rmap -insert pc.cntl [expr {$base + 0x60}]
    $cpu rmap -insert pc.stat [expr {$base + 0x61}]
    $cpu rmap -insert pc.data [expr {$base + 0x62}]
  }

  #
  # pc_start: start the dmpcnt
  #
  proc pc_start {{cpu "cpu0"} args} {
    $cpu cp -wreg pc.cntl [regbldkv rw11::PC_CNTL func "STA" ]
  }

  #
  # pc_stop: stop the dmpcnt
  #
  proc pc_stop {{cpu "cpu0"}} {
    $cpu cp -wreg pc.cntl [regbld rw11::PC_CNTL {func "STO"}]
  }

  #
  # pc_clear: clear the dmpcnt
  #
  proc pc_clear {{cpu "cpu0"}} {
    $cpu cp -wreg pc.cntl [regbld rw11::PC_CNTL {func "CLR"}]
  }

  #
  # pc_read: read dmpcnt data
  #   returns a list of 32 float values in range 0...2^32-1
  #
  proc pc_read {{cpu "cpu0"}} {
    $cpu cp -wreg pc.cntl [regbldkv rw11::PC_CNTL func "LOA" caddr 0 ainc 1 ] \
            -rblk pc.data [expr {2*32}] blk
    set rval {}
    foreach {d0 d1} $blk {
      lappend rval  [expr {$d0 + 65536.*$d1}]
    }
    return $rval
  }

  #
  # pc_print: print dmpcnt data
  #
  proc pc_print {pclist} {
    set sn 0
    set rval ""
    append rval "#cn      count" 
    foreach {pc} $pclist {
      set cname [lindex $rw11::pcnt_cnames $sn]
      append rval [format "\n%3d  %10.0f   %s" $sn $pc $cname]
      incr sn
    }
    return $rval
  }
  
  #
  # pc_printraw: read and print dmpcnt raw data
  #
  proc pc_printraw {{cpu "cpu0"}} {
    $cpu cp -wreg pc.cntl [regbldkv rw11::PC_CNTL func "LOA" caddr 0 ainc 1 ] \
            -rblk pc.data [expr {2*32}] blk
    set sn 0
    set rval {}
    append rval "#cn   msb  lsb      count" 
    foreach {d0 d1} $blk {
      set cnt [expr {$d0 + 65536.*$d1}]
      set cname [lindex $rw11::pcnt_cnames $sn]
      append rval [format "\n%3d  %4.4x %4.4x %10.0f   %s" \
                          $sn $d1 $d0 $cnt $cname]
      incr sn
    }
    return $rval
  }
  
  #
  # pc_lsta: start logging
  #
  proc pc_lsta {{file ""}} {
    variable pcnt_timesta
    variable pcnt_timenext
    variable pcnt_logaftid
    variable pcnt_logchan

    if {$pcnt_logchan != 0} { error "pc logger already running" }

    if {$file eq ""} {
      set timestamp [clock format [clock seconds] -format "%Y-%m-%d-%H%M%S"]
      set file "pc_dmpcnt$timestamp.dat"
    }
    
    pc_clear
    pc_start

    set pcnt_logchan  [open $file w]
    fconfigure $pcnt_logchan -buffering line
    set pcnt_timesta  [clock milliseconds]
    set pcnt_timenext $pcnt_timesta
    after 0 rw11::pc_lhdl
    return ""
  }
  
  #
  # pc_lsto: stop logging
  #
  proc pc_lsto {} {
    variable pcnt_logaftid
    variable pcnt_logchan
    variable pcnt_timesta
    variable pcnt_timenext
    
    if {$pcnt_logchan == 0} { return "" }
    
    after cancel $pcnt_logaftid
    close $pcnt_logchan
    set pcnt_logchan  0
    set pcnt_timesta  0
    set pcnt_timenext 0
    set pcnt_logaftid 0
    return ""
  }
  
  #
  # pc_lcom: add comment to logger
  #
  proc pc_lcom {{comment ""}} {
    variable pcnt_logchan
    if {$pcnt_logchan == 0} { error "pc logger not running" }
    puts $pcnt_logchan "# $comment"
    return ""
  }
  
  #
  # pc_lhdl: logger handler
  #
  proc pc_lhdl {} {
    variable pcnt_timesta
    variable pcnt_timenext
    variable pcnt_logaftid
    variable pcnt_logchan
    if {$pcnt_logchan == 0} { return "" }
    set tela [expr {([clock milliseconds]-$pcnt_timesta)/1000.}]
    set pclist [pc_read]
    set line [format "%10.3f " $tela]
    foreach {pc} $pclist {
      append line [format " %1.0f" $pc]
    }
    puts $pcnt_logchan $line
    set pcnt_timenext [expr {$pcnt_timenext + 1000}]
    set dt [expr { $pcnt_timenext - [clock milliseconds]}]
    after $dt rw11::pc_lhdl
    return ""
  }  

}
