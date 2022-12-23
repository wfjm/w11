# $Id: mmu.tcl 1336 2022-12-23 19:31:01Z mueller $
# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright 2022- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
#
# pdp11_mmu basics
#
gwaddcom "mmu"
gwaddsig       {**.vmbox.mmu.clk}
gwaddsig       {**.vmbox.mmu.cntl.req}
gwaddsig       {**.vmbox.mmu.moni.istart}
gwaddsig       {**.vmbox.mmu.moni.vstart}
gwaddsig -oct  {**.vmbox.mmu.mmr12.r_mmr2}
gwaddsig -oct  {**.vmbox.mmu.mmr12.vaddr}
gwaddsig -sdec {**.vmbox.mmu.mmr12.r_mmr1.ra_delta}
gwaddsig -dec  {**.vmbox.mmu.mmr12.r_mmr1.ra_num}
gwaddsig -sdec {**.vmbox.mmu.mmr12.r_mmr1.rb_delta}
gwaddsig -dec  {**.vmbox.mmu.mmr12.r_mmr1.rb_num}
gwaddsig       {**.vmbox.mmu.aib_*}
gwaddsig       {**.vmbox.mmu.r_mmr0.abo_nonres}
gwaddsig       {**.vmbox.mmu.r_mmr0.abo_length}
gwaddsig       {**.vmbox.mmu.r_mmr0.abo_rdonly}
gwaddsig       {**.vmbox.mmu.r_mmr0.trap_mmu}
gwaddsig       {**.vmbox.mmu.r_mmr0.ena_trap}
gwaddsig       {**.vmbox.mmu.r_mmr0.inst_compl}
gwaddsig -oct  {**.vmbox.mmu.r_mmr0.page_mode}
gwaddsig       {**.vmbox.mmu.r_mmr0.page_dspace}
gwaddsig -oct  {**.vmbox.mmu.r_mmr0.page_num}
gwaddsig       {**.vmbox.mmu.r_mmr0.ena_mmu}
