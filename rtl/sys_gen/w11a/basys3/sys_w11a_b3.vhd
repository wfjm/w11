-- $Id: sys_w11a_b3.vhd 1389 2023-05-20 15:48:59Z mueller $
-- SPDX-License-Identifier: GPL-3.0-or-later
-- Copyright 2015-2023 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
--
------------------------------------------------------------------------------
-- Module Name:    sys_w11a_b3 - syn
-- Description:    w11a test design for basys3
--
-- Dependencies:   bplib/bpgen/s7_cmt_1ce1ce
--                 bplib/bpgen/bp_rs232_2line_iob
--                 vlib/rlink/rlink_sp2c
--                 w11a/pdp11_sys70
--                 ibus/ibdr_maxisys
--                 w11a/pdp11_bram_memctl
--                 vlib/rlink/ioleds_sp1c
--                 w11a/pdp11_hio70
--                 bplib/bpgen/sn_humanio_rbus
--                 bplib/sysmon/sysmonx_rbus_base
--                 vlib/rbus/rbd_usracc
--                 vlib/rbus/rb_sres_or_4
--
-- Test bench:     tb/tb_sys_w11a_b3
--
-- Target Devices: generic
-- Tool versions:  viv 2014.4-2023.1; ghdl 0.31-2.0.0
--
-- Synthesized:
-- Date         Rev  viv    Target       flop  lutl  lutm  bram  slic
-- 2023-05-19  1388 2023.1  xc7a35t-1    3054  5523   267  48.0  1864
-- 2022-12-06  1324 2022.1  xc7a35t-1    3050  5501   267  48.0  1829
-- 2022-07-05  1247 2022.1  xc7a35t-1    3011  5669   267  48.0  1906
-- 2019-05-19  1150 2017.2  xc7a35t-1    2968  6360   273  48.0  1963 +dz11
-- 2019-04-27  1140 2017.2  xc7a35t-1    2835  6032   248  47.5  1879 +*buf
-- 2019-03-02  1116 2017.2  xc7a35t-1    2748  5725   186  47.5  1811 +ibtst
-- 2019-02-02  1108 2018.3  xc7a35t-1    2711  5910   170  47.5  1825 
-- 2019-02-02  1108 2017.2  xc7a35t-1    2698  5636   170  47.5  1728 
-- 2018-10-13  1055 2017.2  xc7a35t-1    2698  5636   170  47.5  1723 +dmpcnt
-- 2018-09-15  1045 2017.2  xc7a35t-1    2475  5282   138  47.5  1643 +KW11P
-- 2017-04-16   881 2016.4  xc7a35t-1    2412  5228   138  47.5  1608 +DEUNA
-- 2017-01-29   846 2016.4  xc7a35t-1    2362  5239   138  47.5  1619 +int24
-- 2016-05-26   768 2016.1  xc7a35t-1    2361  5203   138  47.5  1600 fsm+dsm=0
-- 2016-05-22   767 2016.1  xc7a35t-1    2362  5340   138  48.5  1660 fsm
-- 2016-03-29   756 2015.4  xc7a35t-1    2240  4518   138  48.5  1430 serport2
-- 2016-03-27   753 2015.4  xc7a35t-1    2131  4398   138  48.5  1362 meminf
-- 2016-03-13   742 2015.4  xc7a35t-1    2135  4420   162  48.5  1396 +XADC
-- 2015-06-04   686 2014.4  xc7a35t-1    1919  4372   162  47.5  1408 +TM11 17%
-- 2015-05-14   680 2014.4  xc7a35t-1    1837  4304   162  47.5  1354 +RHRP 17%
-- 2015-02-21   649 2014.4  xc7a35t-1    1637  3767   146  47.5  1195  
--
-- Revision History: 
-- Date         Rev Version  Comment
-- 2018-12-16  1086   1.5    use s7_cmt_1ce1ce
-- 2018-10-13  1055   2.4    use DM_STAT_EXP; IDEC to maxisys; setup PERFEXT
-- 2016-04-02   758   2.3.1  add rbd_usracc (bitfile+jtag timestamp access)
-- 2016-03-28   755   2.3    use serport_2clock2
-- 2016-03-19   748   2.2.2  define rlink SYSID
-- 2016-03-18   745   2.2.1  hardwire XON=1
-- 2016-03-13   742   2.2    add sysmon_rbus
-- 2015-05-09   677   2.1    start/stop/suspend overhaul; reset overhaul
-- 2015-05-01   672   2.0    use pdp11_sys70 and pdp11_hio70
-- 2015-04-11   666   1.1.1  rearrange XON handling
-- 2015-02-21   649   1.1    use ioleds_sp1c,pdp11_(statleds,ledmux,dspmux)
-- 2015-02-08   644   1.0    Initial version (derived from sys_w11a_n4)
------------------------------------------------------------------------------
--
-- w11a test design for basys3
--    w11a + rlink + serport
--
-- Usage of Basys 3 Switches, Buttons, LEDs
--
--    SWI(15:6): no function (only connected to sn_humanio_rbus)
--    SWI(5:4):  select DSP
--                 00 abclkdiv & abclkdiv_f
--                 01 PC
--                 10 DISPREG
--                 11 DR emulation
--    SWI(3):    select LED display
--                 0 overall status
--                 1 DR emulation
--    SWI(2):    unused-reserved (USB port select)
--    SWI(1):    unused-reserved (XON, is hardwired to '1')
--    SWI(0):    unused-reserved (serial port select)
--    
--    LEDs if SWI(3) = 1
--      (15:0)   DR emulation; shows R0 during wait like 11/45+70
--
--    LEDs if SWI(3) = 0
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
--    DSP(7:4)  shows abclkdiv & abclkdiv_f or PS depending on SWI(4)
--    DSP(3:0)  shows DISPREG
--    DP(3:0)   shows IO activity
--                  (3)  not SER_MONI.txok       (shows tx back pressure)
--                  (2)  SER_MONI.txact          (shows tx activity)
--                  (1)  not SER_MONI.rxok       (shows rx back pressure)
--                  (0)  SER_MONI.rxact          (shows rx activity)
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.slvtypes.all;
use work.serportlib.all;
use work.rblib.all;
use work.rbdlib.all;
use work.rlinklib.all;
use work.bpgenlib.all;
use work.bpgenrbuslib.all;
use work.sysmonrbuslib.all;
use work.iblib.all;
use work.ibdlib.all;
use work.pdp11.all;
use work.sys_conf.all;

