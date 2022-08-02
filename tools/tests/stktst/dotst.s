/ $Id:  $
/ SPDX-License-Identifier: GPL-3.0-or-later
/ Copyright 2022- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
/
/ called from C as 
/    irc = dotst(idat, odat)
/ with
/    idat[0]   command ('I','i','l','f','d','r','w', or 'h')
/    idat[1]   command repeat count
/    idat[2]   -c repeat count
/    idat[3]   -s repeat count
/    idat[4]   -o byte offset
/ and returns in odat
/    odat[0]   sp before align and offset
/    odat[1]   sp after  align and offset
/    odat[2]   sp final
/
/ Revision History:
/ Date         Rev Version  Comment
/ 2022-08-01  1267   1.0    Initial version
/

.globl  _dotst
.text
        
_dotst: mov     r2,-(sp)                    / save r2 (r0,r1 are volatile)
        mov     r3,-(sp)                    / save r3
        mov     r4,-(sp)                    / save r4
        mov     r5,-(sp)                    / save r5
                                            / now   (sp) -> saved r5
                                            /      2(sp) -> saved r4
                                            /      4(sp) -> saved r3
                                            /      6(sp) -> saved r2
                                            /     10(sp) -> return address
                                            /     12(sp) -> 1st arg: idat
                                            /     14(sp) -> 2nd arg: odat
        
        mov     12(sp), r2                  / r2 = idat
        mov     14(sp), r3                  / r3 = odat

        mov     sp,r5                       / save sp
        mov     sp,(r3)                     / store original sp in odat[0]
        mov     sp,2(r3)                    / store original sp in odat[1]
        mov     sp,4(r3)                    / store original sp in odat[2]

/ handle r,w,h commands first
        clr     r0                          / set exit code
        movb    (r2),r1                     / command code
        mov     2(r2),r4                    / repeat count used as address

/ handle 'r': probe read
        cmpb    $'r,r1
        bne     testw
        mov     (r4),r1                     / probe read
        br      done

/ handle 'w': probe read/write
testw:  cmpb    $'w,r1
        bne     testh
        mov     (r4),r1                     / probe read
        mov     r1,(r4)                     / probe re-write
        br      done

/ handle 'h': probe halt
testh:  cmpb    $'h,r1
        bne     testx
        halt                                / success is crash here :)
testx:

/ apply sp aligns and offset. In python pseudo code do
/   # segmemt align
/   if idat[3] > 0:
/     sp &= 017777
/     sp -= 8192 * (idat[3]-1)
/   # click align 
/   if idat[2] > 0:
/     sp &= 077
/     sp -= 64 * (idat[2]-1)
/   # byte offset
/   sp += idat[4]
/
        mov     sp,r4
/ handle -s
        tst     6(r2)                       / idat[3] -s count > 0 ?
        beq     optc
        bic     $017777,r4                  / sp &= 017777
        mov     6(r2),r1
        dec     r1                          / idat[3]-1
        mul     $020000,r1
        sub     r1,r4                       / sp -= 8192 * (idat[3]-1)
/ handle -c
optc:   tst     4(r2)                       / idat[2] -c count > 0 ?
        beq     opto
        bic     $000077,r4                  / sp &= 077
        mov     4(r2),r1
        dec     r1                          / idat[2]-1
        mul     $000100,r1
        sub     r1,r4                       / sp -= 64 * (idat[2]-1)
/ handle -o
opto:   add     10(r2),r4
        mov     r4,sp
        mov     sp,2(r3)                    / store aligned+offset sp in odat[1]

/ prepare command handling
        clr     r0                          / set exit code
        mov     (r2),r1                     / command code
        mov     2(r2),r4                    / command repeat count
        beq     done                        / if zero quit

/ handle 'I': clr -(sp)
        cmpb    $'I,r1
        bne     testi
1:      clr     -(sp)
        sob     r4,1b
        br      done

/ handle 'i': stcfi f0,-(sp);  movfi fr0,-(sp) in BSD
testi:  cmpb    $'i,r1
        bne     testl
        seti
        setf
        clrf    fr0
1:      movfi   fr0,-(sp)
        sob     r4,1b
        br      done

/ handle 'l': stcfl f0,-(sp);  movfi fr0,-(sp) in BSD
testl:  cmpb    $'l,r1
        bne     testf
        setl
        setf
        clrf    fr0
1:      movfi   fr0,-(sp)
        sob     r4,1b
        br      done

/ handle 'f': stf f0,-(sp);   movf fr0,-(sp) in BSD
testf:  cmpb    $'f,r1
        bne     testd
        setf
        clrf    fr0
1:      movf    fr0,-(sp)
        sob     r4,1b
        br      done

/ handle 'd': std f0,-(sp);   movf fr0,-(sp) in BSD
testd:  cmpb    $'d,r1
        bne     quit
        setd
        clrf    fr0
1:      movf    fr0,-(sp)
        sob     r4,1b
        br      done

/ quit with bad command
quit:   inc     r0

/ final cleanup
done:   mov     sp,4(r3)                    / sp after tests
        mov     r5,sp                       / restore sp
        mov     (sp)+,r5                    / restore r5
        mov     (sp)+,r4                    / restore r4
        mov     (sp)+,r3                    / restore r3
        mov     (sp)+,r2                    / restore r2
        rts     pc
