/* -*- c++ -*- */
/* $Id: timer.c 1194 2019-07-20 07:43:21Z mueller $ */
/*-----------------------------------------------------------------------------
 * Timer handling for FX2
 *-----------------------------------------------------------------------------
 * Code taken from USRP2 firmware (GNU Radio Project), version 3.0.2,
 * SPDX-License-Identifier: GPL-3.0-or-later
 * Copyright 2003 Free Software Foundation, Inc.
 *-----------------------------------------------------------------------------
 * This code is part of usbjtag. usbjtag is free software;
 *-----------------------------------------------------------------------------
 */

#include "timer.h"
#include "fx2regs.h"
#include "isr.h"

/*
 * Arrange to have isr_tick_handler called at 100 Hz.
 *
 * The cpu clock is running at 48e6.  The input to the timer
 * is 48e6 / 12 = 4e6.
 *
 * We arrange to have the timer overflow every 40000 clocks == 100 Hz
 */

#define	RELOAD_VALUE	((unsigned short) -40000)

void 
hook_timer_tick (unsigned short isr_tick_handler)
{
  ET2 = 0;			// disable timer 2 interrupts
  hook_sv (SV_TIMER_2, isr_tick_handler);
  
  RCAP2H = RELOAD_VALUE >> 8;	// setup the auto reload value
  RCAP2L = RELOAD_VALUE & 0xFF;

  T2CON = 0x04;			// interrupt on overflow; reload; run
  ET2 = 1;			// enable timer 2 interrupts
}
