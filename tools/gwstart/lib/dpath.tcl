# $Id: dpath.tcl 1384 2023-03-22 07:35:32Z mueller $
# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright 2023- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
#
# pdp11_dpath basics
#
gwaddcom "dpath"
gwaddsig       {**.dpath.clk}
gwaddsig       {**.dpath.cntl.dsrc_we}
gwaddsig       {**.dpath.cntl.dsrc_sel}
gwaddsig -oct  {**.dpath.r_dsrc}
gwaddsig       {**.dpath.cntl.ddst_we}
gwaddsig       {**.dpath.cntl.ddst_sel}
gwaddsig -oct  {**.dpath.r_ddst}
gwaddsig       {**.dpath.cntl.dtmp_we}
gwaddsig       {**.dpath.cntl.dtmp_sel}
gwaddsig -oct  {**.dpath.r_dtmp}
