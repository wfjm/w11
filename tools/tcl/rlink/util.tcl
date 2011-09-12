# $Id: util.tcl 403 2011-08-06 17:36:22Z mueller $
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
# 2011-08-06   403   1.0.1  add SINT and SINIT defs for serport init
# 2011-03-26   373   1.0    Initial version
# 2011-03-19   372   0.1    First draft
#

package provide rlink 1.0

package require rutil 1.0

namespace eval rlink {
  regdsc STAT  {stat 7 3} {attn 4} {cerr 3} {derr 2} {rbnak 1} {rberr 0}
  regdsc INIT  {anena 15} {itoena 14} {itoval 7 8}
  regdsc SINIT {fena 12} {fwidth 11 3} {fdelay 8 3} {rtsoff 5 3} {rtson 2 3}
  #
  # 'pseudo register', describes 3rd word in return list element for -rlist
  regdsc FLAGS {vol 16} \
    {chkdata 13} {chkstat 12} \
    {errcrc 11} {errcmd 10}  {errmiss 9} {errnak 8} \
    {resend 7} {recov 6} {pktend 5} {pktbeg 4} \
    {done 2} {send 1} {init 0} 

  variable IINT 0x00ff
  variable SINT 0x00fe

  #
  # init: reset rlink: disable enables; clear attn register
  #
  proc init {} {
    rlc exec \
      -init $rlink::IINT 0x0000 \
      -init $rlink::SINT [regbld rlink::SINIT {rtsoff 7} {rtson 6} ] \
      -attn
    return ""
  }
  #
  # isopen: returns 1 if open and 0 if close
  #
  proc isopen {} {
    if {[rlc open] eq ""} { return 0 }
    return 1
  }
  #
  # isfifo: returns 1 if open and fifo, 0 otherwise
  #
  proc isfifo {} {
    set name [rlc open]
    if {$name ne "" && [regexp -- {^fifo:} $name]} { return 1 }
    return 0
  }
  #
  # issim: returns 1 if open and in simulation mode, 0 otherwise
  #
  proc issim {} {
    if {![info exists rlink::sim_mode]} { return 0}
    return $rlink::sim_mode
  }
}
