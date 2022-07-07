/* $Id: rlink_cext_dpi.c 1247 2022-07-06 07:04:33Z mueller $
 * SPDX-License-Identifier: GPL-3.0-or-later
 * Copyright 2016-2022 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
 *
 *  Revision History: 
 * Date         Rev  Vers    Comment
 * 2022-07-05  1247   1.0.1  add function declarations to avoid xelab warnings
 * 2016-02-07   729   1.0    Initial version 
 */ 

#include "svdpi.h"

/* simple forwarders to call the old VHPI interface from DPI */

int rlink_cext_getbyte(int clk);
int rlink_cext_putbyte(int dat);

DPI_DLLESPEC
int rlink_cext_getbyte_dpi(int clk)
{
  return rlink_cext_getbyte(clk);
}

DPI_DLLESPEC
int rlink_cext_putbyte_dpi(int dat)
{
  return rlink_cext_putbyte(dat);
}
