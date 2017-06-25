# $Id: test_w11a_mem70.tcl 916 2017-06-25 13:30:07Z mueller $
#
# Copyright 2017- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
# License disclaimer see License.txt in $RETROBASE directory
#
# Revision History:
# Date         Rev Version  Comment
# 2017-06-25   916   1.0    Initial version
#
# Test 11/70 memory system registers and cache
#   adopt from old pdpcp style stim files
#     tb/tb_w11a_mem70.dat       --> tests 1-3
#     tb/tb_w11a_mem70_n2.dat    --> test 4 (size adaptive now)
#     tb/tb_w11a_mem70_s3.dat    /

# ----------------------------------------------------------------------------
rlc log "test_w11a_mem70: Test 11/70 memory system and cache ------"

# --------------------------------------------------------------------
rlc log "  access all 11/70 memory system registers"

# loaddr,hiaddr,syserr,cntrl,maint,hm and losize,hisize are contiguous
$cpu cp -wal loaddr \
        -rmi -edata 000000 \
        -rmi -edata 000000 \
        -rmi -edata 000000 \
        -rmi -edata 000000 \
        -rmi -edata 000000 \
        -rmi \
        -wal losize \
        -rmi losize \
        -rmi -edata 000000

set msize [expr {($losize+1) * 64}]
rlc log [format "  --> detected memory size: %4d kB" [expr {$msize/1024}]]

# --------------------------------------------------------------------
rlc log "  Test 1: cache basic rmiss test - is data from mem on rmiss ?"
# - the new configurable cache can be as big as 128 kByte
# - the hit/miss tests below will work for up maximal cache size and use
#   22bit mode access and two areas 128 kByte appart
#       wah/wal    00/0000xx  or 000000xx
#       wah/wal    02/0000xx  or 004000xx
#   write two areas
$cpu cp -wa  00000000 -p22 \
        -bwm {000000 000002 000004 000006 000010 000012 000014 000016} \
        -wa  00400000 -p22 \
        -bwm {020000 020002 020004 020006 020010 020012 020014 020016}
#   read  two areas, second read will definitively miss
$cpu cp -wa  00000000 -p22 \
        -brm 8 -edata {000000 000002 000004 000006 000010 000012 000014 000016} \
        -wa  00400000 -p22 \
        -brm 8 -edata {020000 020002 020004 020006 020010 020012 020014 020016}

# --------------------------------------------------------------------
rlc log "  Test 2: Hit/Miss register"
# use data written in previous test
# 7 read on same location -> 6 hits --> hm 111 111
$cpu cp -wa  00400004 -p22 \
        -rm  -edata 020004 \
        -rm  -edata 020004 \
        -rm  -edata 020004 \
        -rm  -edata 020004 \
        -rm  -edata 020004 \
        -rm  -edata 020004 \
        -rm  -edata 020004 \
        -wal hm \
        -rm  -edata 000077
# 1 read on conflicting address -> 1 miss    --> hm 111 110
# 1 read on next word in line   -> 1 hit     --> hm 111 101
# read next 4 words -> alternating miss/hit  --> hm 010 101
$cpu cp -wa  00000004 -p22 \
        -rm  -edata 000004 \
        -wal hm            \
        -rm  -edata 000076 \
        -wa  00000006 -p22 \
        -rm  -edata 000006 \
        -wal hm            \
        -rm  -edata 000075 \
        -wa  00000010 -p22 \
        -rmi -edata 000010 \
        -rmi -edata 000012 \
        -rmi -edata 000014 \
        -rmi -edata 000016 \
        -wal hm            \
        -rm  -edata 000025
# write next 4 words -> 4 miss   --> hm 010 000
# re-read these 4 words -> 4 hit --> hm 001 111
$cpu cp -wa  00000020 -p22 \
        -bwm {000020 000022 000024 000026} \
        -wal hm            \
        -rm  -edata 000020 \
        -wa  00000020 -p22 \
        -brm 4 -edata {000020 000022 000024 000026} \
        -wal hm            \
        -rm  -edata 000017

# --------------------------------------------------------------------
rlc log "  Test 3: Control Register: test force miss bits"
# use data written in previous tests
# set fmiss bits in cntrl
# re-read last 4 words -> 4 forced misses --> hm 110 000
# clear fmiss bits again
$cpu cp -wal cntrl \
        -wm [regbld rw11::CNTRL {fmiss 3}] \
        -wa  00000020 -p22 \
        -brm 4 -edata {000020 000022 000024 000026} \
        -wal hm            \
        -rm  -edata 000060 \
        -wal cntrl \
        -wm  0

# --------------------------------------------------------------------
rlc log "  Test 4: test full memory (touch (4-7)*2 sections of 16 words"
# determine memory size in 2^n steps; chunck size is 1/4
set msize2 [expr {2*1024*1024}]
while {$msize < $msize2} {
  set msize2 [expr {$msize2 >> 1}]
}
set mstep [expr {$msize2 >> 2}]
set nstep [expr {int($msize / $mstep)}]
rlc log [format "  --> %d chuncks with %4d kB" $nstep [expr {$mstep/1024}]]

# write data
set maddrlow   0
set maddrhigh  [expr {$mstep - 32}]
set clist {}

for {set i 0} {$i < $nstep} {incr i} {
  set vlist {}
  for {set j 0} {$j < 16} {incr j} { lappend vlist [expr {($i<<9) + ($j<<3)}] }
  lappend clist -wa $maddrlow  -p22
  lappend clist -bwm $vlist
  set vlist {}
  for {set j 0} {$j < 16} {incr j} { lappend vlist [expr {($i<<9) + ($j<<3)+1}]} 
  lappend clist -wa $maddrhigh -p22
  lappend clist -bwm $vlist
  incr maddrlow   $mstep
  incr maddrhigh  $mstep
}
$cpu cp {*}$clist

# read data
set maddrlow   0
set maddrhigh  [expr {$mstep - 32}]
set clist {}

for {set i 0} {$i < $nstep} {incr i} {
  set vlist {}
  for {set j 0} {$j < 16} {incr j} { lappend vlist [expr {($i<<9) + ($j<<3)}] }
  lappend clist -wa $maddrlow  -p22
  lappend clist -brm 16 -edata $vlist
  set vlist {}
  for {set j 0} {$j < 16} {incr j} { lappend vlist [expr {($i<<9) + ($j<<3)+1}]} 
  lappend clist -wa $maddrhigh -p22
  lappend clist -brm 16 -edata $vlist
  incr maddrlow   $mstep
  incr maddrhigh  $mstep
}
$cpu cp {*}$clist
