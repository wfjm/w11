# $Id: perf.tcl 376 2011-04-17 12:24:07Z mueller $
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
# 2011-04-17   376   1.0    Initial version
#

package provide rbbram 1.0

namespace eval rbbram {
  #
  # perf_blk: determine wblk/rblk write performance
  # 
  proc perf_blk {{tmax 1000}} {
    if {$tmax < 1} { error "-E: perf_blk: tmax argument must be >= 1" }

    set amax [regget rbbram::CNTL(addr) -1]
    set rval \
"nblk   1 wblk   |  2 wblk   |  4 wblk   |  1 rblk   |  2 rblk   |  4 rblk   "
    append rval \
"\n      ms/r  kB/s  ms/r  kB/s  ms/r  kB/s  ms/r  kB/s  ms/r  kB/s  ms/r  kB/s"

    foreach nblk {1 2 4 8 16 32 64 128 256} {
      set wbuf0 {}
      set wbuf1 {}
      set wbuf2 {}
      set wbuf3 {}
      for {set i 0} {$i < $nblk} {incr i} {
        lappend wbuf0 $i
        lappend wbuf1 [expr 0x1000 + $i]
        lappend wbuf2 [expr 0x2000 + $i]
        lappend wbuf3 [expr 0x3000 + $i]
      }

      set pval {}

      # single wblk
      set tbeg [clock clicks -milliseconds]
      set addr 0x0000
      for {set i 1} {1} {incr i} {
        rlc exec \
          -wreg br.cntl $addr  \
          -wblk br.data $wbuf0
        set trun [expr [clock clicks -milliseconds] - $tbeg]
        if {$trun > $tmax} { break }
        set addr [expr ( $addr + $nblk ) & $amax]
      }
      lappend pval 1 $i $trun

      # double wblk
      set tbeg [clock clicks -milliseconds]
      set addr 0x0000
      for {set i 1} {1} {incr i} {
        rlc exec \
          -wreg br.cntl $addr  \
          -wblk br.data $wbuf0 \
          -wblk br.data $wbuf1
        set trun [expr [clock clicks -milliseconds] - $tbeg]
        if {$trun > $tmax} { break }
        set addr [expr ( $addr + 2 * $nblk ) & $amax]
      }
      lappend pval 2 $i $trun

      # quad wblk
      set tbeg [clock clicks -milliseconds]
      set addr 0x0000
      for {set i 1} {1} {incr i} {
        rlc exec \
          -wreg br.cntl $addr  \
          -wblk br.data $wbuf0 \
          -wblk br.data $wbuf1 \
          -wblk br.data $wbuf2 \
          -wblk br.data $wbuf3 
        set trun [expr [clock clicks -milliseconds] - $tbeg]
        if {$trun > $tmax} { break }
        set addr [expr ( $addr + 4 * $nblk ) & $amax]
      }
      lappend pval 4 $i $trun

      # single rblk
      set tbeg [clock clicks -milliseconds]
      set addr 0x0000
      for {set i 1} {1} {incr i} {
        rlc exec \
          -wreg br.cntl $addr \
          -rblk br.data $nblk rbuf0
        set trun [expr [clock clicks -milliseconds] - $tbeg]
        if {$trun > $tmax} { break }
        set addr [expr ( $addr + $nblk ) & $amax]
      }
      lappend pval 1 $i $trun

      # double rblk
      set tbeg [clock clicks -milliseconds]
      set addr 0x0000
      for {set i 1} {1} {incr i} {
        rlc exec \
          -wreg br.cntl $addr \
          -rblk br.data $nblk rbuf0 \
          -rblk br.data $nblk rbuf1
        set trun [expr [clock clicks -milliseconds] - $tbeg]
        if {$trun > $tmax} { break }
        set addr [expr ( $addr + 2 * $nblk ) & $amax]
      }
      lappend pval 2 $i $trun

      # quad rblk
      set tbeg [clock clicks -milliseconds]
      set addr 0x0000
      for {set i 1} {1} {incr i} {
        rlc exec \
          -wreg br.cntl $addr \
          -rblk br.data $nblk rbuf0 \
          -rblk br.data $nblk rbuf1 \
          -rblk br.data $nblk rbuf2 \
          -rblk br.data $nblk rbuf3
        set trun [expr [clock clicks -milliseconds] - $tbeg]
        if {$trun > $tmax} { break }
        set addr [expr ( $addr + 4 * $nblk ) & $amax]
      }
      lappend pval 4 $i $trun

      set oline [format "\n%4d" $nblk]
      foreach {nr i trun} $pval {
        set ms [expr double($trun) / double($nr*$i)]
        set kb [expr double(2*$nr*$i*$nblk) / double($trun)]
        append oline [format " %5.1f %5.1f" $ms $kb]
      }

      append rval $oline
    }
    return $rval
  }
}
