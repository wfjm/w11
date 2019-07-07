# $Id: dasm.tcl 1177 2019-06-30 12:34:07Z mueller $
# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright 2015- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
#
#  Revision History:
# Date         Rev Version  Comment
# 2015-12-25   717   1.1    add dasm_inst2txt; add nriName arg in dasm_iline
# 2015-08-04   709   1.0    Initial version
# 2015-07-26   705   0.1    First draft
#

package provide rw11 1.0

package require rlink
package require rwxxtpp

namespace eval rw11 {

  #code    mask     name    type  acinf   bwf
  variable dasm_opdsc { \
  {0000000 0000000  halt    0arg  {}       - } \
  {0000001 0000000  wait    0arg  {}       - } \
  {0000002 0000000  rti     0arg  {po po}  w } \
  {0000003 0000000  bpt     0arg  {}       - } \
  {0000004 0000000  iot     0arg  {}       - } \
  {0000005 0000000  reset   0arg  {}       - } \
  {0000006 0000000  rtt     0arg  {po po}  w } \
  {0000007 0000000  !mfpt   0arg  {}       - } \
  {0000100 0000077  jmp     1arg  {da}     w } \
  {0000200 0000007  rts     1reg  {po}     w } \
  {0000230 0000007  spl     spl   {}       - } \
  {0000240 0000017  cl      ccop  {}       - } \
  {0000260 0000017  se      ccop  {}       - } \
  {0000300 0000077  swab    1arg  {dm}     w } \
  {0000400 0000377  br      br    {}       - } \
  {0001000 0000377  bne     br    {}       - } \
  {0001400 0000377  beq     br    {}       - } \
  {0002000 0000377  bge     br    {}       - } \
  {0002400 0000377  blt     br    {}       - } \
  {0003000 0000377  bgt     br    {}       - } \
  {0003400 0000377  ble     br    {}       - } \
  {0004000 0000777  jsr     rsrc  {da pu}  w } \
  {0005000 0000077  clr     1arg  {dw}     w } \
  {0005100 0000077  com     1arg  {dm}     w } \
  {0005200 0000077  inc     1arg  {dm}     w } \
  {0005300 0000077  dec     1arg  {dm}     w } \
  {0005400 0000077  neg     1arg  {dm}     w } \
  {0005500 0000077  adc     1arg  {dm}     w } \
  {0005600 0000077  sbc     1arg  {dm}     w } \
  {0005700 0000077  tst     1arg  {dr}     w } \
  {0006000 0000077  ror     1arg  {dm}     w } \
  {0006100 0000077  rol     1arg  {dm}     w } \
  {0006200 0000077  asr     1arg  {dm}     w } \
  {0006300 0000077  asl     1arg  {dm}     w } \
  {0006400 0000077  mark    mark  {po}     w } \
  {0006500 0000077  mfpi    1arg  {dr pu}  w } \
  {0006600 0000077  mtpi    1arg  {po dw}  w } \
  {0006700 0000077  sxt     1arg  {dw}     w } \
  {0007000 0000077  !csm    1arg  {dr pu pu pu} - } \
  {0007200 0000077  !tstset 1arg  {dm}     - } \
  {0007300 0000077  !wrtlck 1arg  {dw}     w } \
  {0010000 0007777  mov     2arg  {sr dw}  w } \
  {0020000 0007777  cmp     2arg  {sr dr}  w } \
  {0030000 0007777  bit     2arg  {sr dr}  w } \
  {0040000 0007777  bic     2arg  {sr dm}  w } \
  {0050000 0007777  bis     2arg  {sr dm}  w } \
  {0060000 0007777  add     2arg  {sr dm}  w } \
  {0070000 0000777  mul     rdst  {dr}     w } \
  {0071000 0000777  div     rdst  {dr}     w } \
  {0072000 0000777  ash     rdst  {dr}     w } \
  {0073000 0000777  ashc    rdst  {dr}     w } \
  {0074000 0000777  xor     rsrc  {dm}     w } \
  {0077000 0000777  sob     sob   {}       - } \
  {0100000 0000377  bpl     br    {}       - } \
  {0100400 0000377  bmi     br    {}       - } \
  {0101000 0000377  bhi     br    {}       - } \
  {0101400 0000377  blos    br    {}       - } \
  {0102000 0000377  bvc     br    {}       - } \
  {0102400 0000377  bvs     br    {}       - } \
  {0103000 0000377  bcc     br    {}       - } \
  {0103400 0000377  bcs     br    {}       - } \
  {0104000 0000377  emt     trap  {}       - } \
  {0104400 0000377  trap    trap  {}       - } \
  {0105000 0000077  clrb    1arg  {dw}     b } \
  {0105100 0000077  comb    1arg  {dm}     b } \
  {0105200 0000077  incb    1arg  {dm}     b } \
  {0105300 0000077  decb    1arg  {dm}     b } \
  {0105400 0000077  negb    1arg  {dm}     b } \
  {0105500 0000077  adcb    1arg  {dm}     b } \
  {0105600 0000077  sbcb    1arg  {dm}     b } \
  {0105700 0000077  tstb    1arg  {dr}     b } \
  {0106000 0000077  rorb    1arg  {dm}     b } \
  {0106100 0000077  rolb    1arg  {dm}     b } \
  {0106200 0000077  asrb    1arg  {dm}     b } \
  {0106300 0000077  aslb    1arg  {dm}     b } \
  {0106400 0000077  !mtps   1arg  {}       - } \
  {0106500 0000077  mfpd    1arg  {dr pu}  w } \
  {0106600 0000077  mtpd    1arg  {po dw}  w } \
  {0106700 0000077  !mfps   1arg  {}       - } \
  {0110000 0007777  movb    2arg  {sr dw}  b } \
  {0120000 0007777  cmpb    2arg  {sr dr}  b } \
  {0130000 0007777  bitb    2arg  {sr dr}  b } \
  {0140000 0007777  bicb    2arg  {sr dm}  b } \
  {0150000 0007777  bisb    2arg  {sr dm}  b } \
  {0160000 0007777  sub     2arg  {sr dm}  b } \
  {0170000 0000000  !cfcc   0arg  {}       - } \
  {0170001 0000000  !setf   0arg  {}       - } \
  {0170011 0000000  !setd   0arg  {}       - } \
  {0170002 0000000  !seti   0arg  {}       - } \
  {0170012 0000000  !setl   0arg  {}       - } \
  {0170100 0000077  !ldfps  1fpp  {dr}     w } \
  {0170200 0000077  !stfps  1fpp  {dw}     w } \
  {0170300 0000077  !stst   1fpp  {dw}     w } \
  {0170400 0000077  !clrf   1fpp  {dw}     f } \
  {0170500 0000077  !tstf   1fpp  {dr}     f } \
  {0170600 0000077  !absf   1fpp  {dm}     f } \
  {0170700 0000077  !negf   1fpp  {dm}     f } \
  {0171000 0000377  !mulf   rfpp  {dr}     f } \
  {0171400 0000377  !modf   rfpp  {dr}     f } \
  {0172000 0000377  !addf   rfpp  {dr}     f } \
  {0172400 0000377  !ldf    rfpp  {dr}     f } \
  {0173000 0000377  !subf   rfpp  {dr}     f } \
  {0173400 0000377  !cmpf   rfpp  {dr}     f } \
  {0174000 0000377  !stf    rfpp  {dw}     f } \
  {0174400 0000377  !divf   rfpp  {dr}     f } \
  {0175000 0000377  !stexp  rfpp  {dw}     w } \
  {0175400 0000377  !stcif  rfpp  {dw}     f } \
  {0176000 0000377  !stcfd  rfpp  {dw}     f } \
  {0176400 0000377  !ldexp  rfpp  {dr}     w } \
  {0177000 0000377  !ldcif  rfpp  {dr}     f } \
  {0177400 0000377  !ldcdf  rfpp  {dr}     f } \
  }

