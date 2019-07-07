# $Id: shell_egd.tcl 1177 2019-06-30 12:34:07Z mueller $
# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright 2015-2019 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
#
#  Revision History:
# Date         Rev Version  Comment
# 2019-04-21  1134   1.1.2  shell_aspec_parse: allow 8,9 in numeric address
# 2017-06-09   910   1.1.1  BUGFIX: shell_pspec_map: fix mapping for addr>20000
# 2017-03-10   859   1.1    .egd: add /u option (memory access via ubmap)
# 2015-12-28   720   1.0    Initial version
# 2015-12-23   717   0.1    First draft
#

package provide rw11 1.0

package require rlink
package require rwxxtpp

namespace eval rw11 {

  variable shell_egd_lrdef  "l"
  variable shell_egd_amdef  "p"

  #
  # shell_exa: examine memory, return as text ('e' command in shell) ---------
  # 
  proc shell_exa {aspec} {
    set pspec [shell_aspec_parse $aspec]
    set mspec [shell_pspec_map   $pspec]
    set rval  [shell_mspec_get   $mspec]
    set rtxt  [shell_mspec_txt   $mspec $rval]
    return $rtxt
  }

  #
  # shell_get: examine memory, return as list ('g' command in shell) ---------
  # 
  proc shell_get {aspec} {
    set pspec [shell_aspec_parse $aspec]
    set mspec [shell_pspec_map   $pspec]
    set rval  [shell_mspec_get   $mspec]
    return $rval
  }

  #
  # shell_dep: deposit memory ('d' command in shell) -------------------------
  # 
  proc shell_dep {aspec args} {
    set pspec [shell_aspec_parse $aspec]
    set mspec [shell_pspec_map   $pspec]
    set rval  [shell_mspec_put   $mspec $args]
    return
  }

  #
  # shell_aspec_parse: -------------------------------------------------------
  # 
  proc shell_aspec_parse {aspec} {
    variable shell_egd_lrdef
    variable shell_egd_amdef

    set volist [split $aspec "/"]
    set saddr  [lindex $volist 0]
    set opts   [lreplace $volist 0 0]

    # parse options part
    set opt_lr   ""
    set opt_am   ""
    set opt_fmt  "o"
    set opt_cnt  1
    foreach opt $opts {
      switch -regexp -matchvar mvar -- $opt {
        {^[lr]$}        { set opt_lr  $opt }
        {^[cpksu][id]$} { set opt_am  $opt }
        {^[peu]$}       { set opt_am  $opt }
        {^[iabodxfF]$}  { set opt_fmt $opt }
        {^(\d)+$}       { set opt_cnt $opt }
        default         { error "-E: bad option: $opt"}
      }
    }

    # check of only options specified --> update default opts
    if {$saddr eq ""} {
      if {$opt_lr ne ""} {set shell_egd_lrdef $opt_lr}
      if {$opt_am ne ""} {set shell_egd_amdef $opt_am}
      return {}
    }

    # parse symbolic address part
    # use default loc/rem or address space
    if {$opt_lr eq ""} {set opt_lr $shell_egd_lrdef}
    if {$opt_am eq ""} {set opt_am $shell_egd_amdef}

    # Note: put regexp patterns in {} to prevent that tcl modifies them !
    switch -regexp -matchvar mvar -- $saddr {
      {^([0-9]+)$} { 
        set paddr [list "pa" $opt_am [lindex $mvar 1]]
        }
      {^(r0|r1|r2|r3|r4|r5|r6|r7|sp|pc|ps)$} { 
        set paddr [list "reg" "" [lindex $mvar 1]]
        }
      {^@(r0|r1|r2|r3|r4|r5|r6|r7|sp|pc)$} { 
        set paddr [list "ireg" $opt_am [lindex $mvar 1] 0]
        }
      {^\((r0|r1|r2|r3|r4|r5|r6|r7|sp|pc)\)$}  {
        set paddr [list "ireg" $opt_am [lindex $mvar 1] 0]
        }
      {^([0-9].*?)\((r0|r1|r2|r3|r4|r5|r6|r7|sp|pc)\)$}  { 
        set paddr [list "ireg" $opt_am [lindex $mvar 2] [lindex $mvar 1]]
        }
      {^(.+?)\+([0-9].*)$}  { 
        set paddr [list "name" $opt_lr [lindex $mvar 1] [lindex $mvar 2]]
        }
      default { 
        set paddr [list "name" $opt_lr $saddr 0]
        }
    }

    return [list $paddr $opt_cnt $opt_fmt]
  }

