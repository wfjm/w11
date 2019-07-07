# $Id: util.tcl 1177 2019-06-30 12:34:07Z mueller $
# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright 2014-2017 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
#
#  Revision History:
# Date         Rev Version  Comment
# 2017-05-06   894   1.0    Initial version (full functionality)
# 2017-04-14   874   0.5    Initial version (partial functionality)
# 2014-06-09   561   0.1    First draft 
#

package provide ibd_deuna 1.0

package require rlink
package require rw11util
package require rw11

namespace eval ibd_deuna {
  #
  # setup register descriptions for ibd_deuna --------------------------------
  #

  set pcmdtxt "s:NOOP:GETPCB:GETCMD:SELFTST:START:BOOT:CU06:CU07:PDMD:CU11:CU12:CU13:CU14:CU15:CU16:STOP"
  regdsc PR0 {seri 15} {pcei 14} {rxi 13} {txi 12} {dni 11} {rcbi 10} \
    {usci 8} {intr 7} {inte 6} {rset 5} \
    [list "pcmd" 3 4 $pcmdtxt]
  regdsc PR0RR [list "pcmdbp" 15 4 $pcmdtxt] {pdmdwb 10} {busy 9} {pcwwb 8}\
    {intr 7} {inte 6} {rset 5} {brst 4} \
    [list "pcmd" 3 4 $pcmdtxt]
  regdsc PR0RW {seri 15} {pcei 14} {rxi 13} {txi 12} {dni 11} {rcbi 10} \
    {busy 9} {usci 8} {rset 5} {brst 4}
  unset pcmdtxt
  
  variable PCMD_NOOP    [bvi b4 "0000"]
  variable PCMD_GETPCB  [bvi b4 "0001"]
  variable PCMD_GETCMD  [bvi b4 "0010"]
  variable PCMD_SELFTST [bvi b4 "0011"]
  variable PCMD_START   [bvi b4 "0100"]
  variable PCMD_BOOT    [bvi b4 "0101"]
  variable PCMD_PDMD    [bvi b4 "1000"]
  variable PCMD_STOP    [bvi b4 "1111"]

  regdsc PR1 {xpwr 15} {icab 14} {pcto 7} {deuna 4} \
    {state 3 4 "s:RESET:PLOAD:READY:RUN:SU04:UHALT:NHALT:NUHALT:PHALT:SU11:SU12:SU13:SU14:SU15:SU16:SLOAD"}

  variable STATE_RESET  [bvi b4 "0000"]
  variable STATE_PLOAD  [bvi b4 "0001"]
  variable STATE_READY  [bvi b4 "0010"]
  variable STATE_RUN    [bvi b4 "0011"]
  variable STATE_UHALT  [bvi b4 "0101"]
  variable STATE_NHALT  [bvi b4 "0110"]
  variable STATE_NUHALT [bvi b4 "0111"]
  variable STATE_PHALT  [bvi b4 "1000"]
  variable STATE_SLOAD  [bvi b4 "1111"]

  rw11util::regmap_add ibd_deuna xu?.pr0 {l? PR0 rr PR0RR rw PR0RW}
  rw11util::regmap_add ibd_deuna xu?.pr1 {?? PR1}

  variable ANUM 9

  #
  # setup: create controller with default attributes -------------------------
  #
  proc setup {{cpu "cpu0"}} {
    return [rw11::setup_cntl $cpu "deuna" "xua"]
  }

  #
  # rdump: register dump - rem view ------------------------------------------
  #
  proc rdump {{cpu "cpu0"}} {
    set rval {}
    $cpu cp -ribr "xua.pr0"  pr0 \
            -ribr "xua.pr1"  pr1 \
            -ribr "xua.pr2"  pr2 \
            -ribr "xua.pr3"  pr3

    set pcbb [expr {$pr2 + ($pr3<<16) }]

    append rval "Controller registers:"
    append rval [format "\n  pr0:  %6.6o  %s" $pr0 [regtxt ibd_deuna::PR0 $pr0]]
    append rval [format "\n  pr1:  %6.6o  %s" $pr1 [regtxt ibd_deuna::PR1 $pr1]]
    append rval [format "\n  pr2:  %6.6o" $pr2] 
    append rval [format "\n  pr3:  %6.6o  %s" $pr3 [format "pcbb: %7.7o" $pcbb]]

    return $rval
  }
}