  # vector  name
  variable dasm_vecmap
  array set dasm_vecmap { \
    004  iit   \
    010  rit   \
    014  bpt   \
    020  iot   \
    024  pwr   \
    030  emt   \
    034  trp   \
    060  dla-r \
    064  dla-t \
    070  pc-r  \
    074  pc-p  \
    100  kw-l  \
    104  kw-p  \
    114  mse   \
    120  deuna \
    160  rla   \
    200  lpa   \
    220  rka   \
    224  tma   \
    240  pir   \
    244  fpp   \
    250  mmu   \
    254  rpa   \
    260  iist  \
    300  dlb-r \
    304  dlb-t \
    310  dza-r \
    314  dza-t \
  }

  # a
  variable dasm_ackeymap
  array set dasm_ackeymap { \
    sr:00   {}            \
    sr:10   {rd}          \
    sr:20   {rd}          \
    sr:30   {ra rd}       \
    sr:40   {rd}          \
    sr:50   {ra rd}       \
    sr:60   {ri rd}       \
    sr:70   {ri ra rd}    \
    sr:07   {}            \
    sr:17   {rd}          \
    sr:27   {ri}          \
    sr:37   {ri rd}       \
    sr:47   {rd}          \
    sr:57   {ra rd}       \
    sr:67   {ri rd}       \
    sr:77   {ri ra rd}    \
    dr:00   {}            \
    dr:10   {rd}          \
    dr:20   {rd}          \
    dr:30   {ra rd}       \
    dr:40   {rd}          \
    dr:50   {ra rd}       \
    dr:60   {ri rd}       \
    dr:70   {ri ra rd}    \
    dr:07   {}            \
    dr:17   {rd}          \
    dr:27   {ri}          \
    dr:37   {ri rd}       \
    dr:47   {rd}          \
    dr:57   {ra rd}       \
    dr:67   {ri rd}       \
    dr:77   {ri ra rd}    \
    dw:00   {}            \
    dw:10   {wd}          \
    dw:20   {wd}          \
    dw:30   {ra wd}       \
    dw:40   {wd}          \
    dw:50   {ra wd}       \
    dw:60   {ri wd}       \
    dw:70   {ri ra wd}    \
    dw:07   {}            \
    dw:17   {wd}          \
    dw:27   {wd}          \
    dw:37   {ri wd}       \
    dw:47   {wd}          \
    dw:57   {ra wd}       \
    dw:67   {ri wd}       \
    dw:77   {ri ra wd}    \
    dm:00   {}            \
    dm:10   {rd md}       \
    dm:20   {rd md}       \
    dm:30   {ra rd md}    \
    dm:40   {rd md}       \
    dm:50   {ra rd md}    \
    dm:60   {ri rd md}    \
    dm:70   {ri ra rd md} \
    dm:07   {}            \
    dm:17   {rd md}       \
    dm:27   {rd md}       \
    dm:37   {ri rd md}    \
    dm:47   {rd md}       \
    dm:57   {ra rd md}    \
    dm:67   {ri rd md}    \
    dm:77   {ri ra rd md} \
    da:00   {}            \
    da:10   {}            \
    da:20   {}            \
    da:30   {rd}          \
    da:40   {}            \
    da:50   {rd}          \
    da:60   {ri}          \
    da:70   {ri rd}       \
    da:07   {}            \
    da:17   {}            \
    da:27   {}            \
    da:37   {ri}          \
    da:47   {}            \
    da:57   {rd}          \
    da:67   {ri}          \
    da:77   {ri rd}       \
  }

