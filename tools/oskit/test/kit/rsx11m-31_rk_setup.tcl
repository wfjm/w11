# $Id: rsx11m-31_rk_setup.tcl 1196 2019-07-20 18:18:16Z mueller $
# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright 2019- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
#
#  Revision History: 
# Date         Rev Version  Comment
# 2019-07-20  1196   1.0.1  Use os namespace rsx11m
# 2019-06-29  1173   1.0    Initial version
# 2019-06-10  1163   0.1    First draft
#---
# kit setup for rsx11m-31_rk
#

source ../os/rsx11m/rsx11m_base.tcl

set ::tenv(startup_q1)   ">\\* PLEASE ENTER TIME AND DATE.*?: "
set ::tenv(startup_a1)   "[rsx11m::rsx_date "hm_dmy2" 32]\r"
set ::tenv(startup_end)  ">@ <EOF>"
#
set ::tenv(shutdown_q1)  "ENTER MINUTES TO WAIT BEFORE SHUTDOWN: "
set ::tenv(shutdown_a1)  "\r"