-- ----------------------------------------------------------------------------

entity sys_w11a_b3 is                   -- top level
                                        -- implements basys3_aif
  port (
    I_CLK100 : in slbit;                -- 100 MHz clock
    I_RXD : in slbit;                   -- receive data (board view)
    O_TXD : out slbit;                  -- transmit data (board view)
    I_SWI : in slv16;                   -- b3 switches
    I_BTN : in slv5;                    -- b3 buttons
    O_LED : out slv16;                  -- b3 leds
    O_ANO_N : out slv4;                 -- 7 segment disp: anodes   (act.low)
    O_SEG_N : out slv8                  -- 7 segment disp: segments (act.low)
  );
end sys_w11a_b3;

architecture syn of sys_w11a_b3 is

  signal CLK :   slbit := '0';

  signal RESET   : slbit := '0';
  signal CE_USEC : slbit := '0';
  signal CE_MSEC : slbit := '0';

  signal CLKS :  slbit := '0';
  signal CES_MSEC : slbit := '0';

  signal RXD :   slbit := '1';
  signal TXD :   slbit := '0';
    
  signal RB_MREQ        : rb_mreq_type := rb_mreq_init;
  signal RB_SRES        : rb_sres_type := rb_sres_init;
  signal RB_SRES_CPU    : rb_sres_type := rb_sres_init;
  signal RB_SRES_HIO    : rb_sres_type := rb_sres_init;
  signal RB_SRES_SYSMON : rb_sres_type := rb_sres_init;
  signal RB_SRES_USRACC : rb_sres_type := rb_sres_init;

  signal RB_LAM  : slv16 := (others=>'0');
  signal RB_STAT : slv4  := (others=>'0');
  
  signal SER_MONI : serport_moni_type := serport_moni_init;

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

  signal IB_MREQ : ib_mreq_type := ib_mreq_init;
  signal IB_SRES_IBDR  : ib_sres_type := ib_sres_init;

  signal DISPREG :  slv16 := (others=>'0');
  signal ABCLKDIV : slv16 := (others=>'0');
    
  signal SWI     : slv16 := (others=>'0');
  signal BTN     : slv5  := (others=>'0');
  signal LED     : slv16 := (others=>'0');  
  signal DSP_DAT : slv16 := (others=>'0');
  signal DSP_DP  : slv4  := (others=>'0');

  constant rbaddr_rbmon : slv16 := x"ffe8"; -- ffe8/0008: 1111 1111 1110 1xxx
  constant rbaddr_hio   : slv16 := x"fef0"; -- fef0/0008: 1111 1110 1111 0xxx
  constant rbaddr_sysmon: slv16 := x"fb00"; -- fb00/0080: 1111 1011 0xxx xxxx

  constant sysid_proj  : slv16 := x"0201";   -- w11a
  constant sysid_board : slv8  := x"06";     -- basys3
  constant sysid_vers  : slv8  := x"00";