  #
  # dasm_ireg2txt: convert ireg to text
  # 
  proc dasm_ireg2txt {ireg} {
    set dsc [dasm_getdsc $ireg]
    if {[llength $dsc] != 0} {
      return [dasm_iline $ireg $dsc]
    }
    return "?[format %6.6o $ireg]?"
  }

  #
  # dasm_inst2txt: convert instruction to {text nwrd}
  # 
  proc dasm_inst2txt {inst} {
    set ireg   [lindex   $inst 0]
    set rilist [lreplace $inst 0 0]
    set dsc [dasm_getdsc $ireg]
    if {[llength $dsc] == 0} {
      return [list "?[format %6.6o $ireg]?" 1]
    }
    set txt  [dasm_iline $ireg $dsc $rilist nri]
    set nwrd [expr {$nri + 1}]
    return [list $txt $nwrd]
  }

  #
  # dasm_vec2txt: convert vector to text
  # 
  proc dasm_vec2txt {vec} {
    variable dasm_vecmap
    set vkey [format %3.3o $vec]
    if {[info exists dasm_vecmap($vkey)]} {return $dasm_vecmap($vkey)}
    return
  }

  #
  # dasm_getdsc: get opdsc matching an opcode
  # 
  proc dasm_getdsc {ireg} {
    variable dasm_opdsc
    set ndsc [llength $dasm_opdsc]
    set ibeg 0
    set iend [expr {$ndsc - 1} ]
    while {$ibeg >= 0 && $iend < $ndsc && $iend >= $ibeg} {
      set icur [expr {( $ibeg + $iend ) / 2}]
      set cdsc  [lindex $dasm_opdsc $icur]
      set ccode [lindex $cdsc 0]
      set cmask [lindex $cdsc 1]
      set iregm [expr { $ireg & [rutil::com16 $cmask] } ]
      if {$iregm == $ccode} {return $cdsc}
      if {$iregm <  $ccode} {
        set iend [expr {$icur - 1}]
      } else {
        set ibeg [expr {$icur + 1}]
      }
    }
    return {}
  }

