/* -*- c++ -*- */
/* $Id: fx2utils.c 1194 2019-07-20 07:43:21Z mueller $ */
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

#include "fx2utils.h"
#include "fx2regs.h"
#include "delay.h"

void
fx2_stall_ep0 (void)
{
  EP0CS |= bmEPSTALL;
}

void
fx2_reset_data_toggle (unsigned char ep)
{
  TOGCTL = ((ep & 0x80) >> 3 | (ep & 0x0f));
  TOGCTL |= bmRESETTOGGLE;
}

void
fx2_renumerate (void)
{
  USBCS |= bmDISCON | bmRENUM;

  // mdelay (1500);		// FIXME why 1.5 seconds?
  mdelay (250);			// FIXME why 1.5 seconds?
  
  USBIRQ = 0xff;		// clear any pending USB irqs...
  EPIRQ =  0xff;		//   they're from before the renumeration

  EXIF &= ~bmEXIF_USBINT;

  USBCS &= ~bmDISCON;		// reconnect USB
}
