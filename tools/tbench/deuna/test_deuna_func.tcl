# $Id: test_deuna_func.tcl 1119 2019-03-08 16:46:46Z mueller $
#
# Copyright 2017-2019 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
# License disclaimer see License.txt in $RETROBASE directory
#
# Revision History:
# Date         Rev Version  Comment
# 2017-05-06   894   1.0    Initial version (full functionality)
# 2017-04-14   874   0.5    Initial version (partial functionality)
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

rlc log "    A1.4: pcmd busy protect logic: 2nd not PDMD -------"
# pr0 is clean from previous test !
# issue 1st GETPCB and 2nd GETCMD
$cpu cp \
  -wma  xua.pr0 [regbld ibd_deuna::PR0 {pcmd "GETPCB"}] \
  -rma  xua.pr0 -edata [regbld ibd_deuna::PR0 {pcmd "GETPCB"}] \
  -wma  xua.pr0 [regbld ibd_deuna::PR0 {pcmd "GETCMD"}] \
  -rma  xua.pr0 -edata [regbld ibd_deuna::PR0 {pcmd "GETCMD"}]

rlc wtlam 1.
rlc exec -attn -edata $attnmsk

# simulate command handling in backend
#   pcmd and pcmdbp differ now
#   pcwwb is cleared by dni
$cpu cp \
  -ribr xua.pr0 -edata [regbldkv ibd_deuna::PR0RR \
                          pcmdbp "GETPCB" busy 1 pcwwb 1 pcmd "GETCMD"] \
  -wibr xua.pr0 [regbld ibd_deuna::PR0RW dni] \
  -rma  xua.pr0 -edata [regbldkv ibd_deuna::PR0 dni 1 intr 1 pcmd "GETCMD"] \
  -wma  xua.pr0  [regbldkv ibd_deuna::PR0 dni 1] \
  -rma  xua.pr0 -edata 0

rlc log "    A1.5: pcmd busy protect logic: restart with PDMD --"
# pr0 is clean from previous test !
# issue 1st GETCMD and 2nd PDMD
$cpu cp \
  -wma  xua.pr0 [regbld ibd_deuna::PR0 {pcmd "GETCMD"}] \
  -rma  xua.pr0 -edata [regbld ibd_deuna::PR0 {pcmd "GETCMD"}] \
  -wma  xua.pr0 [regbld ibd_deuna::PR0 {pcmd "PDMD"}] \
  -rma  xua.pr0 -edata [regbld ibd_deuna::PR0 {pcmd "PDMD"}]

rlc wtlam 1.
rlc exec -attn -edata $attnmsk

# simulate command handling in backend
#   pcmd and pcmdbp differ now
#   dni will clear pcwwb, restart with attn, and not set dni (thus intr=0)

$cpu cp \
  -ribr xua.pr0 -edata [regbldkv ibd_deuna::PR0RR \
                          pcmdbp "GETCMD" busy 1 pcwwb 1 pcmd "PDMD"] \
  -wibr xua.pr0 [regbld ibd_deuna::PR0RW dni] \
  -rma  xua.pr0 -edata [regbldkv ibd_deuna::PR0 dni 0 intr 0 pcmd "PDMD"]

# handle restarted pdmd
rlc wtlam 1.
rlc exec -attn -edata $attnmsk

# simulate command handling in backend
#   pcmd and pcmdbp equal now; pcwwb=0 now
#   dni will end transaction now

$cpu cp \
  -ribr xua.pr0 -edata [regbldkv ibd_deuna::PR0RR \
                          pcmdbp "PDMD" pdmdwb 1 busy 1 pcwwb 0 pcmd "PDMD"] \
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

# harvest breset/creset triggered attn's
rlc wtlam 0.
rlc exec -attn -edata 0