  #
  # shell_pspec_map: ---------------------------------------------------------
  # 
  proc shell_pspec_map {pspec} {
    variable shell_cpu
    set paddr [lindex $pspec 0]
    set cnt   [lindex $pspec 1]
    set fmt   [lindex $pspec 2]
    set mode  [lindex $paddr 0]
    set am    [lindex $paddr 1]
    set addr  [lindex $paddr 2]
    set off   [lindex $paddr 3]

    if {$addr eq "sp"} {set addr "r6"}
    if {$addr eq "pc"} {set addr "r7"}

    switch $mode {
      reg { 
        if {$addr eq "ps"} {
          if {$cnt > 1} { error "-E: for 'ps' only range count of 1 allowed" }
        } else {
          set rnum [string range $addr 1 1]
          if {[expr {$rnum + $cnt}] > 8} { error "-E: range extends beyond r7" }
        }
        return [list "reg" "" $addr $cnt $fmt ]
      }

      pa   -
      ireg {
        if {$mode eq "ireg"} {
          $shell_cpu cp -r$addr rval
          set addr [expr {$rval + $off}]
        }
        set am0 [string range $am 0 0]
        set am1 [string range $am 1 1]
        if {$am1 ne ""} {
          if {$am0 eq "c" || $am0 eq "p"} {
            $shell_cpu cp -rps rval
            if {$am0 eq "c"} {
              set xmode [regget rw11::PSW(cmode) $rval]
            } else {
              set xmode [regget rw11::PSW(pmode) $rval]
            }
            set am0 [string range "ksxu" $xmode $xmode]
          }
          set segnum [expr {$addr>>13}]
          set sarname "sar${am0}${am1}.${segnum}"
          $shell_cpu cp -rreg $sarname sarval
          set addr [expr {($addr & 017777) + 64 * $sarval}]
          set am "e"
        }
        return [list "mem" $am $addr $cnt $fmt ]
      }

      name {
        set addr [$shell_cpu imap $addr]
        set addr [expr {$addr + $off}]
        for {set i 0} {$i < $cnt} {incr i} {
          set taddr [expr {$addr + 2*$i}]
          if {![$shell_cpu imap -testaddr $taddr]} {
            error "-E: address [format %06o $taddr] not mapped in imap"
          }
        }
        return [list "iop" $am $addr $cnt $fmt ]
      }
    }

    error "-E: BUGCHECK: bad mode $mode"

  }

  #
  # shell_mspec_get: ---------------------------------------------------------
  # 
  proc shell_mspec_get {mspec} {
    variable shell_cpu
    set mode  [lindex $mspec 0]; # reg,mem,iop
    set am    [lindex $mspec 1]; # l,r or p,e,u,[cpksu][id]
    set addr  [lindex $mspec 2]
    set cnt   [lindex $mspec 3]
    set fmt   [lindex $mspec 4]; # i,a,b,o,d,x,f,F
    
    switch $mode {
      mem {
        set clist {}
        switch $am {
          p  {lappend clist -wal $addr}
          u  {lappend clist -wa  $addr -ubm}
          e  {lappend clist -wa  $addr -p22}
          default {error "-E: BUGCHECK: expected am of p,u, or e"}
        }
        lappend clist -brm $cnt rval
        $shell_cpu cp {*}$clist
        return $rval
      }

      reg {
        set clist {}
        if {$addr eq "ps"} {
          lappend clist -rps  cpval0
        } else {
          set rbase [string range $addr 1 1]
          for {set i 0} {$i < $cnt} {incr i} {
            set rnum [expr {$rbase + $i}]
            lappend clist -rr${rnum}  cpval${i}
          }
        }
        $shell_cpu cp {*}$clist
      }

      iop {
        set clist {}
        if {$am eq "l"} {       # loc access
          lappend clist -wal $addr
          for {set i 0} {$i < $cnt} {incr i} {
            lappend clist -rmi cpval[format %02d $i]
            incr addr 2
          }
        } else {                # rem access
          for {set i 0} {$i < $cnt} {incr i} {
            lappend clist -ribr $addr cpval[format %02d $i]
            incr addr 2
          }
        }
        $shell_cpu cp {*}$clist
      }

      default { error "-E: BUGCHECK: bad mode $mode" }
    }

    set rval {}
    foreach var [lsort -dictionary [info locals cpval*]] {
      lappend rval [set $var]
    }

    return $rval
  }

