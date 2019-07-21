/* -*- c++ -*- */
/* $Id: fx2utils.h 1194 2019-07-20 07:43:21Z mueller $ */
/*-----------------------------------------------------------------------------
 * FX2 specific subroutines
 *-----------------------------------------------------------------------------
 * Code taken from USRP2 firmware (GNU Radio Project), version 3.0.2,
 * SPDX-License-Identifier: GPL-3.0-or-later
 * Copyright 2003 Free Software Foundation, Inc.
 *-----------------------------------------------------------------------------
 * This code is part of usbjtag. usbjtag is free software;
 *-----------------------------------------------------------------------------
 */

#ifndef _FX2UTILS_H_
#define _FX2UTILS_H_

void fx2_stall_ep0 (void);
void fx2_reset_data_toggle (unsigned char ep);
void fx2_renumerate (void);



#endif /* _FX2UTILS_H_ */
