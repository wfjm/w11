# $Id: test_pcnt_codes.tcl 1053 2018-10-06 20:34:52Z mueller $
#
# Copyright 2018- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
# License disclaimer see License.txt in $RETROBASE directory
#
# Revision History:
# Date         Rev Version  Comment
# 2018-10-06  1053   1.0    Initial version
#
# Test perf counter functionality with test codes

# ----------------------------------------------------------------------------
rlc log "test_pcnt_codes: test counters --------------------------------------"

if {[$cpu get haspcnt] == 0} {
  rlc log "  test_pcnt_regs-W: no pcnt unit found, test aborted"
  return
}

# define tmpproc for execute test
proc tmpproc_dotest {cpu code args} {
  # compile and load code
  $cpu cp -creset
  $cpu ldasm -lst lst -sym sym $code

  # clear and start dmpcnt
  $cpu cp \
    -wreg pc.cntl [regbld rw11::PC_CNTL {func "CLR"}] \
    -wreg pc.cntl [regbld rw11::PC_CNTL {func "STA"}] 
  
  # run code
  rw11::asmrun  $cpu sym
  rw11::asmwait $cpu sym

  # determine pcnt index range to read
  set imin 31
  set imax  0
  foreach {nam val} $args {
    if {! [info exists rw11::pcnt_cindex($nam)]} {
      rlc log "FAIL: invalid counter name '$nam'"
      rlc errcnt -inc
      return
    }
    set i $rw11::pcnt_cindex($nam)
    set imin [expr {min($imin,$i)}]
    set imax [expr {max($imax,$i)}]
  }
  set nwrd [expr {2*($imax-$imin+1)}]
  if {$nwrd <= 0} {
    rlc log "FAIL: no counters to inspect"
    rlc errcnt -inc
    return
  }
    
  # stop dmpcnt and read counters
  $cpu cp \
    -wreg pc.cntl [regbld rw11::PC_CNTL {func "STO"}] \
    -wreg pc.cntl [regbldkv rw11::PC_CNTL func "LOA" caddr $imin ainc 1] \
    -rreg pc.stat -edata [regbldkv rw11::PC_STAT caddr $imin waddr 0 ainc 1] \
    -rblk pc.data $nwrd pcnt

  ## puts [rw11::pc_printraw]
  
  # inspect counters
  foreach {nam exp} $args {
    set i0 [expr {2*($rw11::pcnt_cindex($nam)-$imin)}]
    set i1 [expr {$i0+1}]
    set v [expr {[lindex $pcnt $i0] + 65536.*[lindex $pcnt $i1]}]
    if {$exp >= 0} {
      if {$v != $exp} {
        rlc log -bare \
          [format "FAIL: $nam expect == $exp, found %1.0f" $v]
        rlc errcnt -inc
      }
    } else {
      if {$v <= -$exp} {
        rlc log -bare \
          [format "FAIL: $nam expect >= %d, found %1.0f" [expr {-$exp}] $v]
        rlc errcnt -inc
      }
    }
  }
}

# -- Section A ---------------------------------------------------------------
rlc log "  A: plain kernel mode codes---------------------------------"

rlc log "    A1: plain sob loop ---------------------------------"
set code {
        . = 1000
stack:  
start:  mov     #32.,r0
1$:     sob     r0,1$
        halt
stop:   
}

# cpu_idec:  34 = 32(sob) + 2(mov+halt)
# ca_rd:     35 = 2(mov) + 32(sob) + 1(halt)
tmpproc_dotest $cpu $code \
  cpu_km_prix   0 \
  cpu_km_pri0  -1 \
  cpu_km_wait   0 \
  cpu_sm        0 \
  cpu_um        0 \
  cpu_idec     34 \
  cpu_vfetch    0 \
  cpu_irupt     0 \
  cpu_pcload   31 \
  ca_rd        35 \
  ca_wr         0 \
  ca_rdhit     35 \
  ca_wrhit      0 \
  ca_rdmem      0 \
  ca_wrmem      0

rlc log "    A2: sob + inc R loop -------------------------------"
set code {
        . = 1000
stack:  
start:  mov     #32.,r0
        clr     r1
1$:     inc     r1
        sob     r0,1$
        halt
stop:   
}

# cpu_idec:  67 = 64(inc+sob) + 2(mov+clr+halt)
# ca_rd:     68 = 3(mov+clr) + 64(inc+sob) + 1(halt)
tmpproc_dotest $cpu $code \
  cpu_km_prix   0 \
  cpu_km_pri0  -1 \
  cpu_km_wait   0 \
  cpu_sm        0 \
  cpu_um        0 \
  cpu_idec     67 \
  cpu_pcload   31 \
  cpu_vfetch    0 \
  cpu_irupt     0 \
  ca_rd        68 \
  ca_wr         0 \
  ca_rdhit     68 \
  ca_wrhit      0 \
  ca_rdmem      0 \
  ca_wrmem      0

rlc log "    A3: sob + inc mem loop -----------------------------"
set code {
        . = 1000
stack:  
start:  mov     #32.,r0
        clr     cnt
1$:     inc     cnt
        sob     r0,1$
        halt
stop:   
cnt:    .word   0
}

# cpu_idec:  67 = 64(inc+sob) + 2(mov+clr+halt)
# ca_rd:    133 = 4(mov+clr) + 128(inc+sob) + 1(halt)
tmpproc_dotest $cpu $code \
  cpu_km_prix   0 \
  cpu_km_pri0  -1 \
  cpu_km_wait   0 \
  cpu_sm        0 \
  cpu_um        0 \
  cpu_idec     67 \
  cpu_pcload   31 \
  cpu_vfetch    0 \
  cpu_irupt     0 \
  ca_rd       133 \
  ca_wr        33 \
  ca_rdhit    133 \
  ca_wrhit     33 \
  ca_rdmem      0 \
  ca_wrmem     33

