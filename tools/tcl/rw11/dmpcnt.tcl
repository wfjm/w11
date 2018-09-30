# $Id: dmpcnt.tcl 1051 2018-09-29 15:29:11Z mueller $
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
# 2018-09-29  1051   1.0    Initial version
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
  variable pcnt_cnames {cpu_cpbusy cpu_km_prix cpu_km_pri0 cpu_km_wait \
                        cpu_sm cpu_um cpu_idec cpu_vfetch \
                        cpu_irupt cpu_pcload ca_rd ca_wr \
                        ca_rdhit -ca_wrhit -ca_rdmem -ca_wrmem \
                        -ca_rdwait -ca_wrwait ib_rd ib_wr \
                        ib_busy rb_rd rb_wr rb_busy \
                        -ext_rdrhit -ext_wrrhit -ext_wrflush -ext_rlrdbusy \
                        -ext_rlrdback -ext_rlwrbusy -ext_rlwrback clock}
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

}
