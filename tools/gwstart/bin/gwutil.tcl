# $Id: gwutil.tcl 1336 2022-12-23 19:31:01Z mueller $
# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright 2016-2022 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
#
#  Revision History:
# Date         Rev Version  Comment
# 2022-12-22  1334   1.2    provide liblist, initialize from GWSTART_LIB
# 2016-10-03   812   1.1    pglobre: new path-glob to re converter
# 2016-07-23   792   1.0    Initial version
#

package provide gwtools 1.0

namespace eval gwtools {
  #
  # doargs: handle remaining level args (after two --) ---------------
  #
  proc doargs {} {
    variable liblist
    # getArgv gives full argv ! --> remove all up to and including 2nd '--'
    set args [gtkwave::getArgv];         # seems broken, nothing returned
    set iarg 0
    set ndd  0
    foreach arg $args {
      incr iarg
      if {$arg eq "--"} {incr ndd}
      if {$ndd == 2}    {break}
    }
    set args [lrange $args $iarg end]

    # now process args as option/value pairs  # not yet functional
    #   -I path      --> lappend
    #   -A set       --> gwadd
    #   -E script    --> source

    foreach {opt val} $args {
      if { $opt eq "-I"} {
        lappend liblist $val
      } elseif { $opt eq "-A"} {
        gwadd $val
      } elseif { $opt eq "-E"} {
        if { [catch {source $val} errmsg] } {
          puts "-E: failed to source file \"$val\" with error message:"
          if {[info exists errorInfo]} {puts $errorInfo} else {puts $errmsg}
        }
      } else {
        puts "gwstart-E: invalid option '$opt'"
      }
    }
    return
  }

  #
  # doinit: handle default initialization ----------------------------
  #
  proc doinit {} {
    variable liblist
    variable siglist

    # set up include lib list from GWSTART_LIB
    if [info exists ::env(GWSTART_LIB)] {
      set liblist [split $::env(GWSTART_LIB) ":"]
    } else {
      set liblist [list "."]
    }

    # puts "+++1 #argv [llength [gtkwave::getArgv]]"
    # set up signals database
    set t0 [clock milliseconds]
    initsigdb
    set t1 [clock milliseconds]

    # handle command line args
    doargs

    # setup display after gdo files processed
    # this ensures that Zoom_Best_Fit works correctly
    gtkwave::setMarker 0;                    # -> initial values shown 
    gtkwave::/Edit/Set_Trace_Max_Hier 3;     # -> good comprise
    gtkwave::/Time/Zoom/Zoom_Best_Fit;       # -> best initial picture

    set t2 [clock milliseconds]

    puts [format \
          "gwtools init done: #fac=%5d #sig=%5d #wav=%3d; time %5.3fs/%5.3fs" \
          [gtkwave::getNumFacs] \
          [llength $siglist] \
          [llength [gtkwave::getDisplayedSignals]] \
          [expr {0.001*($t1-$t0)}] \
          [expr {0.001*($t2-$t1)}] \
         ] 
    return
  }

  #
  # pglobre: convert a path-glob specification to a regular expression
  #
  proc pglobre {pglob} {
    # trim white space (allows to write '{\out\ }' to prevent a '\}'
    set re [string trim $pglob]
    # escape all regexp chars
    set re [string map { .  \\.
                         [  \\[
                         ]  \\]
                         ^  \\^
                        \\  \\\\
                       } $re ]
    # and map ** and * to regexp
    set re [string map { **     .* 
                          *  [^.]*
                       } $re] 
    set re "^${re}\$"
    return $re
  }
}
