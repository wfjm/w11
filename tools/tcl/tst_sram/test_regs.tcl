# $Id: test_regs.tcl 1074 2018-11-25 21:38:59Z mueller $
#
# Copyright 2016-2018 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
#
# This program is free software; you may redistribute and/or modify it under
# the terms of the GNU General Public License as published by the Free
# Software Foundation, either version 3, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY, without even the implied warranty of MERCHANTABILITY
# or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
# for complete details.
#
#  Revision History:
# Date         Rev Version  Comment
# 2018-11-25  1074   1.2.1  don't reset MEM, only SEQ
# 2017-06-25   917   1.2    17bit support; use sstat(awidth); add isnarrow
# 2016-07-10   785   1.1    add memory test (touch evenly distributed addr)
# 2016-07-09   784   1.0    Initial version (ported from tb_tst_sram_stim.dat)
#

package provide tst_sram 1.0

package require rutiltpp
package require rutil
package require rlink

namespace eval tst_sram {
  #
  # test_regs: Test registers: mdi*,mdo*,maddr*,mcmd,mblk,sblk* 
  #                            and saddr,slim,sblk* 
  #
  proc test_regs {} {
    #
    set errcnt 0
    rlc errcnt -clear
    #
    rlc log "tst_sram::test_regs ---------------------------------------------"
    rlc log "  init: reset SEQ via init, clear sfail ect"
    rlc exec -init sr.mdih 0x0001; # reset SEQ (don't reset MEM !)
    #
    #-------------------------------------------------------------------------
    rlc log "  test 1a: test mdi* ,maddr*"
    rlc exec \
      -wreg sr.mdih    0x5555 \
      -wreg sr.mdil    0xaaaa \
      -wreg sr.maddrh  0x0001 \
      -wreg sr.maddrl  0xcccc \
      -rreg sr.mdih    -edata 0x5555 \
      -rreg sr.mdil    -edata 0xaaaa \
      -rreg sr.maddrh  -edata 0x0001 \
      -rreg sr.maddrl  -edata 0xcccc
    #
    #-------------------------------------------------------------------------
    rlc log "  test 1b: test maddrh range"
    set maddrh_max [expr {[iswide] ? 0x3f : [isnarrow] ? 0x01: 0x03}]
    rlc exec \
      -wreg sr.maddrh  0xffff \
      -rreg sr.maddrh  -edata $maddrh_max
    #
    #-------------------------------------------------------------------------
    rlc log "  test 2: test direct memory write/read via mcmd"
    # write mem(0) = 0xdeadbeaf; mem(1)=a5a55a5a
    rlc exec \
      -wreg sr.maddrh 0x0000 \
      -wreg sr.maddrl 0x0000 \
      -wreg sr.mdih   0xdead \
      -wreg sr.mdil   0xbeaf \
      -wreg sr.mcmd   [regbld tst_sram::MCMD we {be 0xf}] \
      -wreg sr.maddrl 0x0001 \
      -wreg sr.mdih   0xa5a5 \
      -wreg sr.mdil   0x5a5a \
      -wreg sr.mcmd   [regbld tst_sram::MCMD we {be 0xf}]
    # read back
    rlc exec \
      -wreg sr.maddrl 0x0000 \
      -wreg sr.mcmd   [regbld tst_sram::MCMD    {be 0xf}] \
      -rreg sr.mdoh   -edata 0xdead \
      -rreg sr.mdol   -edata 0xbeaf \
      -wreg sr.maddrl 0x0001 \
      -wreg sr.mcmd   [regbld tst_sram::MCMD    {be 0xf}] \
      -rreg sr.mdoh   -edata 0xa5a5 \
      -rreg sr.mdol   -edata 0x5a5a
    # check that mdi* unchanged (value from last write)
    rlc exec \
      -rreg sr.mdih   -edata 0xa5a5 \
      -rreg sr.mdil   -edata 0x5a5a 
    # verify that mcmd write only
    rlc exec -rreg sr.mcmd -estaterr; # expect err on read
    #
    #-------------------------------------------------------------------------
    rlc log "  test 3: test block write/read via mblk"
    # write 8 longwords, check maddrl incremented
    rlc exec \
      -wreg sr.maddrh 0x0000 \
      -wreg sr.maddrl 0x0010 \
      -wblk sr.mblk {0x3020 0x1000 \
                     0x3121 0x1101 \
                     0x3222 0x1202 \
                     0x3323 0x1303 \
                     0x3424 0x1404 \
                     0x3525 0x1505 \
                     0x3626 0x1606 \
                     0x3727 0x1707} \
      -rreg sr.maddrh -edata 0x0000 \
      -rreg sr.maddrl -edata 0x0018
    # read 8 longwords, check maddrl incremented
    rlc exec \
      -wreg sr.maddrh 0x0000 \
      -wreg sr.maddrl 0x0010 \
      -rblk sr.mblk 16 -edata {0x3020 0x1000 \
                               0x3121 0x1101 \
                               0x3222 0x1202 \
                               0x3323 0x1303 \
                               0x3424 0x1404 \
                               0x3525 0x1505 \
                               0x3626 0x1606 \
                               0x3727 0x1707} \
      -rreg sr.maddrh -edata 0x0000 \
      -rreg sr.maddrl -edata 0x0018
    #
    #-------------------------------------------------------------------------
    rlc log "  test 4: mcmd: ld,inc and be functionality"
    # use memory as setup by previous test
    # overwrite bytes 12(0001)=42, 13(0010)=53, 14(0100)=64, 15(1000)=75
    rlc exec \
      -wreg sr.maddrh 0x0003 \
      -wreg sr.maddrl 0x0012 \
      -wreg sr.mdih   0xffff \
      -wreg sr.mdil   0xff42 \
      -wreg sr.mcmd   [regbld tst_sram::MCMD ld inc we {be 0x1} {addrh 0x0}] \
      -wreg sr.mdil   0x53ff \
      -wreg sr.mcmd   [regbld tst_sram::MCMD    inc we {be 0x2} ] \
      -wreg sr.mdih   0xff64 \
      -wreg sr.mdil   0xffff \
      -wreg sr.mcmd   [regbld tst_sram::MCMD    inc we {be 0x4} ] \
      -wreg sr.mdih   0x75ff \
      -wreg sr.mcmd   [regbld tst_sram::MCMD    inc we {be 0x8} ]
    # check load maddrh and increment of maddrl; read back and check
    rlc exec \
      -rreg sr.maddrh -edata 0x0000 \
      -rreg sr.maddrl -edata 0x0016 \
      -wreg sr.maddrl 0x0010 \
      -rblk sr.mblk 16 -edata {0x3020 0x1000 \
                               0x3121 0x1101 \
                               0x3222 0x1242 \
                               0x3323 0x5303 \
                               0x3464 0x1404 \
                               0x7525 0x1505 \
                               0x3626 0x1606 \
                               0x3727 0x1707} 
    #
    #-------------------------------------------------------------------------
    rlc log "  test 5: test saddr,slim,sblk,sblkc,sblkd"
    # write/read saddr/slim
    rlc exec \
      -wreg sr.slim  0x0123 \
      -wreg sr.saddr 0x0345 \
      -rreg sr.slim  -edata 0x0123 \
      -rreg sr.saddr -edata 0x0345
    # sblk write of 8 lines, check saddr incremented
    rlc exec \
      -wreg sr.saddr 0x0000 \
      -wblk sr.sblk {0x0300 0x0200 0x0100 0x0000 \
                     0x0301 0x0201 0x0101 0x0001 \
                     0x0302 0x0202 0x0102 0x0002 \
                     0x0303 0x0203 0x0103 0x0003 \
                     0x0304 0x0204 0x0104 0x0004 \
                     0x0305 0x0205 0x0105 0x0005 \
                     0x0306 0x0206 0x0106 0x0006 \
                     0x0307 0x0207 0x0107 0x0007 } \
      -rreg sr.saddr -edata 0x0008
    # sblk read back
    rlc exec \
      -wreg sr.saddr 0x0000 \
      -rblk sr.sblk 32 -edata {0x0300 0x0200 0x0100 0x0000 \
                               0x0301 0x0201 0x0101 0x0001 \
                               0x0302 0x0202 0x0102 0x0002 \
                               0x0303 0x0203 0x0103 0x0003 \
                               0x0304 0x0204 0x0104 0x0004 \
                               0x0305 0x0205 0x0105 0x0005 \
                               0x0306 0x0206 0x0106 0x0006 \
                               0x0307 0x0207 0x0107 0x0007 } \
      -rreg sr.saddr -edata 0x0008
    # sblkc (over-)write of 4 lines (1-4)
    rlc exec \
      -wreg sr.saddr 0x0001 \
      -wblk sr.sblkc {0x1301 0x1201 \
                      0x1302 0x1202 \
                      0x1303 0x1203 \
                      0x1304 0x1204 } \
      -rreg sr.saddr -edata 0x0005
    # sblkd (over-)write of 4 lines (3-6)
    rlc exec \
      -wreg sr.saddr 0x0003 \
      -wblk sr.sblkd {0x2103 0x2003 \
                      0x2104 0x2004 \
                      0x2105 0x2005 \
                      0x2106 0x2006 } \
      -rreg sr.saddr -edata 0x0007
    # sblk read back of all 8 lines, verify c and d updates
    rlc exec \
      -wreg sr.saddr 0x0000 \
      -rblk sr.sblk 32 -edata {0x0300 0x0200 0x0100 0x0000 \
                               0x1301 0x1201 0x0101 0x0001 \
                               0x1302 0x1202 0x0102 0x0002 \
                               0x1303 0x1203 0x2103 0x2003 \
                               0x1304 0x1204 0x2104 0x2004 \
                               0x0305 0x0205 0x2105 0x2005 \
                               0x0306 0x0206 0x2106 0x2006 \
                               0x0307 0x0207 0x0107 0x0007} \
      -rreg sr.saddr -edata 0x0008
    # sblkc read back of all 8 lines
    rlc exec \
      -wreg sr.saddr 0x0000 \
      -rblk sr.sblkc 16 -edata {0x0300 0x0200 \
                                0x1301 0x1201 \
                                0x1302 0x1202 \
                                0x1303 0x1203 \
                                0x1304 0x1204 \
                                0x0305 0x0205 \
                                0x0306 0x0206 \
                                0x0307 0x0207} \
      -rreg sr.saddr -edata 0x0008
    # sblkd read back of all 8 lines
    rlc exec \
      -wreg sr.saddr 0x0000 \
      -rblk sr.sblkd 16 -edata {0x0100 0x0000 \
                                0x0101 0x0001 \
                                0x0102 0x0002 \
                                0x2103 0x2003 \
                                0x2104 0x2004 \
                                0x2105 0x2005 \
                                0x2106 0x2006 \
                                0x0107 0x0007} \
      -rreg sr.saddr -edata 0x0008
    #
    #-------------------------------------------------------------------------
    rlc log "  test 5: test sstat bits"
    set sm [rutil::com16 [regbld tst_sram::SSTAT {awidth -1}]]
    rlc exec \
      -wreg sr.sstat 0 \
      -rreg sr.sstat -edata 0 $sm \
      -wreg sr.sstat        [regbld tst_sram::SSTAT veri ] \
      -rreg sr.sstat -edata [regbld tst_sram::SSTAT veri ] $sm \
      -wreg sr.sstat        [regbld tst_sram::SSTAT xora ] \
      -rreg sr.sstat -edata [regbld tst_sram::SSTAT xora ] $sm \
      -wreg sr.sstat        [regbld tst_sram::SSTAT xord ] \
      -rreg sr.sstat -edata [regbld tst_sram::SSTAT xord ] $sm \
      -wreg sr.sstat        [regbld tst_sram::SSTAT loop ] \
      -rreg sr.sstat -edata [regbld tst_sram::SSTAT loop ] $sm \
      -wreg sr.sstat        [regbld tst_sram::SSTAT wloop] \
      -rreg sr.sstat -edata [regbld tst_sram::SSTAT wloop] $sm \
      -wreg sr.sstat        [regbld tst_sram::SSTAT wswap] \
      -rreg sr.sstat -edata [regbld tst_sram::SSTAT wswap] $sm
    #
    #-------------------------------------------------------------------------
    rlc log "  test 6: test memory (touch 5(+5) evenly spaced addresses)"
    # writes
    if {[isnarrow]} {
      # 17bit: 0x000000 0x004001 0x010002 0x014003 0x01ffff
      rlc exec \
        -wreg sr.mdih   0x5500 \
        -wreg sr.mdil   0xaa00 \
        -wreg sr.maddrl 0x0000 \
        -wreg sr.mcmd   [regbld tst_sram::MCMD ld inc we {be 0xf} {addrh 0x00}] \
        -wreg sr.mdih   0x5501 \
        -wreg sr.mdil   0xaa01 \
        -wreg sr.maddrl 0x4001 \
        -wreg sr.mcmd   [regbld tst_sram::MCMD ld inc we {be 0xf} {addrh 0x00}] \
        -wreg sr.mdih   0x5502 \
        -wreg sr.mdil   0xaa02 \
        -wreg sr.maddrl 0x0002 \
        -wreg sr.mcmd   [regbld tst_sram::MCMD ld inc we {be 0xf} {addrh 0x01}] \
        -wreg sr.mdih   0x5503 \
        -wreg sr.mdil   0xaa03 \
        -wreg sr.maddrl 0x4003 \
        -wreg sr.mcmd   [regbld tst_sram::MCMD ld inc we {be 0xf} {addrh 0x01}] \
        -wreg sr.mdih   0x5504 \
        -wreg sr.mdil   0xaa04 \
        -wreg sr.maddrl 0xffff \
        -wreg sr.mcmd   [regbld tst_sram::MCMD ld     we {be 0xf} {addrh 0x01}]
    } else {
      # 18bit: 0x000000 0x010001 0x020002 0x030003 0x03ffff
      rlc exec \
        -wreg sr.mdih   0x5500 \
        -wreg sr.mdil   0xaa00 \
        -wreg sr.maddrl 0x0000 \
        -wreg sr.mcmd   [regbld tst_sram::MCMD ld inc we {be 0xf} {addrh 0x00}] \
        -wreg sr.mdih   0x5501 \
        -wreg sr.mdil   0xaa01 \
        -wreg sr.mcmd   [regbld tst_sram::MCMD ld inc we {be 0xf} {addrh 0x01}] \
        -wreg sr.mdih   0x5502 \
        -wreg sr.mdil   0xaa02 \
        -wreg sr.mcmd   [regbld tst_sram::MCMD ld inc we {be 0xf} {addrh 0x02}] \
        -wreg sr.mdih   0x5503 \
        -wreg sr.mdil   0xaa03 \
        -wreg sr.mcmd   [regbld tst_sram::MCMD ld inc we {be 0xf} {addrh 0x03}] \
        -rreg sr.maddrl -edata 0x0004 \
        -wreg sr.mdih   0x5504 \
        -wreg sr.mdil   0xaa04 \
        -wreg sr.maddrl 0xffff \
        -wreg sr.mcmd   [regbld tst_sram::MCMD ld     we {be 0xf} {addrh 0x03}]
    }
    # 22bit: 0x040000 0x100001 0x200002 0x300003 0x3fffff
    if {[iswide]} {
    rlc exec \
      -wreg sr.mdih   0xa500 \
      -wreg sr.mdil   0x5a00 \
      -wreg sr.maddrl 0x0000 \
      -wreg sr.mcmd   [regbld tst_sram::MCMD ld inc we {be 0xf} {addrh 0x04}] \
      -wreg sr.mdih   0x5a01 \
      -wreg sr.mdil   0x5a01 \
      -wreg sr.mcmd   [regbld tst_sram::MCMD ld inc we {be 0xf} {addrh 0x10}] \
      -wreg sr.mdih   0x5a02 \
      -wreg sr.mdil   0x5a02 \
      -wreg sr.mcmd   [regbld tst_sram::MCMD ld inc we {be 0xf} {addrh 0x20}] \
      -wreg sr.mdih   0x5a03 \
      -wreg sr.mdil   0x5a03 \
      -wreg sr.mcmd   [regbld tst_sram::MCMD ld inc we {be 0xf} {addrh 0x30}] \
      -rreg sr.maddrl -edata 0x0004 \
      -wreg sr.mdih   0x5a04 \
      -wreg sr.mdil   0x5a04 \
      -wreg sr.maddrl 0xffff \
      -wreg sr.mcmd   [regbld tst_sram::MCMD ld     we {be 0xf} {addrh 0x3f}]
    }
    # reads
    if {[isnarrow]} {
      rlc exec \
        -wreg sr.maddrl 0x0000 \
        -wreg sr.mcmd   [regbld tst_sram::MCMD ld inc    {be 0xf} {addrh 0x00}] \
        -rreg sr.mdoh   -edata 0x5500 \
        -rreg sr.mdol   -edata 0xaa00 \
        -wreg sr.maddrl 0x4001 \
        -wreg sr.mcmd   [regbld tst_sram::MCMD ld inc    {be 0xf} {addrh 0x00}] \
        -rreg sr.mdoh   -edata 0x5501 \
        -rreg sr.mdol   -edata 0xaa01 \
        -wreg sr.maddrl 0x0002 \
        -wreg sr.mcmd   [regbld tst_sram::MCMD ld inc    {be 0xf} {addrh 0x01}] \
        -rreg sr.mdoh   -edata 0x5502 \
        -rreg sr.mdol   -edata 0xaa02 \
        -wreg sr.maddrl 0x4003 \
        -wreg sr.mcmd   [regbld tst_sram::MCMD ld inc    {be 0xf} {addrh 0x01}] \
        -rreg sr.mdoh   -edata 0x5503 \
        -rreg sr.mdol   -edata 0xaa03 \
        -wreg sr.maddrl 0xffff \
        -wreg sr.mcmd   [regbld tst_sram::MCMD ld        {be 0xf} {addrh 0x01}] \
        -rreg sr.mdoh   -edata 0x5504 \
        -rreg sr.mdol   -edata 0xaa04
    } else {
      rlc exec \
        -wreg sr.maddrl 0x0000 \
        -wreg sr.mcmd   [regbld tst_sram::MCMD ld inc    {be 0xf} {addrh 0x00}] \
        -rreg sr.mdoh   -edata 0x5500 \
        -rreg sr.mdol   -edata 0xaa00 \
        -wreg sr.mcmd   [regbld tst_sram::MCMD ld inc    {be 0xf} {addrh 0x01}] \
        -rreg sr.mdoh   -edata 0x5501 \
        -rreg sr.mdol   -edata 0xaa01 \
        -wreg sr.mcmd   [regbld tst_sram::MCMD ld inc    {be 0xf} {addrh 0x02}] \
        -rreg sr.mdoh   -edata 0x5502 \
        -rreg sr.mdol   -edata 0xaa02 \
        -wreg sr.mcmd   [regbld tst_sram::MCMD ld inc    {be 0xf} {addrh 0x03}] \
        -rreg sr.mdoh   -edata 0x5503 \
        -rreg sr.mdol   -edata 0xaa03 \
        -rreg sr.maddrl -edata 0x0004 \
        -wreg sr.maddrl 0xffff \
        -wreg sr.mcmd   [regbld tst_sram::MCMD ld        {be 0xf} {addrh 0x03}] \
        -rreg sr.mdoh   -edata 0x5504 \
        -rreg sr.mdol   -edata 0xaa04
    }
    if {[iswide]} {
    rlc exec \
      -wreg sr.maddrl 0x0000 \
      -wreg sr.mcmd   [regbld tst_sram::MCMD ld inc    {be 0xf} {addrh 0x04}] \
      -rreg sr.mdoh   -edata 0xa500 \
      -rreg sr.mdol   -edata 0x5a00 \
      -wreg sr.mcmd   [regbld tst_sram::MCMD ld inc    {be 0xf} {addrh 0x10}] \
      -rreg sr.mdoh   -edata 0x5a01 \
      -rreg sr.mdol   -edata 0x5a01 \
      -wreg sr.mcmd   [regbld tst_sram::MCMD ld inc    {be 0xf} {addrh 0x20}] \
      -rreg sr.mdoh   -edata 0x5a02 \
      -rreg sr.mdol   -edata 0x5a02 \
      -wreg sr.mcmd   [regbld tst_sram::MCMD ld inc    {be 0xf} {addrh 0x30}] \
      -rreg sr.mdoh   -edata 0x5a03 \
      -rreg sr.mdol   -edata 0x5a03 \
      -rreg sr.maddrl -edata 0x0004 \
      -wreg sr.maddrl 0xffff \
      -wreg sr.mcmd   [regbld tst_sram::MCMD ld        {be 0xf} {addrh 0x3f}] \
      -rreg sr.mdoh   -edata 0x5a04 \
      -rreg sr.mdol   -edata 0x5a04
    }
    #
    #-------------------------------------------------------------------------
    incr errcnt [rlc errcnt -clear]
    return $errcnt
  }
}
