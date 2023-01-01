# $Id: psr.tcl 1340 2023-01-01 08:43:05Z mueller $
# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright 2022- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
#
# pdp11_psr basics
#
gwaddcom "psr"
gwaddsig       {**.psr.clk}
gwaddsig -bin  {**.psr.r_psw.cmode}
gwaddsig -bin  {**.psr.r_psw.pmode}
gwaddsig       {**.psr.r_psw.rset}
gwaddsig -oct  {**.psr.r_psw.pri}
gwaddsig       {**.psr.r_psw.tflag}
gwaddsig -bin  {**.psr.r_psw.cc}
gwaddsig -bin  {**.psr.ccin}
gwaddsig       {**.psr.ccwe}
gwaddsig       {**.psr.we}
gwaddsig       {**.psr.func}
gwaddsig       {**.psr.ibsel_psr}
gwaddsig       {**.psr.ib_mreq.we}
gwaddsig       {**.psr.r_we_1}
