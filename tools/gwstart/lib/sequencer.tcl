# $Id: sequencer.tcl 1336 2022-12-23 19:31:01Z mueller $
# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright 2022- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
#
# pdp11_sequencer basics
#
gwaddcom "sequencer"
gwaddsig       {**.seq.clk}
gwaddsig       {**.seq.r_state}
gwaddsig -oct  {**.dpath.gr.pc}
gwaddsig -oct  {**.seq.ireg}
gwaddsig       {**.seq.mmu_moni.istart}
