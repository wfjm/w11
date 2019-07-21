/* -*- c++ -*- */
/* $Id: i2c.h 1194 2019-07-20 07:43:21Z mueller $ */
/*-----------------------------------------------------------------------------
 * I2C read/write functions for FX2
 *-----------------------------------------------------------------------------
 * Code taken from USRP2 firmware (GNU Radio Project), version 3.0.2,
 * SPDX-License-Identifier: GPL-3.0-or-later
 * Copyright 2003 Free Software Foundation, Inc.
 *-----------------------------------------------------------------------------
 * This code is part of usbjtag. usbjtag is free software;
 *-----------------------------------------------------------------------------
 */

#ifndef _I2C_H_
#define _I2C_H_

// returns non-zero if successful, else 0
unsigned char i2c_read (unsigned char addr, xdata unsigned char *buf, unsigned char len);

// returns non-zero if successful, else 0
unsigned char i2c_write (unsigned char addr, xdata const unsigned char *buf, unsigned char len);

#endif /* _I2C_H_ */
