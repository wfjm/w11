# $Id: tm11test_run.tcl 1367 2023-02-06 14:11:34Z mueller $
# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright 2023- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
#
cpu0tma0 att w11_tm11test.tap
cpu0 ldasm -file tm11test.mac -sym sym
cpu0 cp -stapc $sym(...end)
rw11::asmwait cpu0 sym
