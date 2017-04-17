# $Id: test_deuna_regs.tcl 874 2017-04-14 17:53:07Z mueller $
#
# Copyright 2017- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
# License disclaimer see License.txt in $RETROBASE directory
#
# Revision History:
# Date         Rev Version  Comment
# 2017-04-14   874   1.0    Initial version
# 2017-01-30   848   0.1    First draft
#
# Test register response 
#  A: register basics

# ----------------------------------------------------------------------------
rlc log "test_deuna_regs: test register response -----------------------------"
package require ibd_deuna
if {![ibd_deuna::setup]} {
  rlc log "  test_deuna_regs-W: device not found, test aborted"
  return
}

rlc set statmask  $rw11::STAT_DEFMASK
rlc set statvalue 0

# -- Section A ---------------------------------------------------------------
rlc log "  A1: test read ---------------------------------------------"
rlc log "    A1.1: loc read pr0,...,pr3 -------------------------"

$cpu cp -rma  xua.pr0 \
        -rma  xua.pr1 \
        -rma  xua.pr2 \
        -rma  xua.pr3

rlc log "    A1.2: rem read pr0,...,pr3 -------------------------"

$cpu cp -ribr xua.pr0 \
        -ribr xua.pr1 \
        -ribr xua.pr2 \
        -ribr xua.pr3

rlc log "  A2: test pr2+3 (pcbb) --------------------------------"
rlc log "    A2.1: loc write pcbb, read loc and rem -------------"

$cpu cp -wma  xua.pr2 0xffff \
        -wma  xua.pr3 0xffff \
        -rma  xua.pr2 -edata 0xfffe \
        -rma  xua.pr3 -edata 0x0003 \
        -ribr xua.pr2 -edata 0xfffe \
        -ribr xua.pr3 -edata 0x0003
$cpu cp -wma  xua.pr2 0x1234 \
        -wma  xua.pr3 0x0001 \
        -rma  xua.pr2 -edata 0x1234 \
        -rma  xua.pr3 -edata 0x0001 \
        -ribr xua.pr2 -edata 0x1234 \
        -ribr xua.pr3 -edata 0x0001

rlc log "  A3: test pr0 -----------------------------------------"
rlc log "    A3.1: loc clear or all interrupt bits --------------"

$cpu cp -wma xua.pr0 0xff00 \
        -rma xua.pr0 -edata 0

rlc log "    A3.2: rem set and loc clear of interrupt bits ------"

$cpu cp -wibr xua.pr0 [regbld ibd_deuna::PR0RW seri] \
        -rma  xua.pr0 -edata [regbld ibd_deuna::PR0 seri intr] \
        -wibr xua.pr0 [regbld ibd_deuna::PR0RW pcei] \
        -rma  xua.pr0 -edata [regbld ibd_deuna::PR0 seri pcei intr] \
        -wibr xua.pr0 [regbld ibd_deuna::PR0RW rxi] \
        -rma  xua.pr0 -edata [regbld ibd_deuna::PR0 seri pcei rxi intr] \
        -wibr xua.pr0 [regbld ibd_deuna::PR0RW txi] \
        -rma  xua.pr0 -edata [regbld ibd_deuna::PR0 seri pcei rxi txi intr]
$cpu cp -wma  xua.pr0 [regbld ibd_deuna::PR0 seri] \
        -rma  xua.pr0 -edata [regbld ibd_deuna::PR0 pcei rxi txi intr] \
        -wma  xua.pr0 [regbld ibd_deuna::PR0 pcei] \
        -rma  xua.pr0 -edata [regbld ibd_deuna::PR0 rxi txi intr] \
        -wma  xua.pr0 [regbld ibd_deuna::PR0 rxi] \
        -rma  xua.pr0 -edata [regbld ibd_deuna::PR0 txi intr] \
        -wma  xua.pr0 [regbld ibd_deuna::PR0 txi] \
        -rma  xua.pr0 -edata 0
$cpu cp -wibr xua.pr0 [regbld ibd_deuna::PR0RW dni] \
        -rma  xua.pr0 -edata [regbld ibd_deuna::PR0 dni intr] \
        -wibr xua.pr0 [regbld ibd_deuna::PR0RW rcbi] \
        -rma  xua.pr0 -edata [regbld ibd_deuna::PR0 dni rcbi intr] \
        -wibr xua.pr0 [regbld ibd_deuna::PR0RW usci] \
        -rma  xua.pr0 -edata [regbld ibd_deuna::PR0 dni rcbi usci intr]
$cpu cp -wma  xua.pr0 [regbld ibd_deuna::PR0 dni] \
        -rma  xua.pr0 -edata [regbld ibd_deuna::PR0 rcbi usci intr] \
        -wma  xua.pr0 [regbld ibd_deuna::PR0 rcbi] \
        -rma  xua.pr0 -edata [regbld ibd_deuna::PR0 usci intr] \
        -wma  xua.pr0 [regbld ibd_deuna::PR0 usci] \
        -rma  xua.pr0 -edata 0

rlc log "  A4: test pr1 -----------------------------------------"
rlc log "    A4.1: XPWR,ICAB,PCTO,DEUNA rem write, loc read -----"

$cpu cp -wibr xua.pr1 0 \
        -rma  xua.pr1 -edata 0 \
        -wibr xua.pr1 [regbld ibd_deuna::PR1 xpwr] \
        -rma  xua.pr1 -edata [regbld ibd_deuna::PR1 xpwr] \
        -wibr xua.pr1 [regbld ibd_deuna::PR1 icab] \
        -rma  xua.pr1 -edata [regbld ibd_deuna::PR1 icab] \
        -wibr xua.pr1 [regbld ibd_deuna::PR1 pcto] \
        -rma  xua.pr1 -edata [regbld ibd_deuna::PR1 pcto] \
        -wibr xua.pr1 [regbld ibd_deuna::PR1 deuna] \
        -rma  xua.pr1 -edata [regbld ibd_deuna::PR1 deuna]

rlc log "    A4.2: STATE rem write, loc read -----"

$cpu cp -wibr xua.pr1 [regbld ibd_deuna::PR1 {state 001}] \
        -rma  xua.pr1 -edata [regbld ibd_deuna::PR1 {state 001}] \
        -wibr xua.pr1 [regbld ibd_deuna::PR1 {state 017}] \
        -rma  xua.pr1 -edata [regbld ibd_deuna::PR1 {state 017}] \
        -wibr xua.pr1 0 \
        -rma  xua.pr1 -edata 0
