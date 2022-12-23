# $Id: gwsigdisp.tcl 1336 2022-12-23 19:31:01Z mueller $
# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright 2016-2022 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
#
#  Revision History:
# Date         Rev Version  Comment
# 2022-12-22  1334   1.2    add gwadd
# 2016-10-03   812   1.1    gwaddsig: use gwlssig
# 2016-09-18   809   1.0.1  double '\' in signal names passed to gtkwave:: procs
# 2016-07-23   792   1.0    Initial version
#

package provide gwtools 1.0

namespace eval gwtools {
  #
  # gwaddsig ---------------------------------------------------------
  #
  proc gwaddsig {args} {
    variable siglist
    variable sigtype
    
    # process options
    array set opts {re 0 rad ""}
    while {[llength $args]} {
      set arg [lindex $args 0]
      set next 1
      switch -glob $arg {
        -re     { set opts(re)   1}
        -bin    { set opts(rad)  "bin"}
        -oct    { set opts(rad)  "oct"}
        -dec    { set opts(rad)  "dec"}
        -sdec   { set opts(rad)  "sdec"}
        -hex    { set opts(rad)  "hex"}
        -asc    { set opts(rad)  "asc"}
        -*      { error "bad option $arg" }
        default { break }
      }
      set args [lrange $args $next end]
    }

    if {! [llength $args]} {return "gwaddsig-W: no signals specified"}

    # get signal names
    set olist "-list"
    if {$opts(re)} {lappend olist "-re"}
    set sigs [gwlssig {*}$olist {*}$args]
    if {! [llength $sigs]} {return "gwaddsig-W: no signals matched"}

    # now add signals to display
    foreach sig $sigs {
      # double '\' in signal names, gtkwave needs this for some reason...
      set sig [string map {\\ \\\\} $sig]
      gtkwave::addSignalsFromList $sig
      if {$opts(rad) ne ""} {
        gtkwave::highlightSignalsFromList $sig
        switch $opts(rad) {
          bin     {gtkwave::/Edit/Data_Format/Binary}
          oct     {gtkwave::/Edit/Data_Format/Octal}
          dec     {gtkwave::/Edit/Data_Format/Decimal}
          sdec    {gtkwave::/Edit/Data_Format/Signed_Decimal}
          hex     {gtkwave::/Edit/Data_Format/Hex}
        }
      }
    }

    return [llength $sigs]
  }

  #
  # gwaddcom ---------------------------------------------------------
  #
  proc gwaddcom {{text ""}} {
    ::gtkwave::/Edit/Insert_Comment $text
  }

  #
  # gwadd ------------------------------------------------------------
  #
  proc gwadd {fname} {
    variable liblist
    foreach lib $liblist {
      set fullname "$lib/${fname}.tcl"
      if { [file exists $fullname] } {
        if { [catch {source $fullname} errmsg] } {
          puts "gwadd-E: failed to source \"$fname\" with error message:"
          if {[info exists errorInfo]} {puts $errorInfo} else {puts $errmsg}
          return
        }
        return
      }
    }
    return "gwadd-W: file $fname not found"
  }

  namespace export gwaddsig
  namespace export gwaddcom
  namespace export gwadd
}

namespace import gwtools::gwaddsig
namespace import gwtools::gwaddcom
namespace import gwtools::gwadd