rlc log "    A4: dec+bne+inc @#ibus loop (test ibus access) -----"
# use usr d page addr register (16 bit read/write) as easy ibus target
set code {
        .include        |lib/defs_mmu.mac|
        . = 1000
stack:  
start:  mov     #32.,r0
        clr     @#udpar
1$:     inc     @#udpar
        dec     r0
        bne     1$
        halt
stop:   
cnt:    .word   0
}

# cpu_idec:  99 = 96(inc+dec+bne) + 3(mov+clr+halt)
# ca_rd:    101 = 4(mov+clr) + 128(inc+dec+bne) + 1(halt)
tmpproc_dotest $cpu $code \
  cpu_km_prix   0 \
  cpu_km_pri0  -1 \
  cpu_km_wait   0 \
  cpu_sm        0 \
  cpu_um        0 \
  cpu_idec     99 \
  cpu_pcload   31 \
  cpu_vfetch    0 \
  cpu_irupt     0 \
  ca_rd       133 \
  ca_wr         0 \
  ca_rdhit    133 \
  ca_wrhit      0 \
  ca_rdmem      0 \
  ca_wrmem      0 \
  ib_rd        32 \
  ib_wr        33

# -- Section B ---------------------------------------------------------------
rlc log "  B: test kern pri>0, super and user mode -------------------"

rlc log "    B1: kernel pri > 0 ---------------------------------"
set code {
        .include        |lib/defs_cpu.mac|
        . = 1000
stack:  
start:  mov     #cp.pr7,@#cp.psw
        nop
        nop
        nop
        nop
        mov     #cp.pr0,@#cp.psw
        halt
stop:   
}

tmpproc_dotest $cpu $code \
  cpu_km_prix  -1 \
  cpu_km_pri0  -4 \
  cpu_km_wait   0 \
  cpu_sm        0 \
  cpu_um        0 \
  cpu_idec      7 \
  cpu_vfetch    0 \
  cpu_irupt     0 \
  cpu_pcload    0 \
  ca_rd        11 \
  ca_wr         0 \
  ca_rdhit     11 \
  ca_wrhit      0 \
  ca_rdmem      0 \
  ca_wrmem      0

rlc log "    B2: supervisor mode --------------------------------"
set code {
        .include        |lib/defs_cpu.mac|
        . = 1000
stack:  
start:  mov     #cp.cms,@#cp.psw
        nop
        nop
        nop
        nop
        mov     #cp.pr0,@#cp.psw
        halt
stop:   
}

tmpproc_dotest $cpu $code \
  cpu_km_prix   0 \
  cpu_km_pri0  -1 \
  cpu_km_wait   0 \
  cpu_sm       -4 \
  cpu_um        0 \
  cpu_idec      7 \
  cpu_vfetch    0 \
  cpu_irupt     0 \
  cpu_pcload    0 \
  ca_rd        11 \
  ca_wr         0 \
  ca_rdhit     11 \
  ca_wrhit      0 \
  ca_rdmem      0 \
  ca_wrmem      0

rlc log "    B3: user mode --------------------------------------"
set code {
        .include        |lib/defs_cpu.mac|
        . = 1000
stack:  
start:  mov     #cp.cmu,@#cp.psw
        nop
        nop
        nop
        nop
        mov     #cp.pr0,@#cp.psw
        halt
stop:   
}

tmpproc_dotest $cpu $code \
  cpu_km_prix   0 \
  cpu_km_pri0  -1 \
  cpu_km_wait   0 \
  cpu_sm        0 \
  cpu_um       -4 \
  cpu_idec      7 \
  cpu_vfetch    0 \
  cpu_irupt     0 \
  cpu_pcload    0 \
  ca_rd        11 \
  ca_wr         0 \
  ca_rdhit     11 \
  ca_wrhit      0 \
  ca_rdmem      0 \
  ca_wrmem      0

# -- Section C ---------------------------------------------------------------
rlc log "  C: test vector fetch --------------------------------------"

rlc log "    C1: vector via trap instruction --------------------"
set code {
        .include        |lib/vec_cpucatch.mac|
        . = 1000
stack:  
start:  mov     #vh.trp,@#v..trp
        mov     #vh.emt,@#v..emt
        clr     r0
        trap    1
        emt     1
        trap    2
        emt     2
        halt
stop:

vh.trp: rti

vh.emt: inc     r0
        rti
}

# cpu_idec:  14 = 8(main) +2*1(trap) + 2*2(emt)
# ca_rd:     34 = 14+4(code) + 4*2(trap+emt) + 4*2(rti)
# ca_wr:     34 = 2(code) + 4*2(trap+emt)
# ca_pcload:  8 = 4(trap+emt) + 4(rti)
tmpproc_dotest $cpu $code \
  cpu_km_prix   0 \
  cpu_km_pri0  -1 \
  cpu_km_wait   0 \
  cpu_sm        0 \
  cpu_um        0 \
  cpu_idec     14 \
  cpu_vfetch    4 \
  cpu_irupt     0 \
  cpu_pcload    8 \
  ca_rd        34 \
  ca_wr        10 \
  ca_rdhit     34 \
  ca_wrhit     10 \
  ca_rdmem      0 \
  ca_wrmem     10
