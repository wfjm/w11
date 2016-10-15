# $Id: test_seq.tcl 785 2016-07-10 12:22:41Z mueller $
#
# Copyright 2016- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
#
# This program is free software; you may redistribute and/or modify it under
# the terms of the GNU General Public License as published by the Free
# Software Foundation, either version 2, or at your option any later version.
#
# This program is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY, without even the implied warranty of MERCHANTABILITY
# or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
# for complete details.
#
#  Revision History:
# Date         Rev Version  Comment
# 2016-07-10   785   1.1    add wswap and wloop tests
# 2016-07-09   784   1.0    Initial version (ported from tb_tst_sram_stim.dat)
#

package provide tst_sram 1.0

package require rutiltpp
package require rutil
package require rlink

namespace eval tst_sram {
  #
  # test_seq_srum: helper: run sequencer and check status
  #
  proc test_seq_srun {{sstat 0} {tout 10.} {seaddr 0} {sedath 0} {sedatl 0}} {
    variable nscmd
    if {$nscmd == 0} {error "no or empty scmd list loaded"}
    #
    # set slim, sstat and start sequencer
    rlc exec \
      -wreg sr.slim   [expr {$nscmd-1}] \
      -wreg sr.sstat  $sstat \
      -wreg sr.sstart 0 
    # wait for completion
    rlc wtlam $tout
    # harvest attn and check sequencer status
    # also check rlink command status (RB_STAT(1) <= R_REGS.sfail)
    set seqmsk [rutil::com16 [regbld tst_sram::SSTAT wide]]; # ign sstat.wide !
    set stamsk [regbld rlink::STAT {stat -1} rbtout rbnak rberr];

    if {$seaddr == 0} {         # fail=0 --> check saddr
      rlc exec \
        -attn -edata 0x0001 \
        -rreg sr.sstat  -edata $sstat $seqmsk -estat 0 $stamsk \
        -rreg sr.saddr  -edata $nscmd       -estat 0 $stamsk
    } else {                    # fail=1 --> check seaddr
      set sstat_exp [expr {$sstat | [regbld tst_sram::SSTAT fail]}]
      set stabad [regbld rlink::STAT {stat 2}]; # expect status.stat = 0x2
      rlc exec \
        -attn -edata 0x0001 \
        -rreg sr.sstat  -edata $sstat_exp $seqmsk -estat $stabad $stamsk \
        -rreg sr.seaddr -edata $seaddr            -estat $stabad $stamsk \
        -rreg sr.sedath -edata $sedath            -estat $stabad $stamsk \
        -rreg sr.sedatl -edata $sedatl            -estat $stabad $stamsk 
    }
    return ""
  }

  #
  # test_seq_setxor: helper: setup maddr* and mdi*
  #
  proc test_seq_setxor {maddrh maddrl mdih mdil} {
    rlc exec \
      -wreg sr.maddrh $maddrh \
      -wreg sr.maddrl $maddrl \
      -wreg sr.mdih   $mdih   \
      -wreg sr.mdil   $mdil
  }

