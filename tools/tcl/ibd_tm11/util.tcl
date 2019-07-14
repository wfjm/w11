# $Id: util.tcl 1180 2019-07-08 15:46:59Z mueller $
# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright 2015-2019 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
#
#  Revision History:
# Date         Rev Version  Comment
# 2019-07-08  1180   1.0.2  add sym def for CR.den values
# 2015-12-26   719   1.0.1  add regmap_add defs
# 2015-05-17   683   1.0    Initial version
#

package provide ibd_tm11 1.0

package require rlink
package require rw11util
package require rw11

namespace eval ibd_tm11 {
  #
  # setup register descriptions for ibd_tm11 ---------------------------------
  #

  regdsc SR {icmd 15} {eof 14} {pae 12} {eot 10} {rle 9} {bte 8} {nxm 7} \
    {onl 6} {bot 5} {wrl 2} {rew 1} {tur 0}

  regdsc CR {err 15} {den 14 2 "s:D72:D75:D78:D98"} \
    {ini 12} {pevn 11} {unit 10 3} {rdy 7} {ie 6} {ea 5 2} \
    {func 3 3 "s:UNLOAD:READ:WRITE:WEOF:SFORW:SBACK:WRTEG:REWIND"} \
    {go 0}
  variable FUNC_UNLOAD [bvi b3 "000"]
  variable FUNC_READ   [bvi b3 "001"]
  variable FUNC_WRITE  [bvi b3 "010"]
  variable FUNC_WEOF   [bvi b3 "011"]
  variable FUNC_SFORW  [bvi b3 "100"]
  variable FUNC_SBACK  [bvi b3 "101"]
  variable FUNC_WRTEG  [bvi b3 "110"]
  variable FUNC_REWIND [bvi b3 "111"]

  regdsc RCR {icmd 15} {pae 12} {rle 9} {bte 8} {nxm 7} {unit 5 2} \
    {func 3 3 "s:FU0:WUNIT:DONE:FU3:FU4:FU5:FU6:FU7"} \
    {go 0}
  variable RFUNC_WUNIT [bvi b3 "001"]
  variable RFUNC_DONE  [bvi b3 "010"]

  regdsc RRL {eof 10} {eot 9} {onl 8} {bot 7} {wrl 6} {rew 5} {unit 2 2}

  rw11util::regmap_add ibd_tm11 tm?.sr {?? SR}
  rw11util::regmap_add ibd_tm11 tm?.cr {l? CR rr CR rw RCR}
  rw11util::regmap_add ibd_tm11 tm?.rl {r? RRL}

  variable ANUM 7

  #
  # setup: create controller with default attributes -------------------------
  #
  proc setup {{cpu "cpu0"}} {
    return [rw11::setup_cntl $cpu "tm11" "tma"]
  }

  #
  # rcr_wunit: value for rem CR WUNIT function -----------------------------
  #
  proc rcr_wunit {unit} {
    return [regbld ibd_tm11::RCR [list unit $unit] \
              [list func $ibd_tm11::RFUNC_WUNIT] ]
  }

  #
  # cr_func: value for loc CR function start -------------------------------
  #
  proc cr_func {func} {
    return [regbld ibd_tm11::CR  \
                                 [list func $func] {go 1}]
  }

  #
  # rdump: register dump - rem view ------------------------------------------
  #
  proc rdump {{cpu "cpu0"}} {
    set rval {}
    $cpu cp -ribr "tma.sr"  sr \
            -ribr "tma.cr"  cr \
            -ribr "tma.bc"  bc \
            -ribr "tma.ba"  ba \
            -wibr "tma.cr"  [rcr_wunit 0] \
            -ribr "tma.rl"  sr0 \
            -wibr "tma.cr"  [rcr_wunit 1] \
            -ribr "tma.rl"  sr1 \
            -wibr "tma.cr"  [rcr_wunit 2] \
            -ribr "tma.rl"  sr2 \
            -wibr "tma.cr"  [rcr_wunit 3] \
            -ribr "tma.rl"  sr3 \

    if {$bc} {
      set fbc [format "%d" [expr {64 * 1024 - $bc}]]
    } else {
      set fbc "(0)"
    }

    append rval "Controller registers:"
    append rval [format "\n  sr:  %6.6o  %s" $sr [regtxt ibd_tm11::SR $sr]]
    append rval [format "\n  cr:  %6.6o  %s" $cr [regtxt ibd_tm11::CR $cr]]
    append rval [format "\n  bc:  %6.6o  nb=%s" $bc $fbc]
    append rval [format "\n  ba:  %6.6o"     $ba]

    append rval "\nUnit registers:"
    append rval [format "\n  sr0: %6.6o  %s" $sr0 [regtxt ibd_tm11::RRL $sr0 ]]
    append rval [format "\n  sr1: %6.6o  %s" $sr1 [regtxt ibd_tm11::RRL $sr1 ]]
    append rval [format "\n  sr2: %6.6o  %s" $sr2 [regtxt ibd_tm11::RRL $sr2 ]]
    append rval [format "\n  sr3: %6.6o  %s" $sr3 [regtxt ibd_tm11::RRL $sr3 ]]

    return $rval
  }
}
