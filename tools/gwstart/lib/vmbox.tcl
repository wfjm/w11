# $Id: vmbox.tcl 1336 2022-12-23 19:31:01Z mueller $
# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright 2022- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
#
# pdp11_vmbox basics
#
gwaddcom "vmbox"
gwaddsig       {**.vmbox.clk}
gwaddsig       {**.vmbox.r_regs.state}
gwaddsig       {**.vmbox.r_regs.trap_mmu}
gwaddsig       {**.vmbox.vm_cntl.req}
gwaddsig       {**.vmbox.vm_cntl.cacc}
gwaddsig       {**.vmbox.vm_cntl.macc}
gwaddsig       {**.vmbox.vm_cntl.wacc}
gwaddsig -oct  {**.vmbox.vm_addr}
gwaddsig -oct  {**.vmbox.vm_din}
gwaddsig -oct  {**.vmbox.vm_dout}
gwaddsig       {**.vmbox.vm_stat.ack}
gwaddsig       {**.vmbox.vm_stat.err}
gwaddsig       {**.vmbox.vm_stat.trap_mmu}
