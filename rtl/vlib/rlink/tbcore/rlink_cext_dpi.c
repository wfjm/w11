/* $Id: rlink_cext_dpi.c 1190 2019-07-13 17:05:39Z mueller $
 * SPDX-License-Identifier: GPL-3.0-or-later
 * Copyright 2016- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
 *
 *  Revision History: 
 * Date         Rev  Vers    Comment
 * 2016-02-07   729   1.0    Initial version 
 */ 

#include "svdpi.h"

/* simple forwarders to call the old VHPI interface from DPI */

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
