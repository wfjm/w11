-- $Id: sys_w11a_n3.vhd 1325 2022-12-07 11:52:36Z mueller $
-- SPDX-License-Identifier: GPL-3.0-or-later
-- Copyright 2011-2022 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
--
------------------------------------------------------------------------------
-- Module Name:    sys_w11a_n3 - syn
-- Description:    w11a test design for nexys3
--
-- Dependencies:   vlib/xlib/s6_cmt_sfs
--                 vlib/genlib/clkdivce
--                 bplib/bpgen/bp_rs232_2l4l_iob
--                 bplib/fx2rlink/rlink_sp1c_fx2
--                 w11a/pdp11_sys70
--                 ibus/ibdr_maxisys
--                 bplib/nxcramlib/nx_cram_memctl_as
--                 bplib/fx2rlink/ioleds_sp1c_fx2
--                 w11a/pdp11_hio70
--                 bplib/bpgen/sn_humanio_rbus
--                 vlib/rbus/rb_sres_or_2
--
-- Test bench:     tb/tb_sys_w11a_n3
--
-- Target Devices: generic
-- Tool versions:  xst 13.1-14.7; ghdl 0.29-2.0.0
--
-- Synthesized (xst):
-- Date         Rev  ise         Target      flop lutl lutm slic t peri
-- 2022-12-06  1324 14.7  131013 xc6slx16-2  3227 6368  254 2182 ok:         95%
-- 2019-05-19  1150 14.7  131013 xc6slx16-2  3167 6052  248 2130 ok: +dz11   93%
-- 2019-05-01  1143 14.7  131013 xc6slx16-2  3062 5761  232 2057 ok: +m9312  90%
-- 2019-04-27  1140 14.7  131013 xc6slx16-2  3053 5742  232 2050 ok: +dlbuf  89%
-- 2019-04-24  1137 14.7  131013 xc6slx16-2  3049 5727  223 2045 ok: +pcbuf  89%
-- 2019-03-17  1123 14.7  131013 xc6slx16-2  3059 5722  212 2041 ok: +lpbuf  89%
-- 2019-03-02  1116 14.7  131013 xc6slx16-2  3048 5741  212 2030 ok: +ibtst  89%
-- 2019-01-27  1108 14.7  131013 xc6slx16-2  2979 5542  201 2018 ok: -iist   88%
-- 2018-10-13  1055 14.7  131013 xc6slx16-2  3057 5822  201 2064 ok: +dmpcnt 90%
-- 2018-09-15  1045 14.7  131013 xc6slx16-2  2851 5453  177 1932 ok: +KW11P  84%
-- 2017-03-30   888 14.7  131013 xc6slx16-2  2790 5352  177 1943 ok: +fx2dbg 85%
-- 2017-03-04   858 14.7  131013 xc6slx16-2  2717 5273  177 1885 ok: +deuna  82%
-- 2017-01-29   846 14.7  131013 xc6slx16-2  2680 5208  177 1860 ok: +int24  81%
-- 2015-07-05   698 14.7  131013 xc6slx16-2  2500 4852  161 1782 ok: +dmhbpt 78%
-- 2015-07-05   697 14.7  131013 xc6slx16-2  2428 4786  161 1756 ok: +dmcmon 77%
-- 2015-06-27   695 14.7  131013 xc6slx16-2  2281 4638  161 1714 ok: +dmscnt 75%
-- 2015-06-21   692 14.7  131013 xc6slx16-2  2192 4518  161 1584 ok: rhrp fixes
-- 2015-06-04   686 14.7  131013 xc6slx16-2  2189 4492  161 1543 ok: +TM11   67%
-- 2015-05-14   680 14.7  131013 xc6slx16-2  2120 4443  161 1546 ok: +ibmon  67%
-- 2015-04-06   664 14.7  131013 xc6slx16-2  1991 4350  167 1489 ok: +RHRP   65%
-- 2015-02-21   649 14.7  131013 xc6slx16-2  1819 3905  160 1380 ok: +RL11   61%
-- 2014-12-22   619 14.7  131013 xc6slx16-2  1742 3767  150 1350 ok: +rbmon
-- 2014-12-20   614 14.7  131013 xc6slx16-2  1640 3692  150 1297 ok: -RL11,rlv4
-- 2014-06-08   561 14.7  131013 xc6slx16-2  1531 3500  142 1165 ok: +RL11
-- 2014-05-29   556 14.7  131013 xc6slx16-2  1459 3342  128 1154 ok:         51%
-- 2013-04-21   509 13.3    O76d xc6slx16-2  1516 3274  140 1184 ok: now + FX2 !
-- 2011-12-18   440 13.1    O40d xc6slx16-2  1441 3161   96 1084 ok: LP+PC+DL+II
-- 2011-11-20   430 13.1    O40d xc6slx16-2  1412 3206   84 1063 ok: LP+PC+DL+II
--
-- Revision History: 
-- Date         Rev Version  Comment
-- 2018-10-13  1055   2.3    use DM_STAT_EXP; IDEC to maxisys; setup PERFEXT
-- 2017-04-30   888   2.2    use SWI(7:6) to allow fx2 debug via LEDs
-- 2016-03-19   748   2.1.1  define rlink SYSID
-- 2015-05-09   677   2.1    start/stop/suspend overhaul; reset overhaul
-- 2015-05-01   672   2.0    use pdp11_sys70 and pdp11_hio70
-- 2015-04-24   668   1.8.3  added ibd_ibmon
-- 2015-04-11   666   1.8.2  rearrange XON handling
-- 2015-02-21   649   1.8.1  use ioleds_sp1c,pdp11_(statleds,ledmux,dspmux)
-- 2015-02-15   647   1.8    drop bram and minisys options
-- 2014-12-24   620   1.7.2  relocate ibus window and hio rbus address
-- 2014-12-22   619   1.7.1  add rbus monitor rbd_rbmon
-- 2014-08-28   588   1.7    use new rlink v4 iface generics and 4 bit STAT
-- 2014-08-15   583   1.6    rb_mreq addr now 16 bit
-- 2013-10-06   538   1.5    pll support, use clksys_vcodivide ect
-- 2013-04-21   509   1.4    added fx2 (cuff) support
-- 2011-12-18   440   1.0.4  use rlink_sp1c
-- 2011-12-04   435   1.0.3  increase ATOWIDTH 6->7 (saw i/o timeouts on wblks)
-- 2011-11-26   433   1.0.2  use nx_cram_(dummy|memctl_as) now
-- 2011-11-23   432   1.0.1  fixup PPCM handling
-- 2011-11-20   430   1.0    Initial version (derived from sys_w11a_n2)
------------------------------------------------------------------------------
--
-- w11a test design for nexys3
--    w11a + rlink + serport
--
-- Usage of Nexys 3 Switches, Buttons, LEDs:
--
--    SWI(7:6): select LED display mode
--                 0x  w11 sys70 LED display (further controlled by SWI(3))
--                 10  FX2 debug: fx2 fifo states
--                 11  FX2 debug: fx2 fsm  states
--       (5:4): select DSP
--                 00 abclkdiv & abclkdiv_f
--                 01 PC
--                 10 DISPREG
--                 11 DR emulation
--       (3):   select LED display
--                 0 overall status
--                 1 DR emulation
--       (2)    0 -> int/ext RS242 port for rlink
--              1 -> use USB interface for rlink
--       (1):   1 enable XON
--       (0):   0 -> main board RS232 port
--              1 -> Pmod B/top RS232 port
--    
--    LEDs if SWI(7) = 0 and SWI(3) = 1
--      (7:0)    DR emulation; shows R0(lower 8 bits) during wait like 11/45+70
--
--    LEDs if SWI(7) = 0 and SWI(3) = 0
--        (7)    MEM_ACT_W
--        (6)    MEM_ACT_R
--        (5)    cmdbusy (all rlink access, mostly rdma)
--      (4:0)    if cpugo=1 show cpu mode activity
--                  (4) kernel mode, pri>0
--                  (3) kernel mode, pri=0
--                  (2) kernel mode, wait
--                  (1) supervisor mode
--                  (0) user mode
--              if cpugo=0 shows cpurust
--                  (4) '1'
--                (3:0) cpurust code
--
--    LEDs if SWI(7) = 1
--        (7)    fifo_ep4
--        (6)    fifo_ep6
--        (5)    fsm_rx
--        (4)    fsm_tx
--    LEDs if SWI(7) = 1 and SWI(6) = 0
--        (3)    flag_ep4_empty
--        (2)    flag_ep4_almost
--        (1)    flag_ep6_full
--        (0)    flag_ep6_almost
--    LEDs if SWI(7) = 1 and SWI(6) = 1
--        (3)    fsm_idle
--        (2)    fsm_prep
--        (1)    fsm_disp
--        (0)    fsm_pipe
--
--    DP(3:0) shows IO activity
--            if SWI(2)=0 (serport)
--                  (3):    not SER_MONI.txok       (shows tx back pressure)
--                  (2):    SER_MONI.txact          (shows tx activity)
--                  (1):    not SER_MONI.rxok       (shows rx back pressure)
--                  (0):    SER_MONI.rxact          (shows rx activity)
--            if SWI(2)=1 (fx2-usb)
--                  (3):    RB_SRES.busy            (shows rbus back pressure)
--                  (2):    RLB_TXBUSY              (shows tx back pressure)
--                  (1):    RLB_TXENA               (shows tx activity)
--                  (0):    RLB_RXVAL               (shows rx activity)
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.slvtypes.all;
use work.xlib.all;
use work.genlib.all;
use work.serportlib.all;
use work.rblib.all;
use work.rlinklib.all;
use work.fx2lib.all;
use work.fx2rlinklib.all;
use work.bpgenlib.all;
use work.bpgenrbuslib.all;
use work.nxcramlib.all;
use work.iblib.all;
use work.ibdlib.all;
use work.pdp11.all;
use work.sys_conf.all;

