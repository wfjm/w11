/ $Id: dotst.s 1266 2022-07-30 17:33:07Z mueller $
/ SPDX-License-Identifier: GPL-3.0-or-later
/ Copyright 2014-2022 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
/
/ called from C as 
/    dotst(idat, odat)
/ with
/    idat[0]   divident high (even r)
/    idat[1]   divident low  (odd  r)
/    idat[2]   divisor
/ and returns in odat
/    odat[0]   psw
/    odat[1]   quotient (even r)
/    odat[2]   reminder (odd  r)
/
/ Revision History:
/ Date         Rev Version  Comment
/ 2014-07-20   570   1.0    Initial version
/

.globl  _dotst
.text
        
_dotst: mov     r2,-(sp)                    / save r2 (r0,r1 are volatile)
                                            / now   (sp) -> saved r2
                                            /      2(sp) -> return address
                                            /      4(sp) -> 1st arg: idat
                                            /      6(sp) -> 2ns arg: odat
        
        mov     4(sp), r2                   / r2 = idat

        mov     (r2), r0                    / load dd high
        mov     2(r2),r1                    / load dd low
        div     4(r2),r0                    / do divide

        jsr     pc, getpsw                  / obtain psw in user mode

        mov     6(sp), r2                   / r2 = odat
        mov     valpsw, (r2)                / store psw
        mov     r0, 2(r2)                   / store quotient
        mov     r1, 4(r2)                   / store remainder

        mov     (sp)+,r2                    / restore r2
        rts     pc
        



        
