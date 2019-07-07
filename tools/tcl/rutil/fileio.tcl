# $Id: fileio.tcl 1177 2019-06-30 12:34:07Z mueller $
# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright 2015- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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