-- ----------------------------------------------------------------------------

entity sys_w11a_n3 is                   -- top level
                                        -- implements nexys3_fusp_cuff_aif
  port (
    I_CLK100 : in slbit;                -- 100 MHz clock
    I_RXD : in slbit;                   -- receive data (board view)
    O_TXD : out slbit;                  -- transmit data (board view)
    I_SWI : in slv8;                    -- n3 switches
    I_BTN : in slv5;                    -- n3 buttons
    O_LED : out slv8;                   -- n3 leds
    O_ANO_N : out slv4;                 -- 7 segment disp: anodes   (act.low)
    O_SEG_N : out slv8;                 -- 7 segment disp: segments (act.low)
    O_MEM_CE_N : out slbit;             -- cram: chip enable   (act.low)
    O_MEM_BE_N : out slv2;              -- cram: byte enables  (act.low)
    O_MEM_WE_N : out slbit;             -- cram: write enable  (act.low)
    O_MEM_OE_N : out slbit;             -- cram: output enable (act.low)
    O_MEM_ADV_N  : out slbit;           -- cram: address valid (act.low)
    O_MEM_CLK : out slbit;              -- cram: clock
    O_MEM_CRE : out slbit;              -- cram: command register enable
    I_MEM_WAIT : in slbit;              -- cram: mem wait
    O_MEM_ADDR  : out slv23;            -- cram: address lines
    IO_MEM_DATA : inout slv16;          -- cram: data lines
    O_PPCM_CE_N : out slbit;            -- ppcm: ...
    O_PPCM_RST_N : out slbit;           -- ppcm: ...
    O_FUSP_RTS_N : out slbit;           -- fusp: rs232 rts_n
    I_FUSP_CTS_N : in slbit;            -- fusp: rs232 cts_n
    I_FUSP_RXD : in slbit;              -- fusp: rs232 rx
    O_FUSP_TXD : out slbit;             -- fusp: rs232 tx
    I_FX2_IFCLK : in slbit;             -- fx2: interface clock
    O_FX2_FIFO : out slv2;              -- fx2: fifo address
    I_FX2_FLAG : in slv4;               -- fx2: fifo flags
    O_FX2_SLRD_N : out slbit;           -- fx2: read enable    (act.low)
    O_FX2_SLWR_N : out slbit;           -- fx2: write enable   (act.low)
    O_FX2_SLOE_N : out slbit;           -- fx2: output enable  (act.low)
    O_FX2_PKTEND_N : out slbit;         -- fx2: packet end     (act.low)
    IO_FX2_DATA : inout slv8            -- fx2: data lines
  );
