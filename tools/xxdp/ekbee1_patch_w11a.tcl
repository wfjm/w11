# $Id: ekbee1_patch_w11a.tcl 1324 2022-12-01 11:24:20Z mueller $
# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright 2022- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
#
# Patch set ekbee1 for w11a -- w11a -- w11a -- w11a -- w11a -- w11a
#
# Note: Tcl has default radix 10 --> all octal numbers must start with '0' !!
#
# AP: skip test 046: 18-bit mapping adder ------------------------------------
#   uses maintenance bit, unsupported in SimH
#   Note: all par/pdr setup's done, only tests skiped
#         the next tests seem to depend on the par/pdr settings
#
dep 047720 000412
dep 050006 000412
dep 050074 000412
dep 050162 000412
dep 050250 000412
dep 050336 000412
dep 050424 000412
dep 050512 000412
dep 050600 000412
dep 050666 000412
dep 050754 000412
dep 051042 000412
#
# AP: patch test 50: 22-bit mapping carry propagation ------------------------
#   The test does an access to 17000000, the first word of the UNIBUS
#   window. It expects CPUERR 020 because UBMAP is disabled in MMR3.
#   w11 doesn't simulate the UNIBUS window and has a memory hole instead.
#   So access aborts with NXM instead of timeout.
#   Patch the testing instruction to it expects NXM in CPUERR.
;
dep 052212 000040
#
#  AP: patch test 55: ACF = 1 -------------------------------------------------
#  AP: patch test 56: ACF = 4 -------------------------------------------------
#  AP: patch test 57: ACF = 5 -------------------------------------------------
#    Tests 055, 056, and 057 verify trap response and check mmr0(6:1) which
#    isn't frozen for traps. The instruction is 'mov mmr0,pmmr0' with the
#    scr page 7 (IO page) and dst page 1 (where variables are). The test
#    expects for mmr0 011003, the destination page. On w11 one gets 011017,
#    the source page. Simply different flows. Certainly not an error.
#    Patch the locations to avoid the diagnostic message.
#
dep 054152 011017
dep 054302 011017
dep 054366 011017
dep 054564 011017
#
# AP: skip test 061: no MMU trap when MMU reg accessed -----------------------
#   Test verifies that no MMU traps are issued when MMU regs are accessed.
#   This is not implemented in w11, thus test skipped.
#
dep 054764 000137
dep 054766 055204
#
# AP: skip test 063: proper timing of MMU traps ------------------------------
#   Test tests also the trap behavior when MMU registers are accessed
#   This suppression is not implemented in w11, thus test skipped.
#
dep 055404 000137
dep 055406 055554
#
# AP: skip test 067: verify MMR0(7) ------------------------------------------
#   Tests verifies MMR0(7) instruction complete. Not implemented in w11.
#   The test loops-up.
#
dep 056536 000137
dep 056540 057120
#
#
# HACKS and DEBUG
#
# HP: skip test 071: MMR2 pattern test ---------------------------------------
#   this test tries all PC's in user mode --> skip to ease setting breakpoints
#   and skip in GHDL simulation, it's just a waste of time
#
if {[rlink::issim]} {
  dep 057532 000137
  dep 057534 057766
}
