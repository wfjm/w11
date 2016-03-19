/* $Id: rlink_cext_dpi.c 730 2016-02-13 16:22:03Z mueller $
 *
 * Copyright 2016- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
 *
 * This program is free software; you may redistribute and/or modify it under
 * the terms of the GNU General Public License as published by the Free
 * Software Foundation, either version 2, or at your option any later version.
 *
 * This program is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY, without even the implied warranty of MERCHANTABILITY
 * or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
 * for complete details.
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
