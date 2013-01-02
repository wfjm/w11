/* -*- c++ -*- */
/* $Id: syncdelay.h 395 2011-07-17 22:02:55Z mueller $ */
/*-----------------------------------------------------------------------------
 * Synchronization delay for FX2 access to specific registers
 *-----------------------------------------------------------------------------
 * Code taken from USRP2 firmware (GNU Radio Project), version 3.0.2,
 * Copyright 2003 Free Software Foundation, Inc.
 *-----------------------------------------------------------------------------
 * This code is part of usbjtag. usbjtag is free software; you can redistribute
 * it and/or modify it under the terms of the GNU General Public License as
 * published by the Free Software Foundation; either version 2 of the License,
 * or (at your option) any later version. usbjtag is distributed in the hope
 * that it will be useful, but WITHOUT ANY WARRANTY; without even the implied
 * warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.  You should have received a
 * copy of the GNU General Public License along with this program in the file
 * COPYING; if not, write to the Free Software Foundation, Inc., 51 Franklin
 * St, Fifth Floor, Boston, MA  02110-1301  USA
 *-----------------------------------------------------------------------------
 */

#ifndef _SYNCDELAY_H_
#define _SYNCDELAY_H_

/*
 * Magic delay required between access to certain xdata registers (TRM page 15-106).
 * For our configuration, 48 MHz FX2 / 48 MHz IFCLK, we need three cycles.  Each
 * NOP is a single cycle....
 *
 * From TRM page 15-105:
 *
 * Under certain conditions, some read and write access to the FX2 registers must
 * be separated by a "synchronization delay".  The delay is necessary only under the
 * following conditions:
 *
 *   - between a write to any register in the 0xE600 - 0xE6FF range and a write to one
 *     of the registers listed below.
 *
 *   - between a write to one of the registers listed below and a read from any register
 *     in the 0xE600 - 0xE6FF range.
 *
 *   Registers which require a synchronization delay:
 *
 *	FIFORESET			FIFOPINPOLAR
 *	INPKTEND			EPxBCH:L
 *	EPxFIFOPFH:L			EPxAUTOINLENH:L
 *	EPxFIFOCFG			EPxGPIFFLGSEL
 *	PINFLAGSAB			PINFLAGSCD
 *	EPxFIFOIE			EPxFIFOIRQ
 *	GPIFIE				GPIFIRQ
 *	UDMACRCH:L			GPIFADRH:L
 *	GPIFTRIG			EPxGPIFTRIG
 *	OUTPKTEND			REVCTL
 *	GPIFTCB3			GPIFTCB2
 *	GPIFTCB1			GPIFTCB0
 */

/*
 * FIXME ensure that the peep hole optimizer isn't screwing us
 */
#define	SYNCDELAY	_asm nop; nop; nop; _endasm
#define	NOP		_asm nop; _endasm


#endif /* _SYNCDELAY_H_ */
