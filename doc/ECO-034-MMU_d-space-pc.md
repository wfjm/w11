# ECO-033: D space used instead of I space for some PC specifiers  (2022-09-08)

### Scope
- was in w11a since 2009
- affects: all w11a systems

### Symptom summary
Test 072 of `ekbee1` fails with
```
    D-SPACE ENABLE CIRCUITRY HAS FAILED
    ERROR   AUTOI/D VIRTUAL
    REGISTR REGISTR ADDRESS TESTNO  PC AT ABORT
    100027  000000  060410  000072  060412  
    100027  000027  060416  000072  060422  
```
The test does
```
    060410: tst  (pc)
    060416: cmp  #240,(pc)
```
and expects that these accesses are done to I space.  
They are done to D space instead.

### Analysis
The w11 used D space only for `(pc)+` and `@(pc)+` specifiers.    
The w11a has 4 specifier flows
- srcr: for source read
- dstr: for destination read (in `CMP`, `BIT`, `TST`, ...)
- dstw: for destination write (also read-modify-write)
- dsta: for destination address (in `JSR`, `JMP`)
A code review showed what was OK and what needed a fix
```
s_srcr_def      OK                 mov (pc),r0
s_srcr_inc      OK                 mov #123,r0
s_dstr_def      FIXED              cmp,#123,(pc)
s_dstr_inc      OK                 cmp r0,#123
s_dstw_def      FIXED              mov r0,(pc)    modifies I space code !
s_dstw_inc      FIXED for mode=2   mov r0,#133    modifies I space code !
s_dstw_inc      OK    for mode=3   mov r0,@#lbl
s_dsta_inc      OK                 
```

Note: the 11/70 uses D space for modes 1-5 in the source specifier flow,
and for mode 1-3 in the destination specifier flow.

### Fixes
Add `pispace` modifiers for the `do_memread*` and `do_memwrite*` calls in
pdp11_sequencer.vhd.

### Hindsight
Took 13 years to fix. The fixed address modes are of very little practical
value and are not used in normal code. And certainly used not when running
with kernel D mode enabled.
