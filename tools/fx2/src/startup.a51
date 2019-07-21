;;; -*- asm -*-
;;; $Id: startup.a51 1194 2019-07-20 07:43:21Z mueller $ 
;;;
;;;-----------------------------------------------------------------------------
;;; Startup code
;;;-----------------------------------------------------------------------------
;;; Code taken from USRP2 firmware (GNU Radio Project), version 3.0.2,
;;; SPDX-License-Identifier: GPL-3.0-or-later
;;; Copyright 2003 Free Software Foundation, Inc.
;;;-----------------------------------------------------------------------------
;;; This code is part of usbjtag. 
;;;-----------------------------------------------------------------------------

;;; The default external memory initialization provided by sdcc is not
;;; appropriate to the FX2.  This is derived from the sdcc code, but uses 
;;; the FX2 specific _MPAGE sfr.


        ;; .area XISEG   (XDATA)  ; the initialized external data area
        ;; .area XINIT   (CODE)          ; the code space consts to init XISEG
        .area XSEG    (XDATA)          ; zero initialized xdata
        .area USBDESCSEG (XDATA)  ; usb descriptors

        
        .area CSEG    (CODE)

        ;; sfr that sets upper address byte of MOVX using @r0 or @r1
        _MPAGE        =        0x0092

__sdcc_external_startup::
        ;; This system is now compiled with the --no-xinit-opt 
        ;; which means that any initialized XDATA is handled
        ;; inline by code in the GSINIT segs emitted for each file.
        ;; 
        ;; We zero XSEG and all of the internal ram to ensure 
        ;; a known good state for uninitialized variables.

;        _mcs51_genRAMCLEAR() start
        mov        r0,#l_XSEG
        mov        a,r0
        orl        a,#(l_XSEG >> 8)
        jz        00002$
        mov        r1,#((l_XSEG + 255) >> 8)
        mov        dptr,#s_XSEG
        clr     a
        
00001$:        movx        @dptr,a
        inc        dptr
        djnz        r0,00001$
        djnz        r1,00001$
        
        ;; We're about to clear internal memory.  This will overwrite
        ;; the stack which contains our return address.
        ;; Pop our return address into DPH, DPL
00002$:        pop        dph
        pop        dpl
        
        ;; R0 and A contain 0.  This loop will execute 256 times.
        ;; 
        ;; FWIW the first iteration writes direct address 0x00,
        ;; which is the location of r0.  We get lucky, we're 
        ;; writing the correct value (0)
        
00003$:        mov        @r0,a
        djnz        r0,00003$

        push        dpl                ; restore our return address
        push        dph

        mov        dpl,#0                ; indicate that data init is still required
        ret
