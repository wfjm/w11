# $Id: tcodes.tcl 1249 2022-07-08 06:27:59Z mueller $
# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright 2022- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
#
#  Revision History:
# Date         Rev Version  Comment
# 2022-07-07  1249   1.0    Initial version (derived from tbench.tcl)
#

package provide rw11 1.0

package require rlink
package require rwxxtpp

namespace eval rw11 {

  #
  # tcodes: driver for tcode execution
  #
  proc tcodes {tname} {
    set fname $tname
    set tbase "."
    if {[string match "@*" $tname]} {
      set fname [string range $tname 1 end]
    }
    if {![file exists $fname]} {set tbase "$::env(RETROBASE)/tools/tcode"}

    rlink::anena 1;             # enable attn notify
    set errcnt [tcodes_list $tname $tbase]
    return $errcnt
  }

  #
  # tcodes_list: execute list of tcodes
  #
  proc tcodes_list {tname tbase} {
    set errcnt 0

    set rname  $tname
    set islist 0
    if {[string match "@*" $tname]} {
      set islist 1
      set rname [string range $tname 1 end]
    }

    set dname [file dirname $rname]
    set fname [file tail    $rname]
    if {$dname ne "."} {
      set tbase [file join $tbase $dname]
    }

    if {![file readable "$tbase/$fname"]} {
      puts "-E: file $tbase/$fname not found or readable"
      error "-E: file $tbase/$fname not found or readable"
    }

    if {$islist} {
      set fh [open "$tbase/$fname"]
      while {[gets $fh line] >= 0} {
        set line [string trim $line];       # trim white space 
        if {$line eq ""} {continue};        # skip empty lines
        if {[string match "#*" $line]} {
          if {[string match "##*" $line]} { rlc log -bare $line }
        } elseif {[string match "@*" $line]} {
          incr errcnt [tcodes_list $line $tbase]
        } else {
          incr errcnt [tcodes_exec $line $tbase]
        }
      }
      close $fh

    } else {
      incr errcnt [tcodes_exec $fname $tbase]
    }

    if {$islist} {
      rlc log -bare [format "%s: %s" $tname [rutil::errcnt2txt $errcnt]]
    }
    return $errcnt
  }

  #
  # tcodes_exec: execute single tcode
  #
  proc tcodes_exec {fname tbase} {
    if {![file readable "$tbase/$fname"]} {
      error "-E: file $tbase/$fname not found or readable"
    }

    set cpu "cpu0"
    set errcnt 0
    set tout 100.;              # tcode timeout
    set hascmon [$cpu get hascmon]
    set mwsup 1;                # dmcmon
    set imode 1;                # dmcmon
    set nent 30;                # dmcmon: show last 30 instructions

    if { [catch {$cpu ldasm -file "$tbase/$fname" -sym sym -lst lst} errmsg] } {
      rlc log -error "$fname FAILed to compile"
      rlc log -bare $errmsg
      rlc log -bare [format "%s: %s" $fname "FAIL"]
      return 1
    }

    if {$hascmon} {rw11::cm_start $cpu mwsup $mwsup imode $imode}
    rw11::asmrun  $cpu sym
    
    set dt [$cpu wtcpu -reset $tout]
    if {$hascmon} {rw11::cm_stop}
    
    if {$dt < 0.} {
      rlc log -error "$fname FAILed with timeout after $tout s"
      incr errcnt 1
    } else {
      $cpu cp -rpc rpc
      if {$rpc != $sym(stop)} {
        rlc log -error [format "%s FAILed with HALT at %06o" $fname $rpc]
        incr errcnt 1
      }
    }

    if {$errcnt > 0} {                  # in case of an error
      rlc log -bare [$cpu show -r0ps];  # show registers 
      if {$hascmon} {                   # show last instructions if cmon present
        set cmraw [rw11::cm_read $cpu $nent]
        rlc log -bare [rw11::cm_print $cmraw]
      }
    }
 
    rlc log -bare [format "%s: %s" $fname [rutil::errcnt2txt $errcnt]]
    return $errcnt
  }

}
