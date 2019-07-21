/* $Id: hardware.h 1194 2019-07-20 07:43:21Z mueller $ */
/*-----------------------------------------------------------------------------
 * Hardware-dependent code for usb_jtag
 *-----------------------------------------------------------------------------
 * SPDX-License-Identifier: GPL-3.0-or-later
 * Copyright (C) 2007 Kolja Waschk, ixo.de
 * This code is part of usbjtag. usbjtag is free software;
 *-----------------------------------------------------------------------------
 */

#ifndef _HARDWARE_H
#define _HARDWARE_H 1

extern void ProgIO_Init(void);
extern void ProgIO_Poll(void);
extern void ProgIO_Enable(void);
extern void ProgIO_Disable(void);
extern void ProgIO_Deinit(void);

extern void ProgIO_Set_State(unsigned char d);
extern unsigned char ProgIO_Set_Get_State(unsigned char d);
extern void ProgIO_ShiftOut(unsigned char x);
extern unsigned char ProgIO_ShiftInOut(unsigned char x);

#endif /* _HARDWARE_H */

