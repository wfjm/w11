/ $Id: getpsw.s 1276 2022-08-12 10:25:13Z mueller $
/ SPDX-License-Identifier: GPL-3.0-or-later
/ Copyright 2014-2022 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
/
/ Revision History:
/ Date         Rev Version  Comment
/ 2014-07-20   570   1.0    Initial version
/

.globl  valpsw
.data
valpsw: 0

.text
.globl  getpsw
        
getpsw:        
        bmi     cc1xxx                      / branch on N=1
        beq     cc01xx                      / branch on N=0,Z=1
        bvs     cc001x                      / branch on N=0,Z=0,V=1

        bcs     cc0001                      / branch on N=0,Z=0,V=0,C=1
        mov     $000, valpsw                / here      N=0,Z=0,V=0,C=0
        rts     pc
cc0001: mov     $001, valpsw                / here      N=0,Z=0,V=0,C=1
        rts     pc

cc001x: bcs     cc0011                      / branch on N=0,Z=0,V=1,C=1
        mov     $002, valpsw                / here      N=0,Z=0,V=1,C=0
        rts     pc
cc0011: mov     $003, valpsw                / here      N=0,Z=0,V=1,C=1
        rts     pc

cc01xx: bvs     cc011x                      / branch on N=0,Z=1,V=1

        bcs     cc0101                      / branch on N=0,Z=1,V=0,C=1
        mov     $004, valpsw                / here      N=0,Z=1,V=0,C=0
        rts     pc
cc0101: mov     $005, valpsw                / here      N=0,Z=1,V=0,C=1
        rts     pc

cc011x: bcs     cc0111                      / branch on N=0,Z=1,V=1,C=1
        mov     $006, valpsw                / here      N=0,Z=1,V=1,C=0
        rts     pc
cc0111: mov     $007, valpsw                / here      N=0,Z=1,V=1,C=1
        rts     pc

cc1xxx: beq     cc01xx                      / branch on N=1,Z=1
        bvs     cc001x                      / branch on N=1,Z=0,V=1

        bcs     cc1001                      / branch on N=1,Z=0,V=0,C=1
        mov     $010, valpsw                / here      N=1,Z=0,V=0,C=0
        rts     pc
cc1001: mov     $011, valpsw                / here      N=1,Z=0,V=0,C=1
        rts     pc

cc101x: bcs     cc1011                      / branch on N=1,Z=0,V=1,C=1
        mov     $012, valpsw                / here      N=1,Z=0,V=1,C=0
        rts     pc
cc1011: mov     $013, valpsw                / here      N=1,Z=0,V=1,C=1
        rts     pc

cc11xx: bvs     cc111x                      / branch on N=1,Z=1,V=1

        bcs     cc1101                      / branch on N=1,Z=1,V=0,C=1
        mov     $014, valpsw                / here      N=1,Z=1,V=0,C=0
        rts     pc
cc1101: mov     $015, valpsw                / here      N=1,Z=1,V=0,C=1
        rts     pc

cc111x: bcs     cc1111                      / branch on N=1,Z=1,V=1,C=1
        mov     $016, valpsw                / here      N=1,Z=1,V=1,C=0
        rts     pc
cc1111: mov     $017, valpsw                / here      N=1,Z=1,V=1,C=1
        rts     pc
