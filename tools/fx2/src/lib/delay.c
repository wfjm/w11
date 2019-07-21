/* -*- c++ -*- */
/* $Id: delay.c 1194 2019-07-20 07:43:21Z mueller $ */
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

/*
 * Delay approximately 1 microsecond (including overhead in udelay).
 */
static void
udelay1 (void) _naked
{
  _asm				; lcall that got us here took 4 bus cycles
	ret			; 4 bus cycles
  _endasm;
}

/*
 * delay for approximately usecs microseconds
 */
void
udelay (unsigned char usecs)
{
  do {
    udelay1 ();
  } while (--usecs != 0);
}


/*
 * Delay approximately 1 millisecond.
 * We're running at 48 MHz, so we need 48,000 clock cycles.
 *
 * Note however, that each bus cycle takes 4 clock cycles (not obvious,
 * but explains the factor of 4 problem below).
 */
static void
mdelay1 (void) _naked
{
  _asm
	mov	dptr,#(-1200 & 0xffff)
002$:	
	inc	dptr		; 3 bus cycles
	mov	a, dpl		; 2 bus cycles
	orl	a, dph		; 2 bus cycles
	jnz	002$		; 3 bus cycles

	ret
  _endasm;
}

void
mdelay (unsigned int msecs)
{
  do {
    mdelay1 ();
  } while (--msecs != 0);
}

	
