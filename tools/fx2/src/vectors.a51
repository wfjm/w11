;;; -*- asm -*-
;;; $Id: vectors.a51 1194 2019-07-20 07:43:21Z mueller $ 
;;;
;;;-----------------------------------------------------------------------------
;;; Interrupt vectors
;;;-----------------------------------------------------------------------------
;;; Code taken from USRP2 firmware (GNU Radio Project), version 3.0.2,
;;; SPDX-License-Identifier: GPL-3.0-or-later
;;; Copyright 2003 Free Software Foundation, Inc.
;;;-----------------------------------------------------------------------------
;;; This code is part of usbjtag. usbjtag is free software;
;;;-----------------------------------------------------------------------------

;;; N.B. This object module must come first in the list of modules

        .module vectors

;;; ----------------------------------------------------------------
;;;                  standard FX2 interrupt vectors
;;; ----------------------------------------------------------------

        .area CSEG (CODE)
        .area GSINIT (CODE)
        .area CSEG (CODE)
__standard_interrupt_vector::
__reset_vector::
        ljmp        s_GSINIT
        
        ;; 13 8-byte entries.  We point them all at __isr_nop
        ljmp        __isr_nop        ; 3 bytes
        .ds        5                ; + 5 = 8 bytes for vector slot
        ljmp        __isr_nop
        .ds        5
        ljmp        __isr_nop
        .ds        5
        ljmp        __isr_nop
        .ds        5
        ljmp        __isr_nop
        .ds        5
        ljmp        __isr_nop
        .ds        5
        ljmp        __isr_nop
        .ds        5
        ljmp        __isr_nop
        .ds        5
        ljmp        __isr_nop
        .ds        5
        ljmp        __isr_nop
        .ds        5
        ljmp        __isr_nop
        .ds        5
        ljmp        __isr_nop
        .ds        5
        ljmp        __isr_nop
        .ds        5

__isr_nop::
        reti

;;; ----------------------------------------------------------------
;;; the FIFO/GPIF autovector.  14 4-byte entries.
;;; must start on a 128 byte boundary.
;;; ----------------------------------------------------------------
        
        . = __reset_vector + 0x0080
                
__fifo_gpif_autovector::
        ljmp        __isr_nop
        nop        
        ljmp        __isr_nop
        nop        
        ljmp        __isr_nop
        nop        
        ljmp        __isr_nop
        nop        
        ljmp        __isr_nop
        nop        
        ljmp        __isr_nop
        nop        
        ljmp        __isr_nop
        nop        
        ljmp        __isr_nop
        nop        
        ljmp        __isr_nop
        nop        
        ljmp        __isr_nop
        nop        
        ljmp        __isr_nop
        nop        
        ljmp        __isr_nop
        nop        
        ljmp        __isr_nop
        nop        
        ljmp        __isr_nop
        nop        

        
;;; ----------------------------------------------------------------
;;; the USB autovector.  32 4-byte entries.
;;; must start on a 256 byte boundary.
;;; ----------------------------------------------------------------

        . = __reset_vector + 0x0100
        
__usb_autovector::
        ljmp        __isr_nop
        nop
        ljmp        __isr_nop
        nop
        ljmp        __isr_nop
        nop
        ljmp        __isr_nop
        nop
        ljmp        __isr_nop
        nop
        ljmp        __isr_nop
        nop
        ljmp        __isr_nop
        nop
        ljmp        __isr_nop
        nop
        ljmp        __isr_nop
        nop
        ljmp        __isr_nop
        nop
        ljmp        __isr_nop
        nop
        ljmp        __isr_nop
        nop
        ljmp        __isr_nop
        nop
        ljmp        __isr_nop
        nop
        ljmp        __isr_nop
        nop
        ljmp        __isr_nop
        nop
        ljmp        __isr_nop
        nop
        ljmp        __isr_nop
        nop
        ljmp        __isr_nop
        nop
        ljmp        __isr_nop
        nop
        ljmp        __isr_nop
        nop
        ljmp        __isr_nop
        nop
        ljmp        __isr_nop
        nop
        ljmp        __isr_nop
        nop
        ljmp        __isr_nop
        nop
        ljmp        __isr_nop
        nop
        ljmp        __isr_nop
        nop
        ljmp        __isr_nop
        nop
        ljmp        __isr_nop
        nop
        ljmp        __isr_nop
        nop
        ljmp        __isr_nop
        nop
        ljmp        __isr_nop
        nop
