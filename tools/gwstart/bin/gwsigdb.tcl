# $Id: gwsigdb.tcl 1194 2019-07-20 07:43:21Z mueller $
# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright 2016- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
#
#  Revision History:
# Date         Rev Version  Comment
# 2016-10-03   812   1.1    gwlssig,gwlshier: support selection; use pglobre
# 2016-07-23   792   1.0    Initial version
#

package provide gwtools 1.0

namespace eval gwtools {
  variable siglist;             # list of full signal names without index range 
  variable sigtype;             # hash with index range per signal
  variable sighier;             # hash with list of signals per hierarchy path
  array set sigtype {}
  array set sighier {}

  #
  # addsighier: add a signal to sighier array of lists ---------------
  #
  proc addsighier {nam} {
    variable sighier
    #puts "+++2a '$nam'"
    if {[regexp -- {^(.*)\.(.*)$} $nam match path last]} {
      if {! [info exists sighier($path)]} {addsighier $path} 
      lappend sighier($path) $last
      #puts "+++2b '$path' '$last'"
    }
    return
  }

  #
  # initsigdb: setup siglist,sigtype,sighier from gtkwave facilities -
  #
  proc initsigdb {} {
    variable siglist
    variable sigtype
    variable sighier

    # get all facilities
    set nfac [ gtkwave::getNumFacs ]
    set faclist {}
    for {set i 0} {$i < $nfac } {incr i} {
      lappend faclist  [ gtkwave::getFacName $i ]
    }
    
    # Note: for ghdl+ghw gtkwave often reports one signal multiple times in
    #       the list of facilities. Using '-unique' removes them
    set faclist [lsort -unique -dictionary $faclist]

    foreach fac $faclist {
      # split into name + index
      set nam {}
      set ind {}
      if {! [regexp -- {^(.*)\[(\d*)\]$} $fac match nam ind]} {
        set nam $fac
      }
      #puts "+++1 '$nam' '$ind'"
      if {! [info exists sigtype($nam)]} {
        addsighier $nam
        set sigtype($nam) $ind;            # if no index --> empty list 
      } else { 
        lappend sigtype($nam) $ind
      }
    }

    # collaps index list in [high:low]
    foreach sig [array names sigtype] {
      if {[llength $sigtype($sig)]} {
        set ilist [lsort -integer $sigtype($sig)]
        set ibeg [lindex $ilist 0]
        set iend [lindex $ilist end]
        set sigtype($sig) "\[$iend:$ibeg\]"
        #puts "+++3 '$sig' '$sigtype($sig)'"
      }
    }

    # resort sighier lists (recursive adding of parents via  addsighier
    #   can break sorting order
    foreach sig [array names sighier] {
      set sighier($sig) [lsort -dictionary $sighier($sig)]
    }

    # finally setup siglist (from array names of sigtype)
    set siglist [lsort -dictionary [array names sigtype]]

    return
  }

  #
  # gwlshier: list hierarchy table (with collapsed indices) ----------
  #
  proc gwlshier {args} {
    variable sighier
    set rtxt {}

    # process options
    array set opts {re 0 sig 0}
    while {[llength $args]} {
      set arg [lindex $args 0]
      set next 1
      switch -glob $arg {
        -re     { set opts(re)    1}
        -sig    { set opts(sig)   1}
        -*      { error "bad option $arg"}
        default { break }
      }
      set args [lrange $args $next end]
    }

    # if no selection specifier given take all (like -re .*)
    if {! [llength $args]} {
      set opts(re) 1
      set args {.*}
    }

    # process hierarchy path names
    set hlist [lsort -dictionary [array names sighier]]
    set hiers {}
    foreach arg $args {
      # trim white space (allows to write '{\out\ }' to prevent a '\}'
      set re [string trim $arg]
      if {! $opts(re)} {
        set re [pglobre $re]
      }
      foreach hier $hlist {
        if {[regexp -- $re $hier]} {
          lappend hiers $hier
        }
      }      
    }
    set hiers [lsort -unique -dictionary $hiers]

    foreach hier $hiers {
      append rtxt "$hier\n"

      if ($opts(sig)) {         # show signals when -sig option seen
        array unset namind
        array set namind {}
        foreach val $sighier($hier) {
          if {[regexp -- {^(.*)\[(\d*)\]$} $val match nam ind]} {
            lappend namind($nam) $ind
          } else {
            set namind($val) {}
          }
        }
        foreach nam [lsort -dictionary [array names namind]] {
          if {[llength $namind($nam)]} {
            set ilist [lsort -integer $namind($nam)]
            set ibeg [lindex $ilist 0]
            set iend [lindex $ilist end]
            append rtxt "   $nam\[$ibeg:$iend\]\n"
          } else {
            append rtxt "   $nam\n"
          }
        }
      }     
    }
    return [string trimright $rtxt]
  }

  #
  # gwlssig: list signal table ---------------------------------------
  #
  proc gwlssig {args} {
    variable siglist
    variable sigtype

    # process options
    array set opts {list 0 re 0}
    while {[llength $args]} {
      set arg [lindex $args 0]
      set next 1
      switch -glob $arg {
        -list   { set opts(list) 1}
        -re     { set opts(re)   1}
        -*      { error "bad option $arg" }
        default { break }
      }
      set args [lrange $args $next end]
    }

    # if no selection specifier given take all (like -re .*)
    if {! [llength $args]} {
      set opts(re) 1
      set args {.*}
    }

    # process signal names
    set sigs {}
    foreach arg $args {
      # trim white space (allows to write '{\out\ }' to prevent a '\}'
      set re [string trim $arg]
      if {! $opts(re)} {
        set re [pglobre $re]
      }
      foreach sig $siglist {
        if {[regexp -- $re $sig]} {
          lappend sigs "$sig$sigtype($sig)"
        }
      }      
    }
    set sigs [lsort -unique -dictionary $sigs]

    if ($opts(list)) { return $sigs }

    set rtxt {}
    foreach sig $sigs {
      append rtxt "$sig\n"
    }
    return [string trimright $rtxt]
  }

  namespace export gwlshier
  namespace export gwlssig
}

namespace import gwtools::gwlshier
namespace import gwtools::gwlssig