  #
  # shell_mspec_txt: ---------------------------------------------------------
  # 
  proc shell_mspec_txt {mspec rval} {
    variable shell_cpu
    set mode  [lindex $mspec 0]
    set am    [lindex $mspec 1]
    set addr  [lindex $mspec 2]
    set cnt   [lindex $mspec 3]
    set fmt   [lindex $mspec 4]

    set rtxt {}
    set ind 0

    switch $mode {
      mem {
        while {$ind < $cnt} {
          set line [format "%08o:" [expr {$addr + 2*$ind}]]
          switch $fmt {
            b {
              for {set i 0} {$i <  4 && $ind < $cnt} {incr i; incr ind} {
                append line " "
                append line [pbvi b16 [lindex $rval $ind]]
              }
            }

            o {
              for {set i 0} {$i <  8 && $ind < $cnt} {incr i; incr ind} {
                append line [format " %06o" [lindex $rval $ind]]
              }
            }

            d {
              for {set i 0} {$i <  8 && $ind < $cnt} {incr i; incr ind} {
                append line [format " %6d" [lindex $rval $ind]]
              }
            }

            x {
              for {set i 0} {$i < 12 && $ind < $cnt} {incr i; incr ind} {
                append line [format " %04x" [lindex $rval $ind]]
              }
            }

            a {
              set blist {}
              for {set i 0} {$i <  4 && $ind < $cnt} {incr i; incr ind} {
                set val  [lindex $rval $ind]
                lappend blist [expr { $val     & 0xff}]
                lappend blist [expr {($val>>8) & 0xff}]
              }
              set linebyt ""
              set lineasc ""
              foreach byt $blist {
                append linebyt [format " %03o" $byt]
                set pmark " "
                if {$byt >= 128} {
                  set pmark "!"
                  set byt [expr {$byt & 0177}]
                }
                if {$byt < 32} {
                  append lineasc " $pmark"
                  append lineasc [lindex {{\0} "^a" "^b" "^c"
                                          "^d" "^e" "^f" "^g"
                                          "BS" "^i" "LF" "VT"
                                          "FF" "CR" "^n" "^o"
                                          "^p" "^q" "^r" "^s"
                                          "^t" "^u" "^v" "^w"
                                          "^x" "^y" "^z" "ES"
                                          "FS" "GS" "RS" "US" } $byt]
                } elseif {$byt >= 32 && $byt < 127} {
                  append lineasc [format "  %s%c" $pmark $byt]
                } else {
                  append  lineasc " ${pmark}DE"
                }
              }
              while {[string length $linebyt] < 32} { append linebyt "    "}
              append line $linebyt
              append line " : "
              append line $lineasc
            }

            i {
              set inst   [lrange $rval $ind [expr {$ind + 2}]]
              set dsc    [rw11::dasm_inst2txt $inst]
              set txt    [lindex $dsc 0]
              set nwrd   [lindex $dsc 1]
              for {set i 0} {$i < 3} {incr i} {
                if {$i < $nwrd} {
                  append line [format " %06o" [lindex $rval $ind]]
                  incr ind
                } else {
                  append line "       "
                }
              }
              append line " : $txt"
            }

            default { error "-E: not yet implemented format option /$fmt" }

          }
          if {$rtxt ne ""} {append rtxt "\n"}
          append rtxt $line
        }
      }

      reg {
        for {set i 0} {$i < $cnt} {incr i} {
          set cval [shell_conv_bodx $fmt [lindex $rval $i]]
          set rnam $addr
          if {$i > 0} { set rnam "r[expr {[string range $addr 1 1] + $i}]" }
          if {$rtxt ne ""} {append rtxt "\n"}
          append rtxt "$rnam : $cval"
        }
      }

      iop {
        for {set i 0} {$i < $cnt} {incr i; incr addr 2} {
          set  val [lindex $rval $i]
          set cval [shell_conv_bodx $fmt $val]
          set name [$shell_cpu imap -name $addr]
          set line [format "%06o %-8s : %s" $addr $name $cval]
          if {[$shell_cpu imap -testaddr $addr]} {
            set cnam [$shell_cpu imap -name $addr]
            set ctxt [rw11util::regmap_txt $cnam "${am}r" $val]
            if {$ctxt ne ""} {append line "  $ctxt"}
          }
          if {$rtxt ne ""} {append rtxt "\n"}
          append rtxt $line
        }
        
      }
    }

    return $rtxt
  }

