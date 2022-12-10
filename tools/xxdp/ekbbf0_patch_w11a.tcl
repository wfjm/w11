# $Id: ekbbf0_patch_w11a.tcl 1320 2022-11-22 18:52:59Z mueller $
# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright 2022- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
#
# Patch set ekbbf0 for w11a -- w11a -- w11a -- w11a -- w11a -- w11a
#
# Note: Tcl has default radix 10 --> all octal numbers must start with !!
#
# AP: patch test 014: DIV ----------------------------------------------------
#   fails in section 7: 100000 000000 / 2
#   expects NZVC = 1110  Z=1
#   w11 sets Z=0 for overflows -> patch comparison
#
dep 012074 000012
#
#   fails in section  8: 177776 177777 / -1
#   test specific result register values
#   w11 does not reproduce 11/70 registers after overflow
#   skip over this section
#
dep 012112 000137
dep 012114 012204
#
#   fails in section 12: 000100 000200 / -177
#   expects NZVC = 0010  N=0
#   w11 sets N based on real result sign -> patch comparison
#
dep 012532 000012
