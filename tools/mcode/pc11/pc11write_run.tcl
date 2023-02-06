# $Id: pc11write_run.tcl 1367 2023-02-06 14:11:34Z mueller $
# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright 2023- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
#
cpu0pp att w11_pc11write.dat
cpu0 ldasm -file pc11write.mac -sym sym
cpu0 cp -stapc $sym(...end)
rw11::asmwait cpu0 sym