begin

  assert (sys_conf_clksys mod 1000000) = 0
    report "assert sys_conf_clksys on MHz grid"
    severity failure;
  
  GEN_CLKALL : s7_cmt_1ce1ce            -- clock generator system ------------
    generic map (
      CLKIN_PERIOD   => 10.0,
      CLKIN_JITTER   => 0.01,
      STARTUP_WAIT   => false,
      CLK0_VCODIV    => sys_conf_clksys_vcodivide,
      CLK0_VCOMUL    => sys_conf_clksys_vcomultiply,
      CLK0_OUTDIV    => sys_conf_clksys_outdivide,
      CLK0_GENTYPE   => sys_conf_clksys_gentype,
      CLK0_CDUWIDTH  => 7,
      CLK0_USECDIV   => sys_conf_clksys_mhz,
      CLK0_MSECDIV   => 1000,      
      CLK1_VCODIV    => sys_conf_clkser_vcodivide,
      CLK1_VCOMUL    => sys_conf_clkser_vcomultiply,
      CLK1_OUTDIV    => sys_conf_clkser_outdivide,
      CLK1_GENTYPE   => sys_conf_clkser_gentype,
      CLK1_CDUWIDTH  => 7,
      CLK1_USECDIV   => sys_conf_clkser_mhz,
      CLK1_MSECDIV   => 1000)
    port map (
      CLKIN     => I_CLK100,
      CLK0      => CLK,
      CE0_USEC  => CE_USEC,
      CE0_MSEC  => CE_MSEC,
      CLK1      => CLKS,
      CE1_USEC  => open,
      CE1_MSEC  => CES_MSEC,
      LOCKED    => open
    );

  IOB_RS232 : bp_rs232_2line_iob         -- serport iob ----------------------
    port map (
      CLK      => CLKS,
      RXD      => RXD,
      TXD      => TXD,
      I_RXD    => I_RXD,
      O_TXD    => O_TXD
    );

  RLINK : rlink_sp2c                    -- rlink for serport -----------------
    generic map (
      BTOWIDTH     => 7,                -- 128 cycles access timeout
      RTAWIDTH     => 12,
      SYSID        => sysid_proj & sysid_board & sysid_vers,
      IFAWIDTH     => 5,                --  32 word input fifo
      OFAWIDTH     => 5,                --  32 word output fifo
      ENAPIN_RLMON => sbcntl_sbf_rlmon,
      ENAPIN_RBMON => sbcntl_sbf_rbmon,
      CDWIDTH      => 12,
      CDINIT       => sys_conf_ser2rri_cdinit,
      RBMON_AWIDTH => sys_conf_rbmon_awidth,
      RBMON_RBADDR => rbaddr_rbmon)
    port map (
      CLK      => CLK,
      CE_USEC  => CE_USEC,
      CE_MSEC  => CE_MSEC,
      CE_INT   => CE_MSEC,
      RESET    => RESET,
      CLKS     => CLKS,
      CES_MSEC => CES_MSEC,
      ENAXON   => '1',
      ESCFILL  => '0',
      RXSD     => RXD,
      TXSD     => TXD,
      CTS_N    => '0',
      RTS_N    => open,
      RB_MREQ  => RB_MREQ,
      RB_SRES  => RB_SRES,
      RB_LAM   => RB_LAM,
      RB_STAT  => RB_STAT,
      RL_MONI  => open,
      SER_MONI => SER_MONI
    );

  PERFEXT(0) <= '0';                    -- unused (ext_rdrhit)
  PERFEXT(1) <= '0';                    -- unused (ext_wrrhit)
  PERFEXT(2) <= '0';                    -- unused (ext_wrflush)
  PERFEXT(3) <= SER_MONI.rxact;         -- ext_rlrxact
  PERFEXT(4) <= not SER_MONI.rxok;      -- ext_rlrxback
  PERFEXT(5) <= SER_MONI.txact;         -- ext_rltxact
  PERFEXT(6) <= not SER_MONI.txok;      -- ext_rltxback
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
  
  BRAM_CTL: pdp11_bram_memctl           -- memory controller -----------------
    generic map (
      MAWIDTH => sys_conf_memctl_mawidth,
      NBLOCK  => sys_conf_memctl_nblock)
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
      ADDR        => MEM_ADDR,
      BE          => MEM_BE,
      DI          => MEM_DI,
      DO          => MEM_DO
    );

  LED_IO : ioleds_sp1c                  -- hio leds from serport -------------
    port map (
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
      LED         => LED,
      DSP_DAT     => DSP_DAT
    );

  HIO : sn_humanio_rbus                 -- hio manager -----------------------
    generic map (
      SWIDTH   => 16,
      BWIDTH   =>  5,
      LWIDTH   => 16,
      DCWIDTH  =>  2,
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

  SMRB : if sys_conf_rbd_sysmon  generate    
    I0: sysmonx_rbus_base
      generic map (                     -- use default INIT_ (Vccint=1.00)
        CLK_MHZ  => sys_conf_clksys_mhz,
        RB_ADDR  => rbaddr_sysmon)
      port map (
        CLK      => CLK,
        RESET    => RESET,
        RB_MREQ  => RB_MREQ,
        RB_SRES  => RB_SRES_SYSMON,
        ALM      => open,
        OT       => open,
        TEMP     => open
      );
  end generate SMRB;

  UARB : rbd_usracc
    port map (
      CLK     => CLK,
      RB_MREQ => RB_MREQ,
      RB_SRES => RB_SRES_USRACC
    );

  RB_SRES_OR : rb_sres_or_4             -- rbus or ---------------------------
    port map (
      RB_SRES_1  => RB_SRES_CPU,
      RB_SRES_2  => RB_SRES_HIO,
      RB_SRES_3  => RB_SRES_SYSMON,
      RB_SRES_4  => RB_SRES_USRACC,
      RB_SRES_OR => RB_SRES
    );
  
end syn;
