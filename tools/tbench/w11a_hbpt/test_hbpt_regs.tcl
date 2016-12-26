# $Id: test_hbpt_regs.tcl 830 2016-12-26 20:25:49Z mueller $
#
# Copyright 2015- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
# License disclaimer see License.txt in $RETROBASE directory
#
# Revision History:
# Date         Rev Version  Comment
# 2015-07-11   700   1.0    Initial version
#
# Test register response 

# ----------------------------------------------------------------------------
rlc log "test_hbpt_regs: test register response ------------------------------"

set nbpt [$cpu get hashbpt]
if {$nbpt == 0} {
  rlc log "  test_hbpt_regs-W: no hbpt units found, test aborted"
  return
}

# -- Section A ---------------------------------------------------------------
rlc log "  A1: test cntl,stat for unit 0 -----------------------------"

foreach {cntl stat} [list \
      [regbld rw11::HB_CNTL {mode 1} {irena 0} {dwena 0} {drena 1}] \
      [regbld rw11::HB_STAT {irseen 1} {dwseen 0} {drseen 0}] \
      [regbld rw11::HB_CNTL {mode 2} {irena 0} {dwena 1} {drena 1}] \
      [regbld rw11::HB_STAT {irseen 1} {dwseen 1} {drseen 0}] \
      [regbld rw11::HB_CNTL {mode 3} {irena 1} {dwena 1} {drena 1}] \
      [regbld rw11::HB_STAT {irseen 1} {dwseen 1} {drseen 1}] \
      [regbld rw11::HB_CNTL {mode 0} {irena 0} {dwena 0} {drena 0}] \
      [regbld rw11::HB_STAT {irseen 0} {dwseen 0} {drseen 0}]  \
    ] {
  $cpu cp -wreg "hb0.cntl" $cntl \
          -wreg "hb0.stat" $stat \
          -rreg "hb0.cntl" -edata $cntl \
          -rreg "hb0.stat" -edata $stat 
}

rlc log "  A2: test hilim,lolim for unit 0 ---------------------------"
foreach {hilim lolim} {0177777 0100000 \
                       0100000 0177777 \
                       0000000 0000000 }  {
  $cpu cp -wreg "hb0.hilim" $hilim \
          -wreg "hb0.lolim" $lolim \
          -rreg "hb0.hilim" -edata [expr {$hilim & 0177776}] \
          -rreg "hb0.lolim" -edata [expr {$lolim & 0177776}]
}

rlc log "  A3: test cntl,stat,hi,lolim for all $nbpt units ---------------"

set cntl  {}
set stat  {}
set hilim {}
set lolim {}

for {set i 0} {$i<$nbpt} {incr i} {
  lappend cntl  [expr {$i + 1} ]
  lappend stat  [expr {$i + 1} ]
  lappend hilim [expr {2 * ($i+1) * 1234} ]
  lappend lolim [expr {2 * ($i+1) * 2345} ]
}

for {set i 0} {$i<$nbpt} {incr i} {
  $cpu cp -wreg "hb${i}.cntl"  [lindex $cntl  $i] \
          -wreg "hb${i}.stat"  [lindex $stat  $i] \
          -wreg "hb${i}.hilim" [lindex $hilim $i] \
          -wreg "hb${i}.lolim" [lindex $lolim $i]
}
for {set i 0} {$i<$nbpt} {incr i} {
  $cpu cp -rreg "hb${i}.cntl"  -edata [lindex $cntl  $i] \
          -rreg "hb${i}.stat"  -edata [lindex $stat  $i] \
          -rreg "hb${i}.hilim" -edata [lindex $hilim $i] \
          -rreg "hb${i}.lolim" -edata [lindex $lolim $i]
}
