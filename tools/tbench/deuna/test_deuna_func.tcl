# $Id: test_deuna_func.tcl 874 2017-04-14 17:53:07Z mueller $
#
# Copyright 2017- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
# License disclaimer see License.txt in $RETROBASE directory
#
# Revision History:
# Date         Rev Version  Comment
# 2017-04-14   874   1.0    Initial version
# 2017-01-30   848   0.1    First draft
#
# Test function response 

# ----------------------------------------------------------------------------
rlc log "test_deuna_func: test function response -----------------------------"
package require ibd_deuna
if {![ibd_deuna::setup]} {
  rlc log "  test_deuna_regs-W: device not found, test aborted"
  return
}

rlc set statmask  $rw11::STAT_DEFMASK
rlc set statvalue 0

# discard pending attn to be on save side
rlc wtlam 0.
rlc exec -attn

set attnmsk [expr {1<<$ibd_deuna::ANUM}]

# -- Section A ---------------------------------------------------------------
rlc log "  A1: test PR0:PCMD -----------------------------------------"
rlc log "    A1.1: set PR1 state to READY -----------------------"
$cpu cp -wibr xua.pr1 [regbld ibd_deuna::PR1 {state "READY"}]

rlc log "    A1.2: check NOOP doesn't LAM -----------------------"

# cleanup pr0 loc and rem
$cpu cp \
  -wma  xua.pr0 0xff00 \
  -rma  xua.pr0 -edata 0 \
  -wibr xua.pr0 [regbld ibd_deuna::PR0RW busy rset brst] \
  -ribr xua.pr0 -edata 0

rlc wtlam 0.
rlc exec -attn -edata 0

rlc log "    A1.3: check PCMD>0 gives LAM ----------------------"
#  0001:GETPCB; 0010:GETCMD; 1000:PDMD; 1111:STOP

foreach pcmd {0x01 0x02 0x08 0x0f} {
  set pr0 [regbldkv ibd_deuna::PR0 pcmd $pcmd]
  # loc write and read pr0; also check rem pr0
  $cpu cp \
    -wma  xua.pr0 $pcmd \
    -rma  xua.pr0 -edata $pcmd \
    -ribr xua.pr0 -edata [regbldkv ibd_deuna::PR0RR \
                            pcmdbp $pcmd busy 1 pcmd $pcmd]
    
  rlc wtlam 1.
  rlc exec -attn -edata $attnmsk

  # simulate command handling in backend and driver response
  #   rem: PR0  write dni
  #   loc: PR0  expect dni,intr
  #   loc: PR0  write dni (to clear), also set pcmd=0
  #   loc: PR0  expect dni cleared (in fact pr0 = 0)
  $cpu cp \
    -wibr xua.pr0 [regbld ibd_deuna::PR0RW dni] \
    -rma  xua.pr0 -edata [regbldkv ibd_deuna::PR0 dni 1 intr 1 pcmd $pcmd] \
    -wma  xua.pr0  [regbldkv ibd_deuna::PR0 dni 1] \
    -rma  xua.pr0 -edata 0
}

rlc log "    A1.4: check pcmd busy protect logic----------------"
# pr0 is clean from previous test !
$cpu cp \
  -wma  xua.pr0 [regbld ibd_deuna::PR0 {pcmd "GETCMD"}] \
  -rma  xua.pr0 -edata [regbld ibd_deuna::PR0 {pcmd "GETCMD"}] \
  -wma  xua.pr0 [regbld ibd_deuna::PR0 {pcmd "PDMD"}] \
  -rma  xua.pr0 -edata [regbld ibd_deuna::PR0 {pcmd "PDMD"}]

rlc wtlam 1.
rlc exec -attn -edata $attnmsk

# simulate command handling in backend
#   pcmd and pcmdbp differ now
#   pcwwb is cleared by rem pr0 read (check by reading twice)
$cpu cp \
  -ribr xua.pr0 -edata [regbldkv ibd_deuna::PR0RR \
                          pcmdbp "GETCMD" busy 1 pcwwb 1 pcmd "PDMD"] \
  -ribr xua.pr0 -edata [regbldkv ibd_deuna::PR0RR \
                          pcmdbp "GETCMD" busy 1 pcmd "PDMD"] \
  -wibr xua.pr0 [regbld ibd_deuna::PR0RW dni] \
  -rma  xua.pr0 -edata [regbldkv ibd_deuna::PR0 dni 1 intr 1 pcmd "PDMD"] \
  -wma  xua.pr0  [regbldkv ibd_deuna::PR0 dni 1] \
  -rma  xua.pr0 -edata 0

rlc log "  A2: test PR0:RSET -----------------------------------------"
# pr0 is clean from previous test !
$cpu cp \
  -wma  xua.pr0 [regbld ibd_deuna::PR0 rset] \
  -rma  xua.pr0 -edata 0 \
  -rma  xua.pr1 -edata [regbld ibd_deuna::PR1 {state "RESET"}]

rlc wtlam 1.
rlc exec -attn -edata $attnmsk

# simulate command handling in backend
$cpu cp \
  -ribr xua.pr0 -edata [regbld ibd_deuna::PR0RR busy rset] \
  -wibr xua.pr0  [regbld ibd_deuna::PR0RW rset] \
  -ribr xua.pr0 -edata 0

rlc log "  A3: test BRESET  ------------------------------------------"

# pr0 is clean from previous test !
# But PR1 state must be set to READY again
$cpu cp \
  -wibr xua.pr1 [regbld ibd_deuna::PR1 {state "READY"}] \
  -breset \
  -rma  xua.pr0 -edata 0 \
  -rma  xua.pr1 -edata [regbld ibd_deuna::PR1 {state "RESET"}]

rlc wtlam 1.
rlc exec -attn -edata $attnmsk

# simulate command handling in backend
$cpu cp \
  -ribr xua.pr0 -edata [regbld ibd_deuna::PR0RR busy brst] \
  -wibr xua.pr0  [regbld ibd_deuna::PR0RW brst] \
  -ribr xua.pr0 -edata 0
