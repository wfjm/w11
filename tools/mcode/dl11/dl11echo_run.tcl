# $Id: dl11echo_run.tcl 1367 2023-02-06 14:11:34Z mueller $
# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright 2023- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
#
rw11::setup_tt cpu0
cpu0 ldasm -file dl11echo.mac -sym sym
cpu0 cp -stapc $sym(...end)
#
puts "dl11echo running, quit with .qq"
