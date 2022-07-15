# $Id: test_w11a_inst_quick.tcl 1254 2022-07-13 06:16:19Z mueller $
# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright 2022- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
#
# Revision History:
# Date         Rev Version  Comment
# 2022-07-12  1254   1.0    Initial version
#
# Quick instruction test.
#   Most arithmetic instructions are used, usully for a single value
#   Full testing with all corner cases is done in tcode cpu_basics.mac  
#

# ----------------------------------------------------------------------------
rlc log "test_w11a_inst_quick: quick instruction test ------------------------"

# -- Section A ---------------------------------------------------------------
rlc log "  Word instructions -----------------------------------------"
# derived from tb_pdp11core_stim.dat code 17
#   r3  points to data, each instruction reads or modifies one value
#   r4  points to check data, the values after instruction
#   r5  points to check psw, the psw values after instruction

$cpu ldasm -lst lst -sym sym {
        .include        |lib/defs_cpu.mac|
        .include        |lib/vec_cpucatch.mac|
;
; setup bpt vector
        . = 000014
        .word   vh.bpt
        .word   0
;
        . = 1000
stack:
;
; bpt vector handler
vh.bpt: cmp     -2(r3),(r4)+    ; check modified data
        beq     1$
        halt
1$:     cmp     2(sp),(r5)+     ; check psw saved on stack
        beq     2$
        halt
2$:     rtt                     ; ensure next instruction is executed

; main code
start:  mov     r1,(r3)+        ; (#4711,  #123456)
        cmp     r1,(r3)+        ; (#4711,  #123456)
        cmp     r2,(r3)+        ; (#123456,#4711)
        cmp     r1,(r3)+        ; (#4711,  #4711)
        clr     (r3)+           ; (#123456)
        bit     r1,(r3)+        ; (#4711,  #11)
        bit     r1,(r3)+        ; (#4711,  #66)
        bic     r1,(r3)+        ; (#4711,  #123456)
        bis     r1,(r3)+        ; (#4711,  #123456)
        add     r1,(r3)+        ; (#4711,  #123456)
        sub     r1,(r3)+        ; (#4711,  #123456)
        com     (r3)+           ; (#123456)
        inc     (r3)+           ; (#123456)
        dec     (r3)+           ; (#123456)
        neg     (r3)+           ; (#123456)
        tst     (r3)+           ; (#123456)
        ror     (r3)+           ; (#100201)   Cin=0; Cout=1
        ror     (r3)+           ; (#002201)   Cin=1; Cout=1
        rol     (r3)+           ; (#100200)   Cin=1; Cout=1
        asr     (r3)+           ; (#200)
        asr     (r3)+           ; (#100200)
        asl     (r3)+           ; (#200)
        asl     (r3)+           ; (#100200)
        add     r1,(r3)+        ; (#4711,   #077777)
        adc     (r3)+           ; (#200)   
        sub     r1,(r3)+        ; (#4711,   #4700)
        sbc     (r3)+           ; (#200)
        swab    (r3)+           ; (#111000)
        sxt     (r3)+           ; (#111111 with N=1)
        xor     r1,(r3)+        ; (#070707,#4711)
        sxt     (r3)+           ; (#111111 with N=0)
        halt
stop:

; input data for code
data:   .word   123456          ; mov r1,(r3)+ (#4711,  #123456)
        .word   123456          ; cmp r1,(r3)+ (#4711,  #123456)
        .word   004711          ; cmp r1,(r3)+ (#123456,#4711)  
        .word   004711          ; cmp r1,(r3)+ (#4711,  #4711)  
        .word   123456          ; clr (r3)+    (#123456)
        .word   000011          ; bit r1,(r3)+ (#4711,  #11)    
        .word   000066          ; bit r1,(r3)+ (#4711,  #66)    
        .word   123456          ; bic r1,(r3)+ (#4711,  #123456)
        .word   123456          ; bis r1,(r3)+ (#4711,  #123456)
        .word   123456          ; add r1,(r3)+ (#4711,  #123456)
        .word   123456          ; sub r1,(r3)+ (#4711,  #123456)
        .word   123456          ; com (r3)+    (#123456)
        .word   123456          ; inc (r3)+    (#123456)
        .word   123456          ; dec (r3)+    (#123456)
        .word   123456          ; neg (r3)+    (#123456)
        .word   123456          ; tst (r3)+    (#123456)
        .word   100201          ; ror (r3)+    (#100201)
        .word   002201          ; ror (r3)+    (#002201)
        .word   100200          ; rol (r3)+    (#100200)
        .word   000200          ; asr (r3)+    (#200)   
        .word   100200          ; asr (r3)+    (#100200)   
        .word   000200          ; asl (r3)+    (#200)   
        .word   100200          ; asl (r3)+    (#100200)   
        .word   177000          ; add r1,(r3)+ (#4711, ,#177000)
        .word   000200          ; adc (r3)+    (#200)
        .word   004701          ; sub r1,(r3)+ (#4711,  #4701)
        .word   000200          ; sbc (r3)+    (#200)
        .word   111000          ; swab (r3)+   (#111000)
        .word   111111          ; sxt (r3)+    (#111111)
        .word   070707          ; xor r1,(r3)+ (#070707)
        .word   111111          ; sxt (r3)+    (#111111)
;
; data check, values after instruction
chkdat: .word   004711          ; mov r1,(r3)+ (#4711,  #123456)
        .word   123456          ; cmp r1,(r3)+ (#4711,  #123456)
        .word   004711          ; cmp r1,(r3)+ (#123456,#4711)  
        .word   004711          ; cmp r1,(r3)+ (#4711,  #4711)  
        .word   000000          ; clr (r3)+    (#123456)
        .word   000011          ; bit r1,(r3)+ (#4711,  #11)    
        .word   000066          ; bit r1,(r3)+ (#4711,  #66)    
        .word   123046          ; bic r1,(r3)+ (#4711,  #123456)
        .word   127757          ; bis r1,(r3)+ (#4711,  #123456)
        .word   130367          ; add r1,(r3)+ (#4711,  #123456)
        .word   116545          ; sub r1,(r3)+ (#4711,  #123456)
        .word   054321          ; com (r3)+    (#123456)
        .word   123457          ; inc (r3)+    (#123456)
        .word   123455          ; dec (r3)+    (#123456)
        .word   054322          ; neg (r3)+    (#123456)
        .word   123456          ; tst (r3)+    (#123456)
        .word   040100          ; ror (r3)+    (#100201)
        .word   101100          ; ror (r3)+    (#002201)
        .word   000401          ; rol (r3)+    (#100200)
        .word   000100          ; asr (r3)+    (#200)   
        .word   140100          ; asr (r3)+    (#100200)   
        .word   000400          ; asl (r3)+    (#200)   
        .word   000400          ; asl (r3)+    (#100200)   
        .word   003711          ; add r1,(r3)+ (#4711, ,#177000)
        .word   000201          ; adc (r3)+    (#200)
        .word   177770          ; sub r1,(r3)+ (#4711,  #4701)
        .word   000177          ; sbc (r3)+    (#200)
        .word   000222          ; swab (r3)+   (#111000)
        .word   177777          ; sxt (r3)+    (#111111)
        .word   074016          ; xor r1,(r3)+ (#070707)
        .word   000000          ; sxt (r3)+    (#111111)
;
; psw check, condition codes after instruction (Note: T bit always set !)
chkcc:  .word   000020          ; 0000; mov r1,(r3)+ (#4711,  #123456)
        .word   000021          ; 000C; cmp r1,(r3)+ (#4711,  #123456)
        .word   000030          ; N000; cmp r1,(r3)+ (#123456,#4711)  
        .word   000024          ; 0Z00; cmp r1,(r3)+ (#4711,  #4711)  
        .word   000024          ; 0Z00; clr (r3)+    (#123456)
        .word   000020          ; 0000; bit r1,(r3)+ (#4711,  #11)    
        .word   000024          ; 0Z00; bit r1,(r3)+ (#4711,  #66)    
        .word   000030          ; N000; bic r1,(r3)+ (#4711,  #123456)
        .word   000030          ; N000; bis r1,(r3)+ (#4711,  #123456)
        .word   000030          ; N000; add r1,(r3)+ (#4711,  #123456)
        .word   000030          ; N000; sub r1,(r3)+ (#4711,  #123456)
        .word   000021          ; 000C; com (r3)+    (#123456) 
        .word   000031          ; N00C; inc (r3)+    (#123456) keep C!
        .word   000031          ; N00C; dec (r3)+    (#123456) keep C!
        .word   000021          ; 000C; neg (r3)+    (#123456) 
        .word   000030          ; N000; tst (r3)+    (#123456)
        .word   000023          ; 00VC; ror (r3)+    (#100201)
        .word   000031          ; N00C; ror (r3)+    (#002201)
        .word   000023          ; 00VC; rol (r3)+    (#100200)
        .word   000020          ; 0000; asr (r3)+    (#200)   
        .word   000032          ; N0V0; asr (r3)+    (#100200)   
        .word   000020          ; 0000; asl (r3)+    (#200)   
        .word   000023          ; 00VC; asl (r3)+    (#100200)   
        .word   000021          ; 000C; add r1,(r3)+ (#4711, ,#177000)
        .word   000020          ; 0000; adc (r3)+    (#200)
        .word   000031          ; N00C; sub r1,(r3)+ (#4711,  #4701)
        .word   000020          ; 0000; sbc (r3)+    (#200)
        .word   000030          ; N000; swab (r3)+   (#111000)
        .word   000030          ; N000; sxt (r3)+    (#111111 with N=1)
        .word   000020          ; 0000; xor r1,(r3)+ (#4711,   #070707)
        .word   000024          ; 0Z00; sxt (r3)+    (#111111 with N=0)
}

rw11::asmrun  $cpu sym  r0 0 \
                        r1 0004711 \
                        r2 0123456 \
                        r3 $sym(data) \
                        r4 $sym(chkdat) \
                        r5 $sym(chkcc) \
                        sp $sym(stack) \
                        pc $sym(start) \
                        ps 020
rw11::asmwait $cpu sym 
rw11::asmtreg $cpu  r1 0004711 \
                    r2 0123456 \
                    r3 [expr $sym(data)+2*31] \
                    r4 [expr $sym(chkdat)+2*31] \
                    r5 [expr $sym(chkcc)+2*31] \
                    sp $sym(stack)
;
# -- Section B ---------------------------------------------------------------
rlc log "  Byte instructions -----------------------------------------"
# derived from tb_pdp11core_stim.dat code 25
#   r3  points to data, each instruction reads or modifies one value
#   r4  points to check data, the values after instruction
#   r5  points to check psw, the psw values after instruction

$cpu ldasm -lst lst -sym sym {
        .include        |lib/defs_cpu.mac|
        .include        |lib/vec_cpucatch.mac|
;
; setup bpt vector
        . = 000014
        .word   vh.bpt
        .word   0
;
        . = 1000
stack:
;
; bpt vector handler
vh.bpt: cmpb    -1(r3),(r4)+    ; check modified data
        beq     1$
        halt
1$:     cmp     2(sp),(r5)+     ; check psw saved on stack
        beq     2$
        halt
2$:     rtt                     ; ensure next instruction is executed

; main code
start:  movb    r1,(r3)+        ; (#123,  #333)
        cmpb    r1,(r3)+        ; (#123,  #333)
        cmpb    r2,(r3)+        ; (#321,  #111)
        cmpb    r1,(r3)+        ; (#123,  #123)
        clrb    (r3)+           ; (#333)
        bitb    r1,(r3)+        ; (#123,  #11)
        bitb    r1,(r3)+        ; (#123,  #44)
        bicb    r1,(r3)+        ; (#123,  #333)   
        bisb    r1,(r3)+        ; (#123,  #111)   
        comb    (r3)+           ; (#321)
        incb    (r3)+           ; (#321)
        decb    (r3)+           ; (#321)
        negb    (r3)+           ; (#321)
        tstb    (r3)+           ; (#321)
        rorb    (r3)+           ; (#201)   Cin=0; Cout=1
        rorb    (r3)+           ; (#021)   Cin=1; Cout=1
        rolb    (r3)+           ; (#210)   Cin=1; Cout=1
        asrb    (r3)+           ; (#020)
        asrb    (r3)+           ; (#220)
        aslb    (r3)+           ; (#020)
        aslb    (r3)+           ; (#220)
        halt
stop:

; input data for code
data:   .byte   333             ; movb r1,(r3)+  (#123,  #333)
        .byte   333             ; cmpb r1,(r3)+  (#123,  #333)
        .byte   111             ; cmpb r2,(r3)+  (#321,  #111)
        .byte   123             ; cmpb r1,(r3)+  (#123,  #123)
        .byte   333             ; clrb (r3)+     (#333)
        .byte   011             ; bitb r1,(r3)+  (#123,  #11)
        .byte   044             ; bitb r1,(r3)+  (#123,  #44)
        .byte   333             ; bicb r1,(r3)+  (#123,  #333)   
        .byte   111             ; bisb r1,(r3)+  (#123,  #111)   
        .byte   321             ; comb (r3)+     (#321)
        .byte   321             ; incb (r3)+     (#321)
        .byte   321             ; decb (r3)+     (#321)
        .byte   321             ; negb (r3)+     (#321)
        .byte   321             ; tstb (r3)+     (#321)
        .byte   201             ; rorb (r3)+     (#201)   Cin=0; Cout=1
        .byte   021             ; rorb (r3)+     (#021)   Cin=1; Cout=1
        .byte   210             ; rolb (r3)+     (#210)   Cin=1; Cout=1
        .byte   020             ; asrb (r3)+     (#020)
        .byte   220             ; asrb (r3)+     (#220)
        .byte   020             ; aslb (r3)+     (#020)
        .byte   220             ; aslb (r3)+     (#220)
        .even
;
; data check, values after instruction
chkdat: .byte   123             ; movb r1,(r3)+  (#123,  #333)
        .byte   333             ; cmpb r1,(r3)+  (#123,  #333)
        .byte   111             ; cmpb r2,(r3)+  (#321,  #111)
        .byte   123             ; cmpb r1,(r3)+  (#123,  #123)
        .byte   000             ; clrb (r3)+     (#333)
        .byte   011             ; bitb r1,(r3)+  (#123,  #11)
        .byte   044             ; bitb r1,(r3)+  (#123,  #44)
        .byte   210             ; bicb r1,(r3)+  (#123,  #333)   
        .byte   133             ; bisb r1,(r3)+  (#123,  #111)   
        .byte   056             ; comb (r3)+     (#321)
        .byte   322             ; incb (r3)+     (#321)
        .byte   320             ; decb (r3)+     (#321)
        .byte   057             ; negb (r3)+     (#321)
        .byte   321             ; tstb (r3)+     (#321)
        .byte   100             ; rorb (r3)+     (#201)   Cin=0; Cout=1
        .byte   210             ; rorb (r3)+     (#021)   Cin=1; Cout=1
        .byte   021             ; rolb (r3)+     (#210)   Cin=1; Cout=1
        .byte   010             ; asrb (r3)+     (#020)
        .byte   310             ; asrb (r3)+     (#220)
        .byte   040             ; aslb (r3)+     (#020)
        .byte   040             ; aslb (r3)+     (#220)
        .even
;
; psw check, condition codes after instruction (Note: T bit always set !)
chkcc:
        .word   000020          ; 0000; movb r1,(r3)+ (#123, #333)
        .word   000021          ; 000C; cmpb r1,(r3)+ (#123, #333)
        .word   000030          ; N000; cmpb r1,(r3)+ (#321, #111)  
        .word   000024          ; 0Z00; cmpb r1,(r3)+ (#123, #123)  
        .word   000024          ; 0Z00; clrb (r3)+    (#333)
        .word   000020          ; 0000; bitb r1,(r3)+ (#123, #11)    
        .word   000024          ; 0Z00; bitb r1,(r3)+ (#123, #44)    
        .word   000030          ; N000; bicb r1,(r3)+ (#123, #333)
        .word   000020          ; 0000; bisb r1,(r3)+ (#123, #111)
        .word   000021          ; 000C; comb (r3)+    (#321) 
        .word   000031          ; N00C; incb (r3)+    (#321) keep C!
        .word   000031          ; N00C; decb (r3)+    (#321) keep C!
        .word   000021          ; 000C; negb (r3)+    (#321) 
        .word   000030          ; N000; tstb (r3)+    (#321)
        .word   000023          ; 00VC; rorb (r3)+    (#201)
        .word   000031          ; N00C; rorb (r3)+    (#021)
        .word   000023          ; 00VC; rolb (r3)+    (#210)
        .word   000020          ; 0000; asrb (r3)+    (#020)   
        .word   000032          ; N0V0; asrb (r3)+    (#220)   
        .word   000020          ; 0000; aslb (r3)+    (#020)   
        .word   000023          ; 00VC; aslb (r3)+    (#220)   
}

rw11::asmrun  $cpu sym  r0 0 \
                        r1 0000123 \
                        r2 0000321 \
                        r3 $sym(data) \
                        r4 $sym(chkdat) \
                        r5 $sym(chkcc) \
                        sp $sym(stack) \
                        pc $sym(start) \
                        ps 020
rw11::asmwait $cpu sym 
rw11::asmtreg $cpu  r1 0000123 \
                    r2 0000321 \
                    r3 [expr $sym(data)+1*21] \
                    r4 [expr $sym(chkdat)+1*21] \
                    r5 [expr $sym(chkcc)+2*21] \
                    sp $sym(stack)
