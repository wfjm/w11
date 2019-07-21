/* $Id: eeprom.h 1194 2019-07-20 07:43:21Z mueller $ */
/*-----------------------------------------------------------------------------
 * FTDI EEPROM emulation
 *-----------------------------------------------------------------------------
 * SPDX-License-Identifier: GPL-3.0-or-later
 * Copyright (C) 2007 Kolja Waschk, ixo.de
 * This code is part of usbjtag. usbjtag is free software;
 *-----------------------------------------------------------------------------
 */

#ifndef _EEPROM_H
#define _EEPROM_H 1

extern xdata unsigned char eeprom[128];
extern void eeprom_init(void);

#endif /* _EEPROM_H */

