# $Id: util.tcl 1143 2019-05-01 13:25:51Z mueller $
#
# Copyright 2019- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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
# 2019-05-01  1143   1.0    Initial version
#

package provide ibd_m9312 1.0

package require rlink
package require rw11util
package require rw11

namespace eval ibd_m9312 {
  #
  # setup register descriptions for ibd_m9312 --------------------------------
  #
  set A_LOROM 0165000
  set A_HIROM 0173000
  regdsc RCSR  {locwe 7} {enahi 1} {enalo 0}

  rw11util::regmap_add ibd_m9312 m9.csr {r? RCSR}

  #
  # boot: load m9312 from mac source and start -------------------------------
  #
  proc boot {{cpu "cpu0"} {fnam ""}} {
    $cpu cp -stapc [load $cpu $fnam]
    return;
  }

  #
  # load: load m9312 from mac source -----------------------------------------
  #
  proc load {{cpu "cpu0"} {fnam ""}} {
    if {$fnam eq ""} {
      set fnam "$::env(RETROBASE)/tools/mcode/m9312/bootw11.mac"
    }
    if {! [file readable $fnam]} {
      error "m9312::load-E: file '$fnam' not found"
    }

    $cpu cp -wibr m9.csr [regbld ibd_m9312::RCSR locwe]

    if { [catch {loadfile $cpu $fnam} start] } {
      $cpu cp -wibr m9.csr 0x0
      error $start
    }
    $cpu cp -wibr m9.csr [regbld ibd_m9312::RCSR enalo enahi]
    return $start;
  }

  #
  # loadfile: helper to perform the actual file load -------------------------
  #
  proc loadfile {cpu fnam} {
    set start 1;
    if {[string match "*.mac" $fnam]} {
      $cpu ldasm -file $fnam -sym ldasm_sym
      if {[info exists ldasm_sym(...end)]} { set start $ldasm_sym(...end) }
    } else {
      $cpu ldabs $fnam start
    }
    if {($start < $ibd_m9312::A_LOROM ||
         $start > [expr {$ibd_m9312::A_LOROM + 0776}]) &&
        ($start < $ibd_m9312::A_HIROM ||
         $start > [expr {$ibd_m9312::A_HIROM + 0776}])} {
      error "m9312::load-E: start address not specified or not in ROM"
    }
    return $start
  }
}