end sys_w11a_n3;

architecture syn of sys_w11a_n3 is

  signal CLK :   slbit := '0';

  signal RESET   : slbit := '0';
  signal CE_USEC : slbit := '0';
  signal CE_MSEC : slbit := '0';

  signal RXD :   slbit := '1';
  signal TXD :   slbit := '0';
  signal RTS_N : slbit := '0';
  signal CTS_N : slbit := '0';
    
  signal RB_MREQ       : rb_mreq_type := rb_mreq_init;
  signal RB_SRES       : rb_sres_type := rb_sres_init;
  signal RB_SRES_CPU   : rb_sres_type := rb_sres_init;
  signal RB_SRES_HIO   : rb_sres_type := rb_sres_init;

  signal RB_LAM  : slv16 := (others=>'0');
  signal RB_STAT : slv4  := (others=>'0');

  signal RLB_MONI : rlb_moni_type := rlb_moni_init;
  signal SER_MONI : serport_moni_type := serport_moni_init;
  signal FX2_MONI : fx2ctl_moni_type  := fx2ctl_moni_init;

  signal GRESET  : slbit := '0';        -- general reset (from rbus)
  signal CRESET  : slbit := '0';        -- cpu reset     (from cp)
  signal BRESET  : slbit := '0';        -- bus reset     (from cp or cpu)
  signal PERFEXT : slv8  := (others=>'0');

  signal EI_PRI  : slv3   := (others=>'0');
  signal EI_VECT : slv9_2 := (others=>'0');
  signal EI_ACKM : slbit  := '0';
  
  signal CP_STAT : cp_stat_type := cp_stat_init;
  signal DM_STAT_EXP : dm_stat_exp_type := dm_stat_exp_init;

  signal MEM_REQ   : slbit := '0';
  signal MEM_WE    : slbit := '0';
  signal MEM_BUSY  : slbit := '0';
  signal MEM_ACK_R : slbit := '0';
  signal MEM_ACT_R : slbit := '0';
  signal MEM_ACT_W : slbit := '0';
  signal MEM_ADDR  : slv20 := (others=>'0');
  signal MEM_BE    : slv4  := (others=>'0');
  signal MEM_DI    : slv32 := (others=>'0');
  signal MEM_DO    : slv32 := (others=>'0');

  signal MEM_ADDR_EXT : slv22 := (others=>'0');

  signal IB_MREQ : ib_mreq_type := ib_mreq_init;
  signal IB_SRES_IBDR : ib_sres_type := ib_sres_init;

  signal DISPREG : slv16 := (others=>'0');
  signal ABCLKDIV : slv16 := (others=>'0');

  signal LED70   : slv8  := (others=>'0');  

  signal SWI     : slv8  := (others=>'0');
  signal BTN     : slv5  := (others=>'0');
  signal LED     : slv8  := (others=>'0');  
  signal DSP_DAT : slv16 := (others=>'0');
  signal DSP_DP  : slv4  := (others=>'0');
  
  constant rbaddr_rbmon : slv16 := x"ffe8"; -- ffe8/0008: 1111 1111 1110 1xxx
  constant rbaddr_hio   : slv16 := x"fef0"; -- fef0/0008: 1111 1110 1111 0xxx

  constant sysid_proj  : slv16 := x"0201";   -- w11a
  constant sysid_board : slv8  := x"03";     -- nexys3
  constant sysid_vers  : slv8  := x"00";