  #
  # test_seq: Test sequencer, basic 18 bit mode
  #
  proc test_seq {{tout 10.}} {
    variable nscmd
    #
    set errcnt 0
    rlc errcnt -clear
    set sm [rutil::com16 [regbld tst_sram::SSTAT wide]]

    rlink::anena 1;             # enable attn notify

    #
    rlc log "tst_sram::test_seq ----------------------------------------------"
    #
    #-------------------------------------------------------------------------
    rlc log "  test  1: list of write commands"
    # load list of 8 mem write commands
    set clist {}
    lappend clist { 0 w 1111 0x000110 0x70605040};
    lappend clist { 0 w 1111 0x000111 0x71615141};
    lappend clist { 0 w 1111 0x000112 0x72625242};
    lappend clist { 0 w 1111 0x000113 0x73635343};
    lappend clist { 0 w 1111 0x000114 0x74645444};
    lappend clist { 0 w 1111 0x000115 0x75655545};
    lappend clist { 0 w 1111 0x000116 0x76665646};
    lappend clist { 0 w 1111 0x000117 0x77675747};
    scmd_write $clist

    # run sequencer (plain xord=0 xora=0 veri=0)
    test_seq_srun 0 $tout
    # read back 8 longwords
    rlc exec \
      -wreg sr.maddrh 0x0000 \
      -wreg sr.maddrl 0x0110 \
      -wblk sr.mblk {0x7060 0x5040 \
                     0x7161 0x5141 \
                     0x7262 0x5242 \
                     0x7363 0x5343 \
                     0x7464 0x5444 \
                     0x7565 0x5545 \
                     0x7666 0x5646 \
                     0x7767 0x5747}
    #
    #-------------------------------------------------------------------------
    rlc log "  test  2: list of read commands"
    # load list of 8 mem read commands
    set clist {}
    lappend clist { 0 r 1111 0x000110 0xdead0000};
    lappend clist { 0 r 1111 0x000111 0xbeaf1111};
    lappend clist { 0 r 1111 0x000112 0xdead2222};
    lappend clist { 0 r 1111 0x000113 0xbeaf3333};
    lappend clist { 0 r 1111 0x000114 0xdead4444};
    lappend clist { 0 r 1111 0x000115 0xbeaf5555};
    lappend clist { 0 r 1111 0x000116 0xdead6666};
    lappend clist { 0 r 1111 0x000117 0xbeaf7777};
    scmd_write $clist

    # run sequencer (plain xord=0 xora=0 veri=0)
    test_seq_srun 0 $tout
    # read back data part of sequencer
    rlc exec \
      -wreg sr.saddr 0x0000 \
      -rblk sr.sblkd 16 -edata {0x7060 0x5040
                                0x7161 0x5141 \
                                0x7262 0x5242 \
                                0x7363 0x5343 \
                                0x7464 0x5444 \
                                0x7565 0x5545 \
                                0x7666 0x5646 \
                                0x7767 0x5747}
    #
    #-------------------------------------------------------------------------
    rlc log "  test  3: mixed list of writes (some byte wise) and reads"
    # this list modifies the memory left from previous test !
    set clist {}
    lappend clist { 0 w 0001 0x000112 0x00000082};  # wr 12 0001
    lappend clist { 0 w 0010 0x000113 0x00009300};  # wr 13 0010
    lappend clist { 0 r 1111 0x000110 0x00000000};  # rd 10
    lappend clist { 0 w 0100 0x000114 0x00a40000};  # wr 14 0100
    lappend clist { 0 r 1111 0x000111 0x00000000};  # rd 11
    lappend clist { 0 w 1000 0x000115 0xb5000000};  # wr 15 1000
    lappend clist { 0 r 1111 0x000112 0x00000000};  # rd 12
    lappend clist { 0 r 1111 0x000113 0x00000000};  # rd 13
    lappend clist { 0 w 1111 0x000118 0x78685848};  # wr 18
    lappend clist { 0 r 1111 0x000114 0x00000000};  # rd 14
    lappend clist { 0 w 1111 0x000119 0x79695949};  # wr 19
    lappend clist { 0 w 1111 0x00011a 0x7a6a5a4a};  # wr 1a
    lappend clist { 0 r 1111 0x000115 0x00000000};  # rd 15
    lappend clist { 0 w 1111 0x00011b 0x7b6b5b4b};  # wr 1b
    lappend clist { 0 r 1111 0x000116 0x00000000};  # rd 16
    lappend clist { 0 w 1111 0x00011c 0x7c6c5c4c};  # wr 1c
    lappend clist { 0 w 1111 0x00011d 0x7d6d5d4d};  # wr 1d
    lappend clist { 0 r 1111 0x000117 0x00000000};  # rd 17
    lappend clist { 0 r 1111 0x000118 0x00000000};  # rd 18
    lappend clist { 0 w 1111 0x00011e 0x7e6e5e4e};  # wr 1e
    lappend clist { 0 w 1111 0x00011f 0x7f6f5f4f};  # wr 1f
    lappend clist { 0 r 1111 0x000119 0x00000000};  # rd 19
    lappend clist { 0 r 1111 0x00011a 0x00000000};  # rd 1a
    lappend clist { 0 r 1111 0x00011b 0x00000000};  # rd 1b
    lappend clist { 0 r 1111 0x00011c 0x00000000};  # rd 1c
    lappend clist { 0 r 1111 0x00011d 0x00000000};  # rd 1d
    lappend clist { 0 r 1111 0x00011e 0x00000000};  # rd 1e
    lappend clist { 0 r 1111 0x00011f 0x00000000};  # rd 1f
    scmd_write $clist

    # run sequencer (plain xord=0 xora=0 veri=0)
    test_seq_srun 0 $tout
    # read back data part of sequencer
    rlc exec \
      -wreg sr.saddr 0x0000 \
      -rblk sr.sblkd 56 -edata {0x0000 0x0082 \
                                0x0000 0x9300 \
                                0x7060 0x5040 \
                                0x00a4 0x0000 \
                                0x7161 0x5141 \
                                0xb500 0x0000 \
                                0x7262 0x5282 \
                                0x7363 0x9343 \
                                0x7868 0x5848 \
                                0x74a4 0x5444 \
                                0x7969 0x5949 \
                                0x7a6a 0x5a4a \
                                0xb565 0x5545 \
                                0x7b6b 0x5b4b \
                                0x7666 0x5646 \
                                0x7c6c 0x5c4c \
                                0x7d6d 0x5d4d \
                                0x7767 0x5747 \
                                0x7868 0x5848 \
                                0x7e6e 0x5e4e \
                                0x7f6f 0x5f4f \
                                0x7969 0x5949 \
                                0x7a6a 0x5a4a \
                                0x7b6b 0x5b4b \
                                0x7c6c 0x5c4c \
                                0x7d6d 0x5d4d \
                                0x7e6e 0x5e4e \
                                0x7f6f 0x5f4f}

    #
    #-------------------------------------------------------------------------
    rlc log "  test  4: sequencer verify mode"
    # list of 4 mem write and 4 read commands
    set clist {}
    lappend clist { 0 w 1111 0x000220 0xb0a09080};
    lappend clist { 0 w 1111 0x000221 0xb1a19181};
    lappend clist { 0 r 1111 0x000220 0xb0a09080};
    lappend clist { 0 w 1111 0x000222 0xb2a29282};
    lappend clist { 0 r 1111 0x000221 0xb1a19181};
    lappend clist { 0 w 1111 0x000223 0xb3a39383};
    lappend clist { 0 r 1111 0x000222 0xb2a29282};
    lappend clist { 0 r 1111 0x000223 0xb3a39383};
    scmd_write $clist

    # run sequencer (veri=1)
    test_seq_srun [regbld tst_sram::SSTAT veri]  $tout

    # again, but with mismatch on 2nd read
    set clist {}
    lappend clist { 0 w 1111 0x000230 0xb0a09080};  #   0
    lappend clist { 0 w 1111 0x000231 0xb1a19181};  #   1
    lappend clist { 0 r 1111 0x000230 0xb0a09080};  #   2
    lappend clist { 0 w 1111 0x000232 0xb2a29282};  #   3
    lappend clist { 0 r 1111 0x000231 0x00000000};  #   4 <-- read mismatch here
    lappend clist { 0 w 1111 0x000233 0xb3a39383};  #   5
    lappend clist { 0 r 1111 0x000232 0xb2a29282};  #   6
    lappend clist { 0 r 1111 0x000233 0xb3a39383};  #   7
    scmd_write $clist

    # run sequencer (veri=1, expect fail)
    test_seq_srun [regbld tst_sram::SSTAT veri]  $tout 4 0xb1a1 0x9181

    # sblkd re-read data, check that data part wasn't overwritten
    rlc exec \
      -wreg sr.saddr 0 \
      -rblk sr.sblkd 16 -edata {0xb0a0 0x9080 \
                                0xb1a1 0x9181 \
                                0xb0a0 0x9080 \
                                0xb2a2 0x9282 \
                                0x0000 0x0000 \
                                0xb3a3 0x9383 \
                                0xb2a2 0x9282 \
                                0xb3a3 0x9383}
    #
    #-------------------------------------------------------------------------
    rlc log "  test  5: test reset via init"
    # expects state from fail srun of previous test with
    #   seaddr=0x0004   sedath=0xb1a1 sedatl=0x9181
    
    # re-check fail bit status bit set from previous test
    rlc exec \
      -rreg sr.sstat  -edata [regbld tst_sram::SSTAT veri fail] $sm \
      -rreg sr.seaddr -edata 0x0004 \
      -rreg sr.sedath -edata 0xb1a1 \
      -rreg sr.sedatl -edata 0x9181
    # init 0x0 --> noop
    rlc exec \
      -init sr.mdih   0x0000 \
      -rreg sr.sstat  -edata [regbld tst_sram::SSTAT veri fail] $sm \
      -rreg sr.seaddr -edata 0x0004 \
      -rreg sr.sedath -edata 0xb1a1 \
      -rreg sr.sedatl -edata 0x9181
    # init 0x2 --> reset MEM, no effect on SEQ state
    rlc exec \
      -init sr.mdih   0x0002 \
      -rreg sr.sstat  -edata [regbld tst_sram::SSTAT veri fail] $sm \
      -rreg sr.seaddr -edata 0x0004 \
      -rreg sr.sedath -edata 0xb1a1 \
      -rreg sr.sedatl -edata 0x9181
    # init 0x1 --> reset SEQ, add registers cleared
    rlc exec \
      -init sr.mdih   0x0001 \
      -rreg sr.sstat  -edata 0 $sm \
      -rreg sr.seaddr -edata 0     \
      -rreg sr.sedath -edata 0     \
      -rreg sr.sedatl -edata 0
    #
    #-------------------------------------------------------------------------
    rlc log "  test  6: xord and xora options"
    # list of 4 mem write and 4 read commands
    set clist {}
    lappend clist { 0 w 1111 0x000440 0xc0b0a090};
    lappend clist { 0 w 1111 0x000441 0xc1b1a191};
    lappend clist { 0 r 1111 0x000440 0xc0b0a090};
    lappend clist { 0 w 1111 0x000442 0xc2b2a292};
    lappend clist { 0 r 1111 0x000441 0xc1b1a191};
    lappend clist { 0 w 1111 0x000443 0xc3b3a393};
    lappend clist { 0 r 1111 0x000442 0xc2b2a292};
    lappend clist { 0 r 1111 0x000443 0xc3b3a393};
    scmd_write $clist

    # run sequencer (xord=1,xora=1,veri=1) and maddr=0 mdi=0
    test_seq_setxor 0x00 0x0000 0x0000 0x0000
    test_seq_srun   [regbld tst_sram::SSTAT xord xora veri]  $tout

    # read and check mem data (in 440...443, data as in smem)
    rlc exec \
      -wreg sr.maddrh 0x0000 \
      -wreg sr.maddrl 0x0440 \
      -rblk sr.mblk 8 -edata {0xc0b0 0xa090 \
                              0xc1b1 0xa191 \
                              0xc2b2 0xa292 \
                              0xc3b3 0xa393}

    # start sequencer with xord=1 and mdi=f0f0f0f0
    #   now 9=1001 <-> 6=0110
    #   now a=1010 <-> 5=0101
    #   now b=1011 <-> 4=0100
    #   now c=1100 <-> 3=0011
    test_seq_setxor 0x00 0x0000 0xf0f0 0xf0f0
    test_seq_srun   [regbld tst_sram::SSTAT xord veri]  $tout
    # read and check mem data (in 440...443, now xord'ed)
    rlc exec \
      -wreg sr.maddrh 0x0000 \
      -wreg sr.maddrl 0x0440 \
      -rblk sr.mblk 8 -edata {0x3040 0x5060 \
                              0x3141 0x5161 \
                              0x3242 0x5262 \
                              0x3343 0x5363}

    # start sequencer with xord=1 and mdi=0f0f0f0f
    #   now 0=0000 -> f=1111
    #   now 1=0001 -> e=1110
    #   now 2=0010 -> d=1101
    #   now 3=0011 -> c=1100
    test_seq_setxor 0x00 0x0000 0x0f0f 0x0f0f
    test_seq_srun   [regbld tst_sram::SSTAT xord veri]  $tout
    rlc exec \
      -wreg sr.maddrh 0x0000 \
      -wreg sr.maddrl 0x0440 \
      -rblk sr.mblk 8 -edata {0xcfbf 0xaf9f \
                              0xcebe 0xae9e \
                              0xcdbd 0xad9d \
                              0xccbc 0xac9c}

    # start sequencer with xora=1 and maddr=1000
    test_seq_setxor 0x00 0x1000 0x0000 0x0000
    test_seq_srun   [regbld tst_sram::SSTAT xora veri]  $tout
    # read and check mem data (in 1440...1443, data as in smem)
    rlc exec \
      -wreg sr.maddrh 0x0000 \
      -wreg sr.maddrl 0x1440 \
      -rblk sr.mblk 8 -edata {0xc0b0 0xa090 \
                              0xc1b1 0xa191 \
                              0xc2b2 0xa292 \
                              0xc3b3 0xa393}

    # start sequencer with xord=1,xora=1 and maddr=2000,mdi=f0f0f0f0
    test_seq_setxor 0x00 0x2000 0xf0f0 0xf0f0
    test_seq_srun   [regbld tst_sram::SSTAT xord xora veri]  $tout
    # read and check mem data (in 2440...2443, data xord'ed)
    rlc exec \
      -wreg sr.maddrh 0x0000 \
      -wreg sr.maddrl 0x2440 \
      -rblk sr.mblk 8 -edata {0x3040 0x5060 \
                              0x3141 0x5161 \
                              0x3242 0x5262 \
                              0x3343 0x5363}

    # finally check, that sedat hold pure mem data
    # list of 4 mem write and 4 read commands
    set clist {}
    lappend clist { 0 w 1111 0x000550 0xc0b0a090};
    lappend clist { 0 w 1111 0x000551 0xc1b1a191};
    lappend clist { 0 w 1111 0x000552 0xc2b2a292};
    lappend clist { 0 w 1111 0x000553 0xc3b3a393};
    lappend clist { 0 r 1111 0x000550 0x00000000};  # add read deta wrong
    lappend clist { 0 r 1111 0x000551 0x00000000};
    lappend clist { 0 r 1111 0x000552 0x00000000};
    lappend clist { 0 r 1111 0x000553 0x00000000};
    scmd_write $clist

    # start sequencer with xord=1,xora=1 and maddr=4000,mdi=f0f0f0f0
    #   check that data in sedat is xor'ed !!
    test_seq_setxor 0x00 0x4000 0xf0f0 0xf0f0
    test_seq_srun   [regbld tst_sram::SSTAT xord xora veri]  $tout \
                          4 0x3040 0x5060
    # read and check mem data (in 4550...4553, data xord'ed)
    rlc exec \
      -wreg sr.maddrh 0x0000 \
      -wreg sr.maddrl 0x4550 \
      -rblk sr.mblk 8 -edata {0x3040 0x5060 \
                              0x3141 0x5161 \
                              0x3242 0x5262 \
                              0x3343 0x5363}

    # finally clear veri error
    rlc exec -init sr.mdih 0x1; # reset SEQ
    #
    #-------------------------------------------------------------------------
    rlc log "  test  7: loop option (with xora)"
    # list of 4 mem write and 4 read commands
    set clist {}
    lappend clist { 0 w 1111 0x000000 0x00102030};
    lappend clist { 0 w 1111 0x000001 0x01112131};
    lappend clist { 0 r 1111 0x000000 0x00102030};
    lappend clist { 0 w 1111 0x000002 0x02122232};
    lappend clist { 0 r 1111 0x000001 0x01112131};
    lappend clist { 0 w 1111 0x000003 0x03132333};
    lappend clist { 0 r 1111 0x000002 0x02122232};
    lappend clist { 0 r 1111 0x000003 0x03132333};
    scmd_write $clist

    # start sequencer with loop=1,xora=1 and maddr=3fff0 (will loop to 3ffff)
    test_seq_setxor 0x03 0xfff0 0x0000 0x0000
    test_seq_srun   [regbld tst_sram::SSTAT loop xora veri]  $tout
    # check that maddr incremented
    rlc exec \
      -rreg sr.maddrh -edata 0x0003 \
      -rreg sr.maddrl -edata 0xffff
    # last iteration will write into
    #  00000 xor 03ffff -> 03ffff  (00102030)
    #  00001 xor 03ffff -> 03fffe  (01112131)
    #  00002 xor 03ffff -> 03fffd  (02122232)
    #  00003 xor 03ffff -> 03fffc  (03132333)
    # read back 4 longwords 03fffc..03ffff
    rlc exec \
      -wreg sr.maddrh 0x0003 \
      -wreg sr.maddrl 0xfffc \
      -rblk sr.mblk 8 -edata {0x0313 0x2333 \
                              0x0212 0x2232 \
                              0x0111 0x2131 \
                              0x0010 0x2030}

    #
    #-------------------------------------------------------------------------
    rlc log "  test  8: loop option (with xora), verify fail case"
    # list of 4 mem write and 4 read commands, 2nd read will fail
    set clist {}
    lappend clist { 0 w 1111 0x000100 0x00102030};
    lappend clist { 0 w 1111 0x000101 0x01112131};
    lappend clist { 0 w 1111 0x000102 0x02122232};
    lappend clist { 0 w 1111 0x000103 0x03132333};
    lappend clist { 0 r 1111 0x000100 0x00102030};
    lappend clist { 0 r 1111 0x000101 0x00000000};  # <-- will fail
    lappend clist { 0 r 1111 0x000102 0x00000000};
    lappend clist { 0 r 1111 0x000103 0x00000000};
    scmd_write $clist

    # start with loop=1,xora=1 and maddr=03fff0 (tried to loop to 03ffff)
    test_seq_setxor 0x03 0xfff0 0x0000 0x0000
    test_seq_srun   [regbld tst_sram::SSTAT loop xora veri]  $tout \
                       5 0x0111 0x2131
    # check that maddr do not increment (fail on first loop !)
    rlc exec \
      -rreg sr.maddrh -edata 0x0003 \
      -rreg sr.maddrl -edata 0xfff0

    # finally clear veri error
    rlc exec -init sr.mdih 0x1; # reset SEQ
 
    #
    #-------------------------------------------------------------------------
    rlc log "  test  9: wait field in sequencer"
    # list of 16 writes and 16 reads, with increasing waits
    set clist {}
    lappend clist { 0x0 w 1111 0x000110 0x20001000}; # writes
    lappend clist { 0x1 w 1111 0x000111 0x20011001};
    lappend clist { 0x2 w 1111 0x000112 0x20021002};
    lappend clist { 0x3 w 1111 0x000113 0x20031003};
    lappend clist { 0x4 w 1111 0x000114 0x20041004};
    lappend clist { 0x5 w 1111 0x000115 0x20051005};
    lappend clist { 0x6 w 1111 0x000116 0x20061006};
    lappend clist { 0x7 w 1111 0x000117 0x20071007};
    lappend clist { 0x8 w 1111 0x000118 0x20081008};
    lappend clist { 0x9 w 1111 0x000119 0x20091009};
    lappend clist { 0xa w 1111 0x00011a 0x200a100a};
    lappend clist { 0xb w 1111 0x00011b 0x200b100b};
    lappend clist { 0xc w 1111 0x00011c 0x200c100c};
    lappend clist { 0xd w 1111 0x00011d 0x200d100d};
    lappend clist { 0xe w 1111 0x00011e 0x200e100e};
    lappend clist { 0xf w 1111 0x00011f 0x200f100f};
    lappend clist { 0x0 r 1111 0x000110 0x20001000}; # read
    lappend clist { 0x1 r 1111 0x000111 0x20011001};
    lappend clist { 0x2 r 1111 0x000112 0x20021002};
    lappend clist { 0x3 r 1111 0x000113 0x20031003};
    lappend clist { 0x4 r 1111 0x000114 0x20041004};
    lappend clist { 0x5 r 1111 0x000115 0x20051005};
    lappend clist { 0x6 r 1111 0x000116 0x20061006};
    lappend clist { 0x7 r 1111 0x000117 0x20071007};
    lappend clist { 0x8 r 1111 0x000118 0x20081008};
    lappend clist { 0x9 r 1111 0x000119 0x20091009};
    lappend clist { 0xa r 1111 0x00011a 0x200a100a};
    lappend clist { 0xb r 1111 0x00011b 0x200b100b};
    lappend clist { 0xc r 1111 0x00011c 0x200c100c};
    lappend clist { 0xd r 1111 0x00011d 0x200d100d};
    lappend clist { 0xe r 1111 0x00011e 0x200e100e};
    lappend clist { 0xf r 1111 0x00011f 0x200f100f};
    scmd_write $clist

    # start sequencer with xora=1 and maddr=11000
    test_seq_setxor 0x01 0x1000 0x0000 0x0000
    test_seq_srun   [regbld tst_sram::SSTAT xora veri]  $tout

    # list of groups of 2 write / 2 read, with increasing wait
    set clist {}
    lappend clist { 0x0 w 1111 0x000120 0x30002000}; # write
    lappend clist { 0x0 w 1111 0x000121 0x30012001};
    lappend clist { 0x0 r 1111 0x000120 0x30002000}; # read
    lappend clist { 0x0 r 1111 0x000121 0x30012001};
    lappend clist { 0x1 w 1111 0x000122 0x30022002}; # write
    lappend clist { 0x1 w 1111 0x000123 0x30032003};
    lappend clist { 0x1 r 1111 0x000122 0x30022002}; # read
    lappend clist { 0x1 r 1111 0x000123 0x30032003};
    lappend clist { 0x2 w 1111 0x000124 0x30042004}; # write
    lappend clist { 0x2 w 1111 0x000125 0x30052005};
    lappend clist { 0x2 r 1111 0x000124 0x30042004}; # read
    lappend clist { 0x2 r 1111 0x000125 0x30052005};
    lappend clist { 0x3 w 1111 0x000126 0x30062006}; # write
    lappend clist { 0x3 w 1111 0x000127 0x30072007};
    lappend clist { 0x3 r 1111 0x000126 0x30062006}; # read
    lappend clist { 0x3 r 1111 0x000127 0x30072007};
    lappend clist { 0x4 w 1111 0x000128 0x30082008}; # write
    lappend clist { 0x4 w 1111 0x000129 0x30092009};
    lappend clist { 0x4 r 1111 0x000128 0x30082008}; # read
    lappend clist { 0x4 r 1111 0x000129 0x30092009};
    lappend clist { 0x5 w 1111 0x00012a 0x300a200a}; # write
    lappend clist { 0x5 w 1111 0x00012b 0x300b200b};
    lappend clist { 0x5 r 1111 0x00012a 0x300a200a}; # read
    lappend clist { 0x5 r 1111 0x00012b 0x300b200b};
    lappend clist { 0x6 w 1111 0x00012c 0x300c200c}; # write
    lappend clist { 0x6 w 1111 0x00012d 0x300d200d};
    lappend clist { 0x6 r 1111 0x00012c 0x300c200c}; # read
    lappend clist { 0x6 r 1111 0x00012d 0x300d200d};
    lappend clist { 0x7 w 1111 0x00012e 0x300e200e}; # write
    lappend clist { 0x7 w 1111 0x00012f 0x300f200f};
    lappend clist { 0x7 r 1111 0x00012e 0x300e200e}; # read
    lappend clist { 0x7 r 1111 0x00012f 0x300f200f};
    scmd_write $clist

    # start sequencer with xora=1 and maddr=22000
    test_seq_setxor 0x02 0x2000 0x0000 0x0000
    test_seq_srun   [regbld tst_sram::SSTAT xora veri]  $tout

    #
    #-------------------------------------------------------------------------
    if {[iswide]} {
      rlc log "  test 10: wswap option"
      # write with sequencer
      # list of writes, top 2 bits of seq address change; do read back
      set clist {}
      lappend clist { 0x0 w 1111 0x000000 0x12340000}; # -> 0x001000
      lappend clist { 0x0 w 1111 0x010011 0x12340011}; # -> 0x101011
      lappend clist { 0x0 w 1111 0x020022 0x12340022}; # -> 0x201022
      lappend clist { 0x0 w 1111 0x030033 0x12340033}; # -> 0x301033
      lappend clist { 0x0 r 1111 0x000000 0x12340000}; # <- 0x001000
      lappend clist { 0x0 r 1111 0x010011 0x12340011}; # <- 0x101011
      lappend clist { 0x0 r 1111 0x020022 0x12340022}; # <- 0x201022
      lappend clist { 0x0 r 1111 0x030033 0x12340033}; # <- 0x301033
      scmd_write $clist

      # start sequencer with xora=1 and maddr=001000
      test_seq_setxor 0x00 0x1000 0x0000 0x0000
      test_seq_srun   [regbld tst_sram::SSTAT wswap xora veri]  $tout

      # check memory via mcmd reads
      rlc exec \
        -wreg sr.maddrl 0x1000 \
        -wreg sr.mcmd   [regbld tst_sram::MCMD ld {be 0xf} {addrh 0x00}] \
        -rreg sr.mdoh   -edata 0x1234 \
        -rreg sr.mdol   -edata 0x0000 \
        -wreg sr.maddrl 0x1011 \
        -wreg sr.mcmd   [regbld tst_sram::MCMD ld {be 0xf} {addrh 0x10}] \
        -rreg sr.mdoh   -edata 0x1234 \
        -rreg sr.mdol   -edata 0x0011 \
        -wreg sr.maddrl 0x1022 \
        -wreg sr.mcmd   [regbld tst_sram::MCMD ld {be 0xf} {addrh 0x20}] \
        -rreg sr.mdoh   -edata 0x1234 \
        -rreg sr.mdol   -edata 0x0022 \
        -wreg sr.maddrl 0x1033 \
        -wreg sr.mcmd   [regbld tst_sram::MCMD ld {be 0xf} {addrh 0x30}] \
        -rreg sr.mdoh   -edata 0x1234 \
        -rreg sr.mdol   -edata 0x0033
    }
    #
    #-------------------------------------------------------------------------
    if {[iswide]} {
      rlc log "  test 11: wloop option"
      # like test previous test 7, but now using wloop
      # list of 4 mem write and 4 read commands
      set clist {}
      lappend clist { 0 w 1111 0x000000 0x00102030};
      lappend clist { 0 w 1111 0x000001 0x01112131};
      lappend clist { 0 r 1111 0x000000 0x00102030};
      lappend clist { 0 w 1111 0x000002 0x02122232};
      lappend clist { 0 r 1111 0x000001 0x01112131};
      lappend clist { 0 w 1111 0x000003 0x03132333};
      lappend clist { 0 r 1111 0x000002 0x02122232};
      lappend clist { 0 r 1111 0x000003 0x03132333};
      scmd_write $clist
      
      # start with wloop=1,loop=1,xora=1 and maddr=3ffff0 (will loop to 3fffff)
      test_seq_setxor 0x3f 0xfff0 0x0000 0x0000
      test_seq_srun   [regbld tst_sram::SSTAT wloop loop xora veri]  $tout
      # check that maddr incremented
      rlc exec \
        -rreg sr.maddrh -edata 0x003f \
        -rreg sr.maddrl -edata 0xffff
      # last iteration will write into
      #  00000 xor 3fffff -> 3fffff  (00102030)
      #  00001 xor 3fffff -> 3ffffe  (01112131)
      #  00002 xor 3fffff -> 3ffffd  (02122232)
      #  00003 xor 3fffff -> 3ffffc  (03132333)
      # read back 4 longwords 3ffffc..3fffff
      rlc exec \
        -wreg sr.maddrh 0x003f \
        -wreg sr.maddrl 0xfffc \
        -rblk sr.mblk 8 -edata {0x0313 0x2333 \
                                0x0212 0x2232 \
                                0x0111 0x2131 \
                                0x0010 0x2030}
      
    }
    #
    #-------------------------------------------------------------------------
    incr errcnt [rlc errcnt -clear]
    return $errcnt
  }
}
