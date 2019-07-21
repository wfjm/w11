/* -*- c++ -*- */
/* $Id: delay.h 1194 2019-07-20 07:43:21Z mueller $ */
/*-----------------------------------------------------------------------------
 * Delay routines
 *-----------------------------------------------------------------------------
 * Code taken from USRP2 firmware (GNU Radio Project), version 3.0.2,
 * SPDX-License-Identifier: GPL-3.0-or-later
 * Copyright 2003 Free Software Foundation, Inc.
 *-----------------------------------------------------------------------------
 * This code is part of usbjtag. usbjtag is free software;
 *-----------------------------------------------------------------------------
 */

#ifndef _DELAY_H_
#define _DELAY_H_

/*
 * delay for approximately usecs microseconds
 * Note limit of 255 usecs.
 */
void udelay (unsigned char usecs);

/*
 * delay for approximately msecs milliseconds
 */
void mdelay (unsigned short msecs);


#endif /* _DELAY_H_ */