  #
  # dasm_iline: convert 1-3 words; return text and word count
  # 
  proc dasm_iline {ireg idsc {rilist {}} {nriName {}} } {
    set icode  [lindex $idsc 0]
    set imask  [lindex $idsc 1]
    set imnemo [lindex $idsc 2]
    set itype  [lindex $idsc 3]

    set src    [expr {( $ireg >> 6 ) & 077}]; # source address spec
    set dst    [expr {  $ireg        & 077}]; # dest   address spec
    set reg6   [expr {( $ireg >> 6 ) &  07}]; # register from 8:6
    set reg0   [expr {  $ireg        &  07}]; # register from 2:0

    # Note on br and sob: offsets are expressed as ". +- nnn"
    #   where . represents the pc of instruction (as in assembler)
    #   the instruction itself holds the offset to the pc after fetch !!
    switch $itype {
      0arg     { set rval "$imnemo" }
      1arg     { set rval "$imnemo [dasm_regmod $dst]"}
      2arg     { set rval "$imnemo [dasm_regmod $src],[dasm_regmod $dst]"}
      rsrc     { set rval "$imnemo [dasm_regnam $reg6],[dasm_regmod $dst]"}
      rdst     { set rval "$imnemo [dasm_regmod $dst],[dasm_regnam $reg6]"}
      1reg     { set rval "$imnemo [dasm_regnam $reg0]"}
      br       { if {$ireg & 0200} {
                   set sign "-"
                   set off [expr {((~$ireg) & 0177) + 1}]
                   set off [expr {($off - 1) * 2}]
                 } else {
                   set sign "+"
                   set off [expr {$ireg & 0177}]
                   set off [expr {($off + 1) * 2}]
                 }
                 set rval "$imnemo .${sign}${off}"
               }
      sob      { set off [expr {$ireg & 0077}]
                 set off [expr {($off - 1) * 2}]
                 set rval "$imnemo [dasm_regnam $reg6],.-${off}"
               }
      trap     { set off [expr {$ireg & 0377}]
                 set rval "$imnemo [format %3.3o $off]"
               }
      spl      { set off [expr {$ireg & 0007}]
                 set rval "$imnemo $off "
               }
      ccop     { set off [expr {$ireg & 0017}]
                 set del ""
                 set str ""
                 if {$ireg & 010} { append str "${del}${imnemo}n"; set del "+"}
                 if {$ireg & 004} { append str "${del}${imnemo}z"; set del "+"}
                 if {$ireg & 002} { append str "${del}${imnemo}v"; set del "+"}
                 if {$ireg & 001} { append str "${del}${imnemo}c"; set del "+"}
                 set rval $str
                 if {$off  ==    0} {set rval "nop"}
                 if {$ireg == 0257} {set rval "ccc"}
                 if {$ireg == 0277} {set rval "scc"}
               }
      mark     { set off [expr {$ireg & 0077}]
                 set rval "$imnemo [format %3.3o $off]"
               }
      1fpp     { set rval "$imnemo [dasm_regmod $dst f]"}
      rfpp     { set regf [expr {( $ireg >> 6 ) &  03}]; # register from 8:6
                 set rval "$imnemo f${regf},[dasm_regmod $dst f]"
               }
      default  { return "??itype" }
    }

    set nval 0
    while {1} {
      set i [string first X $rval]
      if {$i < 0} {break}
      if {[llength $rilist] == 0} {
        set rval [string replace $rval $i $i "n"]
      } else {
        incr nval
        set rval [string replace $rval $i $i [format %6.6o [lindex $rilist 0]]]
        set rilist [lreplace $rilist 0 0]
      }
    }

    if {$nriName ne ""} {
      upvar 1 $nriName nri
      set nri $nval
    }

    return $rval
  }

  #
  # dasm_regmod: return access mode info
  # 
  proc dasm_regmod {regmod {pref r} } {
    set mod [expr {( $regmod >> 3 ) & 07}]
    set reg [expr {  $regmod        & 07}]
    set rstr [dasm_regnam $reg]
    if {$mod == 0 && $pref == "f" && $reg <= 5} {set rstr "f$reg"}
    switch $mod {
      0  { if {$pref == "f" && $reg <= 5} {return "f$reg"}
           return "$rstr"
          }
      1  { return "($rstr)"}
      2  { if {$reg!=7} {return "($rstr)+"}  else {return "#X"}  }
      3  { if {$reg!=7} {return "@($rstr)+"} else {return "@#X"} }
      4  {return "-($rstr)"}
      5  {return "@-($rstr)"}
      6  {return "X($rstr)"}
      7  {return "@X($rstr)"}
    }
    return "??regmod"
  }

  #
  # dasm_regnam: return register name
  # 
  proc dasm_regnam {reg} {
    set rstr "r${reg}"
    if {$reg == 6} {set rstr "sp"}
    if {$reg == 7} {set rstr "pc"}
    return $rstr
  }

  #
  # dasm_acmod2aclist
  # 
  proc dasm_acmod2aclist {acmod regmod} {
    variable dasm_ackeymap
    set mod [expr {( $regmod >> 3 ) & 07}]
    set reg [expr {  $regmod        & 07}]
    if {$reg != 7} {set reg 0}
    set ackey [format "%s:%o%o" $acmod $mod $reg]
    if {[info exists dasm_ackeymap($ackey)]} {
      return $dasm_ackeymap($ackey)
    }
    return "??"
  }

}