  #
  # shell_mspec_put: ---------------------------------------------------------
  # 
  proc shell_mspec_put {mspec valr} {
    variable shell_cpu
    set mode  [lindex $mspec 0]
    set am    [lindex $mspec 1]
    set addr  [lindex $mspec 2]
    set cnt   [lindex $mspec 3]
    set fmt   [lindex $mspec 4]

    # handle conversions 
    #   - regdsc values (as list in {k v ...} or {dsc k v ...} format)
    #   - 0bnnnn values

    set vals {}
    foreach val $valr {
      if {[llength $val] > 1} {
        set rdsc ""
        if {$mode eq "iop"} {
          set ioaddr [expr {$addr + 2 * [llength $vals]}]
          if {[$shell_cpu imap -testaddr $ioaddr]} {
            set ioname [$shell_cpu imap -name $ioaddr]
            set rdsc [rw11util::regmap_get $ioname "${am}w"]
          }
        }
        if {[llength $val] & 01} {
          set rdsc [lindex $val 0]
          set val  [lreplace $val 0 0]
        }
        if {$rdsc ne "" && [info exists $rdsc]} {
          set val [regbldkv $rdsc {*}$val]
        } else {
          error "-E: missing or invalid register desciptor '$rdsc'"
        }
        
      } else {
        if {[string match "0b*" $val]} {
          set val [bvi b16 [string range $val 2 end]]
        }
      }
      lappend vals $val
    }

    set nvals [llength $vals]
    if {$nvals != $cnt} { 
      error "-E: expected $cnt write values, seen $nvals"
    }

    switch $mode {
      mem {
        set clist {}
        switch $am {
          p  {lappend clist -wal $addr}
          u  {lappend clist -wa  $addr -ubm}
          e  {lappend clist -wa  $addr -p22}
          default {error "-E: BUGCHECK: expected am of p,u, or e"}
        }
        lappend clist -bwm $vals
        $shell_cpu cp {*}$clist
        return
      }

      reg {
        set clist {}
        if {$addr eq "ps"} {
          lappend clist -wps $vals
        } else {
          set rbase [string range $addr 1 1]
          for {set i 0} {$i < $cnt} {incr i} {
            set rnum [expr {$rbase + $i}]
            lappend clist -wr${rnum}  [lindex $vals $i]
          }
        }
        $shell_cpu cp {*}$clist
      }

      iop {
        set clist {}
        if {$am eq "l"} {       # loc access
          lappend clist -wal $addr
          for {set i 0} {$i < $cnt} {incr i} {
            lappend clist -wmi [lindex $vals $i]
            incr addr 2
          }
        } else {                # rem access
          for {set i 0} {$i < $cnt} {incr i} {
            lappend clist -wibr $addr [lindex $vals $i]
            incr addr 2
          }
        }
        $shell_cpu cp {*}$clist
      }

      default { error "-E: BUGCHECK: bad mode $mode" }
    }

    return

  }

  #
  # shell_conv_bodx: ---------------------------------------------------------
  # 
  proc shell_conv_bodx {fmt val} {
    switch $fmt {
      b       { return [pbvi b16      $val] }
      d       { return [format  "%6d" $val] }
      x       { return [format "%04x" $val] }
      default { return [format "%06o" $val] }
    }
  }

}
