/* -*- c++ -*- */
/* $Id: timer.h 1194 2019-07-20 07:43:21Z mueller $ */
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

#ifndef _TIMER_H_
#define _TIMER_H_

/*
 * Arrange to have isr_tick_handler called at 100 Hz
 */
void hook_timer_tick (unsigned short isr_tick_handler);

#define clear_timer_irq()  				\
	TF2 = 0 	/* clear overflow flag */


#endif /* _TIMER_H_ */