begin

  assert (sys_conf_clksys mod 1000000) = 0
    report "assert sys_conf_clksys on MHz grid"
    severity failure;
  
  GEN_CLKSYS : s6_cmt_sfs               -- clock generator -------------------
    generic map (
      VCO_DIVIDE     => sys_conf_clksys_vcodivide,
      VCO_MULTIPLY   => sys_conf_clksys_vcomultiply,
      OUT_DIVIDE     => sys_conf_clksys_outdivide,
      CLKIN_PERIOD   => 10.0,
      CLKIN_JITTER   => 0.01,
      STARTUP_WAIT   => false,
      GEN_TYPE       => sys_conf_clksys_gentype)
    port map (
      CLKIN   => I_CLK100,
      CLKFX   => CLK,
      LOCKED  => open
    );

  CLKDIV : clkdivce                     -- usec/msec clock divider -----------
    generic map (
      CDUWIDTH => 7,
      USECDIV  => sys_conf_clksys_mhz,
      MSECDIV  => 1000)
    port map (
      CLK     => CLK,
      CE_USEC => CE_USEC,
      CE_MSEC => CE_MSEC
    );

  IOB_RS232 : bp_rs232_2l4l_iob         -- serport iob/switch ----------------
    port map (
      CLK      => CLK,
      RESET    => '0',
      SEL      => SWI(0),
      RXD      => RXD,
      TXD      => TXD,
      CTS_N    => CTS_N,
      RTS_N    => RTS_N,
      I_RXD0   => I_RXD,
      O_TXD0   => O_TXD,
      I_RXD1   => I_FUSP_RXD,
      O_TXD1   => O_FUSP_TXD,
      I_CTS1_N => I_FUSP_CTS_N,
      O_RTS1_N => O_FUSP_RTS_N
    );

  RLINK : rlink_sp1c_fx2                -- rlink for serport + fx2 -----------
    generic map (
      BTOWIDTH     => 7,                -- 128 cycles access timeout
      RTAWIDTH     => 12,
      SYSID        => (others=>'0'),
      IFAWIDTH     => 5,                --  32 word input fifo
      OFAWIDTH     => 5,                --  32 word output fifo
      PETOWIDTH    => sys_conf_fx2_petowidth,
      CCWIDTH      => sys_conf_fx2_ccwidth,
      ENAPIN_RLMON => sbcntl_sbf_rlmon,
      ENAPIN_RBMON => sbcntl_sbf_rbmon,
      CDWIDTH      => 13,
      CDINIT       => sys_conf_ser2rri_cdinit,
      RBMON_AWIDTH => sys_conf_rbmon_awidth,
      RBMON_RBADDR => rbaddr_rbmon)
    port map (
      CLK      => CLK,
      CE_USEC  => CE_USEC,
      CE_MSEC  => CE_MSEC,
      CE_INT   => CE_MSEC,
      RESET    => RESET,
      ENAXON   => SWI(1),
      ENAFX2   => SWI(2),
      RXSD     => RXD,
      TXSD     => TXD,
      CTS_N    => CTS_N,
      RTS_N    => RTS_N,
      RB_MREQ  => RB_MREQ,
      RB_SRES  => RB_SRES,
      RB_LAM   => RB_LAM,
      RB_STAT  => RB_STAT,
      RL_MONI  => open,
      RLB_MONI => RLB_MONI,
      SER_MONI => SER_MONI,
      FX2_MONI => FX2_MONI,
      I_FX2_IFCLK    => I_FX2_IFCLK,
      O_FX2_FIFO     => O_FX2_FIFO,
      I_FX2_FLAG     => I_FX2_FLAG,
      O_FX2_SLRD_N   => O_FX2_SLRD_N,
      O_FX2_SLWR_N   => O_FX2_SLWR_N,
      O_FX2_SLOE_N   => O_FX2_SLOE_N,
      O_FX2_PKTEND_N => O_FX2_PKTEND_N,
      IO_FX2_DATA    => IO_FX2_DATA
    );

  PERFEXT(0) <= '0';                    -- unused (ext_rdrhit)
  PERFEXT(1) <= '0';                    -- unused (ext_wrrhit)
  PERFEXT(2) <= '0';                    -- unused (ext_wrflush)
  PERFEXT(3) <= RLB_MONI.rxval and not RLB_MONI.rxhold;  -- ext_rlrxact
  PERFEXT(4) <= RLB_MONI.rxhold;                         -- ext_rlrxback
  PERFEXT(5) <= RLB_MONI.txena and not RLB_MONI.txbusy;  -- ext_rltxact
  PERFEXT(6) <= RLB_MONI.txbusy;                         -- ext_rltxback
  PERFEXT(7) <= CE_USEC;                -- ext_usec
  
  SYS70 : pdp11_sys70                   -- 1 cpu system ----------------------
    port map (
      CLK         => CLK,
      RESET       => RESET,
      RB_MREQ     => RB_MREQ,
      RB_SRES     => RB_SRES_CPU,
      RB_STAT     => RB_STAT,
      RB_LAM_CPU  => RB_LAM(0),
      GRESET      => GRESET,
      CRESET      => CRESET,
      BRESET      => BRESET,
      CP_STAT     => CP_STAT,
      EI_PRI      => EI_PRI,
      EI_VECT     => EI_VECT,
      EI_ACKM     => EI_ACKM,
      PERFEXT     => PERFEXT,
      IB_MREQ     => IB_MREQ,
      IB_SRES     => IB_SRES_IBDR,
      MEM_REQ     => MEM_REQ,
      MEM_WE      => MEM_WE,
      MEM_BUSY    => MEM_BUSY,
      MEM_ACK_R   => MEM_ACK_R,
      MEM_ADDR    => MEM_ADDR,
      MEM_BE      => MEM_BE,
      MEM_DI      => MEM_DI,
      MEM_DO      => MEM_DO,
      DM_STAT_EXP => DM_STAT_EXP
    );

  IBDR_SYS : ibdr_maxisys               -- IO system -------------------------
    port map (
      CLK      => CLK,
      CE_USEC  => CE_USEC,
      CE_MSEC  => CE_MSEC,
      RESET    => GRESET,
      BRESET   => BRESET,
      ITIMER   => DM_STAT_EXP.se_itimer,
      IDEC     => DM_STAT_EXP.se_idec,
      CPUSUSP  => CP_STAT.cpususp,
      RB_LAM   => RB_LAM(15 downto 1),
      IB_MREQ  => IB_MREQ,
      IB_SRES  => IB_SRES_IBDR,
      EI_ACKM  => EI_ACKM,
      EI_PRI   => EI_PRI,
      EI_VECT  => EI_VECT,
      DISPREG  => DISPREG
    );
    
  MEM_ADDR_EXT <= "00" & MEM_ADDR;    -- just use lower 4 MB (of 16 MB)

  CRAMCTL: nx_cram_memctl_as            -- memory controller -----------------
    generic map (
      READ0DELAY => sys_conf_memctl_read0delay,
      READ1DELAY => sys_conf_memctl_read1delay,
      WRITEDELAY => sys_conf_memctl_writedelay)
    port map (
      CLK         => CLK,
      RESET       => GRESET,
      REQ         => MEM_REQ,
      WE          => MEM_WE,
      BUSY        => MEM_BUSY,
      ACK_R       => MEM_ACK_R,
      ACK_W       => open,
      ACT_R       => MEM_ACT_R,
      ACT_W       => MEM_ACT_W,
      ADDR        => MEM_ADDR_EXT,
      BE          => MEM_BE,
      DI          => MEM_DI,
      DO          => MEM_DO,
      O_MEM_CE_N  => O_MEM_CE_N,
      O_MEM_BE_N  => O_MEM_BE_N,
      O_MEM_WE_N  => O_MEM_WE_N,
      O_MEM_OE_N  => O_MEM_OE_N,
      O_MEM_ADV_N => O_MEM_ADV_N,
      O_MEM_CLK   => O_MEM_CLK,
      O_MEM_CRE   => O_MEM_CRE,
      I_MEM_WAIT  => I_MEM_WAIT,
      O_MEM_ADDR  => O_MEM_ADDR,
      IO_MEM_DATA => IO_MEM_DATA
    );

  O_PPCM_CE_N  <= '1';              -- keep parallel PCM memory disabled
  O_PPCM_RST_N <= '1';              --

  LED_IO : ioleds_sp1c_fx2              -- hio leds from serport or fx2 ------
    port map (
      CLK      => CLK,
      CE_USEC  => CE_USEC,
      RESET    => GRESET,
      ENAFX2   => SWI(2),
      RB_SRES  => RB_SRES,
      RLB_MONI => RLB_MONI,
      SER_MONI => SER_MONI,
      IOLEDS   => DSP_DP
    );
  
  ABCLKDIV <= SER_MONI.abclkdiv(11 downto 0) & '0' & SER_MONI.abclkdiv_f;

  HIO70 : pdp11_hio70                   -- hio from sys70 --------------------
    generic map (
      LWIDTH => LED'length,
      DCWIDTH => 2)
    port map (
      SEL_LED     => SWI(3),
      SEL_DSP     => SWI(5 downto 4),
      MEM_ACT_R   => MEM_ACT_R,
      MEM_ACT_W   => MEM_ACT_W,
      CP_STAT     => CP_STAT,
      DM_STAT_EXP => DM_STAT_EXP,
      ABCLKDIV    => ABCLKDIV,
      DISPREG     => DISPREG,
      LED         => LED70,
      DSP_DAT     => DSP_DAT
    );

  proc_fx2leds: process (SWI, LED70, FX2_MONI) -- hio LED handler ------------
    variable iled : slv8 := (others=>'0');
  begin

    iled := (others=>'0');
    if SWI(7) = '0' then
      iled := LED70;
    else
      iled(7) := FX2_MONI.fifo_ep4;
      iled(6) := FX2_MONI.fifo_ep6;
      iled(5) := FX2_MONI.fsm_rx;
      iled(4) := FX2_MONI.fsm_tx;
      if SWI(6) = '0' then
        iled(3) := FX2_MONI.flag_ep4_empty;
        iled(2) := FX2_MONI.flag_ep4_almost;
        iled(1) := FX2_MONI.flag_ep6_full;
        iled(0) := FX2_MONI.flag_ep6_almost;
      else
        iled(3) := FX2_MONI.fsm_idle;
        iled(2) := FX2_MONI.fsm_prep;
        iled(1) := FX2_MONI.fsm_disp;
        iled(0) := FX2_MONI.fsm_pipe;
      end if;
    end if;
    LED <= iled;
    
  end process proc_fx2leds;

  HIO : sn_humanio_rbus                 -- hio manager -----------------------
    generic map (
      BWIDTH   => 5,
      DEBOUNCE => sys_conf_hio_debounce,
      RB_ADDR  => rbaddr_hio)
    port map (
      CLK     => CLK,
      RESET   => RESET,
      CE_MSEC => CE_MSEC,
      RB_MREQ => RB_MREQ,
      RB_SRES => RB_SRES_HIO,
      SWI     => SWI,                   
      BTN     => BTN,                   
      LED     => LED,                   
      DSP_DAT => DSP_DAT,               
      DSP_DP  => DSP_DP,
      I_SWI   => I_SWI,                 
      I_BTN   => I_BTN,
      O_LED   => O_LED,
      O_ANO_N => O_ANO_N,
      O_SEG_N => O_SEG_N
    );

  RB_SRES_OR : rb_sres_or_2             -- rbus or ---------------------------
    port map (
      RB_SRES_1  => RB_SRES_CPU,
      RB_SRES_2  => RB_SRES_HIO,
      RB_SRES_OR => RB_SRES
    );
  
end syn;
