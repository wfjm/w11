# $Id: regmap.tcl 1146 2019-05-05 06:25:13Z mueller $
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
# 2019-05-04  1146   1.0.4  add ibd_dz11
# 2019-04-30  1143   1.0.3  add ibd_m9312
# 2019-03-03  1118   1.0.2  add ibd_ibtst
# 2017-03-04   858   1.0.1  add ibd_deuna
# 2015-12-28   720   1.0    Initial version
# 2015-12-26   719   0.1    First draft
#

package provide rw11util 1.0

package require rlink
package require rwxxtpp

namespace eval rw11util {

  variable regmap
  array set regmap {}
  variable regmap_loaded 0

  #
  # regmap_add: add a register definition
  # 
  proc regmap_add {pack name amlist} {
    variable regmap
    if {[info exists regmap($name)]} {
      error "E-regmap_add: register '$name' already defined"
    }

    set regmap($name) [list $pack $amlist]    
    return
  }

  #
  # regmap_get: get a register definition
  # 
  proc regmap_get {name am} {
    variable regmap
    variable regmap_loaded

    if {!$regmap_loaded} {regmap_load}

    foreach key [array names regmap] {
      if {[string match $key $name]} {
        set dsc    $regmap($key)
        set pack   [lindex $dsc 0]
        set amlist [lindex $dsc 1]
        foreach {amp reg} $amlist {
          if {[string match $amp $am]} {
            package require $pack
            return "${pack}::${reg}"
          }
        }
      }
    }
    return
  }

  #
  # regmap_txt: get text representation of a register
  # 
  proc regmap_txt {name am val} {
    set rdsc [regmap_get $name $am]
    if {$rdsc eq ""} return
    return [regtxt $rdsc $val]
  }

  #
  # regmap_load: load all rw11 register definitions
  # 
  proc regmap_load {} {
    variable regmap_loaded
    package require rw11
    package require ibd_deuna
    package require ibd_dl11
    package require ibd_dz11
    package require ibd_ibmon
    package require ibd_ibtst
    package require ibd_lp11
    package require ibd_m9312
    package require ibd_pc11
    package require ibd_rhrp
    package require ibd_rk11
    package require ibd_rl11
    package require ibd_tm11
    set regmap_loaded 1
    return
  }

}
