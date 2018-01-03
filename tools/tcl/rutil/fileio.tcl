# $Id: fileio.tcl 985 2018-01-03 08:59:40Z mueller $
#
# Copyright 2015- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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
# 2015-07-17   701   1.0    Initial version
#

package provide rutil 1.0

package require rutiltpp

namespace eval rutil {
  #
  # tofile: write a variable to file -----------------------------------------
  #
  proc tofile {fname val} {
    if [catch {open $fname w} fout] {
      error "Cannot open $fname for writing"
    } else {
      puts $fout $val
      close $fout
    }
    return
  }

  #
  # fromfile: read a variable from file --------------------------------------
  #
  proc fromfile {fname} {
    if [catch {open $fname r} fin] {
      error "Cannot open $fname for reading"
    } else {
      set rval [read -nonewline $fin]
      close $fin
    }
    return $rval
  }

  namespace export tofile
  namespace export fromfile
}

namespace import rutil::tofile
namespace import rutil::fromfile
