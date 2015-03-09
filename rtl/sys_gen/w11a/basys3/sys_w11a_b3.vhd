-- $Id: sys_w11a_b3.vhd 652 2015-02-28 12:18:08Z mueller $
--
-- Copyright 2015- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
--
-- This program is free software; you may redistribute and/or modify it under
-- the terms of the GNU General Public License as published by the Free
-- Software Foundation, either version 2, or at your option any later version.
--
-- This program is distributed in the hope that it will be useful, but
-- WITHOUT ANY WARRANTY, without even the implied warranty of MERCHANTABILITY
-- or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
-- for complete details.
--
------------------------------------------------------------------------------
-- Module Name:    sys_w11a_b3 - syn
-- Description:    w11a test design for basys3
--
-- Dependencies:   vlib/xlib/s7_cmt_sfs
--                 vlib/genlib/clkdivce
--                 bplib/bpgen/bp_rs232_2line_iob
--                 bplib/bpgen/sn_humanio_rbus
--                 vlib/rlink/rlink_sp1c
--                 vlib/rbus/rb_sres_or_3
--                 w11a/pdp11_core_rbus
--                 w11a/pdp11_core
--                 w11a/pdp11_cache
--                 w11a/pdp11_mem70
--                 w11a/pdp11_bram_memctl
--                 ibus/ib_sres_or_2
--                 ibus/ibdr_maxisys
--                 vlib/rlink/ioleds_sp1c
--                 w11a/pdp11_statleds
--                 w11a/pdp11_ledmux
--                 w11a/pdp11_dspmux
--                 w11a/pdp11_tmu_sb           [sim only]
--
-- Test bench:     tb/tb_sys_w11a_b3
--
-- Target Devices: generic
-- Tool versions:  viv 2014.4; ghdl 0.31
--
-- Synthesized:
-- Date         Rev  viv    Target       flop  lutl  lutm  bram  slic
-- 2015-02-21   649 2014.4  xc7a35t-1    1637  3767   146  47.5  1195  
--
-- Revision History: 
-- Date         Rev Version  Comment
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
--    SWI(1):    1 enable XON
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
--                  (3)  not SER_MONI.txok       (shows tx back preasure)
--                  (2)  SER_MONI.txact          (shows tx activity)
--                  (1)  not SER_MONI.rxok       (shows rx back preasure)
--                  (0)  SER_MONI.rxact          (shows rx activity)
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
use work.bpgenlib.all;
use work.bpgenrbuslib.all;
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

  signal RXD :   slbit := '1';
  signal TXD :   slbit := '0';
    
  signal SWI     : slv16 := (others=>'0');
  signal BTN     : slv5  := (others=>'0');
  signal LED     : slv16 := (others=>'0');  
  signal DSP_DAT : slv16 := (others=>'0');
  signal DSP_DP  : slv4  := (others=>'0');

  signal RB_LAM  : slv16 := (others=>'0');
  signal RB_STAT : slv4  := (others=>'0');
  
  signal SER_MONI : serport_moni_type := serport_moni_init;

  signal RB_MREQ     : rb_mreq_type := rb_mreq_init;
  signal RB_SRES     : rb_sres_type := rb_sres_init;
  signal RB_SRES_CPU : rb_sres_type := rb_sres_init;
  signal RB_SRES_IBD : rb_sres_type := rb_sres_init;
  signal RB_SRES_HIO : rb_sres_type := rb_sres_init;

  signal RESET   : slbit := '0';
  signal CE_USEC : slbit := '0';
  signal CE_MSEC : slbit := '0';

  signal CPU_RESET : slbit := '0';
  signal CP_CNTL : cp_cntl_type := cp_cntl_init;
  signal CP_ADDR : cp_addr_type := cp_addr_init;
  signal CP_DIN  : slv16 := (others=>'0');
  signal CP_STAT : cp_stat_type := cp_stat_init;
  signal CP_DOUT : slv16 := (others=>'0');

  signal EI_PRI  : slv3   := (others=>'0');
  signal EI_VECT : slv9_2 := (others=>'0');
  signal EI_ACKM : slbit  := '0';
  
  signal EM_MREQ : em_mreq_type := em_mreq_init;
  signal EM_SRES : em_sres_type := em_sres_init;
  
  signal HM_ENA      : slbit := '0';
  signal MEM70_FMISS : slbit := '0';
  signal CACHE_FMISS : slbit := '0';
  signal CACHE_CHIT  : slbit := '0';

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

  signal BRESET  : slbit := '0';
  signal IB_MREQ : ib_mreq_type := ib_mreq_init;
  signal IB_SRES : ib_sres_type := ib_sres_init;

  signal IB_SRES_MEM70 : ib_sres_type := ib_sres_init;
  signal IB_SRES_IBDR  : ib_sres_type := ib_sres_init;

  signal DM_STAT_DP : dm_stat_dp_type := dm_stat_dp_init;
  signal DM_STAT_VM : dm_stat_vm_type := dm_stat_vm_init;
  signal DM_STAT_CO : dm_stat_co_type := dm_stat_co_init;
  signal DM_STAT_SY : dm_stat_sy_type := dm_stat_sy_init;

  signal DISPREG :  slv16 := (others=>'0');
  signal STATLEDS :  slv8 := (others=>'0');
  signal ABCLKDIV : slv16 := (others=>'0');

  constant rbaddr_hio   : slv16 := x"fef0"; -- fef0/0004: 1111 1110 1111 00xx
  constant rbaddr_ibus0 : slv16 := x"4000"; -- 4000/1000: 0100 xxxx xxxx xxxx
  constant rbaddr_core0 : slv16 := x"0000"; -- 0000/0020: 0000 0000 000x xxxx

begin

  assert (sys_conf_clksys mod 1000000) = 0
    report "assert sys_conf_clksys on MHz grid"
    severity failure;
  
  GEN_CLKSYS : s7_cmt_sfs
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

  CLKDIV : clkdivce
    generic map (
      CDUWIDTH => 7,
      USECDIV  => sys_conf_clksys_mhz,
      MSECDIV  => 1000)
    port map (
      CLK     => CLK,
      CE_USEC => CE_USEC,
      CE_MSEC => CE_MSEC
    );

  IOB_RS232 : bp_rs232_2line_iob
    port map (
      CLK      => CLK,
      RXD      => RXD,
      TXD      => TXD,
      I_RXD    => I_RXD,
      O_TXD    => O_TXD
    );

  HIO : sn_humanio_rbus
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

  RLINK : rlink_sp1c
    generic map (
      BTOWIDTH     => 7,                -- 128 cycles access timeout
      RTAWIDTH     => 12,
      SYSID        => (others=>'0'),
      IFAWIDTH     => 5,                --  32 word input fifo
      OFAWIDTH     => 5,                --  32 word output fifo
      ENAPIN_RLMON => sbcntl_sbf_rlmon,
      ENAPIN_RBMON => sbcntl_sbf_rbmon,
      CDWIDTH      => 13,
      CDINIT       => sys_conf_ser2rri_cdinit)
    port map (
      CLK      => CLK,
      CE_USEC  => CE_USEC,
      CE_MSEC  => CE_MSEC,
      CE_INT   => CE_MSEC,
      RESET    => RESET,
      ENAXON   => SWI(1),
      ENAESC   => SWI(1),
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

  RB_SRES_OR : rb_sres_or_3
    port map (
      RB_SRES_1  => RB_SRES_CPU,
      RB_SRES_2  => RB_SRES_IBD,
      RB_SRES_3  => RB_SRES_HIO,
      RB_SRES_OR => RB_SRES
    );
  
  RB2CP : pdp11_core_rbus
    generic map (
      RB_ADDR_CORE => rbaddr_core0,
      RB_ADDR_IBUS => rbaddr_ibus0)
    port map (
      CLK       => CLK,
      RESET     => RESET,
      RB_MREQ   => RB_MREQ,
      RB_SRES   => RB_SRES_CPU,
      RB_STAT   => RB_STAT,
      RB_LAM    => RB_LAM(0),
      CPU_RESET => CPU_RESET,
      CP_CNTL   => CP_CNTL,
      CP_ADDR   => CP_ADDR,
      CP_DIN    => CP_DIN,
      CP_STAT   => CP_STAT,
      CP_DOUT   => CP_DOUT      
    );

  W11A : pdp11_core
    port map (
      CLK       => CLK,
      RESET     => CPU_RESET,
      CP_CNTL   => CP_CNTL,
      CP_ADDR   => CP_ADDR,
      CP_DIN    => CP_DIN,
      CP_STAT   => CP_STAT,
      CP_DOUT   => CP_DOUT,
      EI_PRI    => EI_PRI,
      EI_VECT   => EI_VECT,
      EI_ACKM   => EI_ACKM,
      EM_MREQ   => EM_MREQ,
      EM_SRES   => EM_SRES,
      BRESET    => BRESET,
      IB_MREQ_M => IB_MREQ,
      IB_SRES_M => IB_SRES,
      DM_STAT_DP => DM_STAT_DP,
      DM_STAT_VM => DM_STAT_VM,
      DM_STAT_CO => DM_STAT_CO
    );  
    
  CACHE: pdp11_cache
    port map (
      CLK       => CLK,
      GRESET    => CPU_RESET,
      EM_MREQ   => EM_MREQ,
      EM_SRES   => EM_SRES,
      FMISS     => CACHE_FMISS,
      CHIT      => CACHE_CHIT,
      MEM_REQ   => MEM_REQ,
      MEM_WE    => MEM_WE,
      MEM_BUSY  => MEM_BUSY,
      MEM_ACK_R => MEM_ACK_R,
      MEM_ADDR  => MEM_ADDR,
      MEM_BE    => MEM_BE,
      MEM_DI    => MEM_DI,
      MEM_DO    => MEM_DO
    );

  MEM70: pdp11_mem70
    port map (
      CLK         => CLK,
      CRESET      => BRESET,
      HM_ENA      => HM_ENA,
      HM_VAL      => CACHE_CHIT,
      CACHE_FMISS => MEM70_FMISS,
      IB_MREQ     => IB_MREQ,
      IB_SRES     => IB_SRES_MEM70
    );

  HM_ENA      <= EM_SRES.ack_r or EM_SRES.ack_w;
  CACHE_FMISS <= MEM70_FMISS or sys_conf_cache_fmiss;
  
  BRAM_CTL: pdp11_bram_memctl
    generic map (
      MAWIDTH => sys_conf_memctl_mawidth,
      NBLOCK  => sys_conf_memctl_nblock)
    port map (
      CLK         => CLK,
      RESET       => CPU_RESET,
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

  IB_SRES_OR : ib_sres_or_2
    port map (
      IB_SRES_1  => IB_SRES_MEM70,
      IB_SRES_2  => IB_SRES_IBDR,
      IB_SRES_OR => IB_SRES
    );

  IBDR_SYS : ibdr_maxisys
    port map (
      CLK      => CLK,
      CE_USEC  => CE_USEC,
      CE_MSEC  => CE_MSEC,
      RESET    => CPU_RESET,
      BRESET   => BRESET,
      RB_LAM   => RB_LAM(15 downto 1),
      IB_MREQ  => IB_MREQ,
      IB_SRES  => IB_SRES_IBDR,
      EI_ACKM  => EI_ACKM,
      EI_PRI   => EI_PRI,
      EI_VECT  => EI_VECT,
      DISPREG  => DISPREG
    );

  LED_IO : ioleds_sp1c
    port map (
      SER_MONI => SER_MONI,
      IOLEDS   => DSP_DP
    );

  LED_CPU : pdp11_statleds
    port map (
      MEM_ACT_R  => MEM_ACT_R,
      MEM_ACT_W  => MEM_ACT_W,
      CP_STAT    => CP_STAT,
      DM_STAT_DP => DM_STAT_DP,
      STATLEDS   => STATLEDS
    );
  
  LED_MUX : pdp11_ledmux
    generic map (
      LWIDTH => LED'length)
    port map (
      SEL        => SWI(3),
      STATLEDS   => STATLEDS,
      DM_STAT_DP => DM_STAT_DP,
      LED        => LED
    );
    
  ABCLKDIV <= SER_MONI.abclkdiv(11 downto 0) & '0' & SER_MONI.abclkdiv_f;

  DSP_MUX : pdp11_dspmux
    generic map (
      DCWIDTH => 2)
    port map (
      SEL        => SWI(5 downto 4),
      ABCLKDIV   => ABCLKDIV,
      DM_STAT_DP => DM_STAT_DP,
      DISPREG    => DISPREG,
      DSP_DAT    => DSP_DAT
    );
  
-- synthesis translate_off
  DM_STAT_SY.emmreq <= EM_MREQ;
  DM_STAT_SY.emsres <= EM_SRES;
  DM_STAT_SY.chit   <= CACHE_CHIT;
  
  TMU : pdp11_tmu_sb
    generic map (
      ENAPIN => 13)
    port map (
      CLK        => CLK,
      DM_STAT_DP => DM_STAT_DP,
      DM_STAT_VM => DM_STAT_VM,
      DM_STAT_CO => DM_STAT_CO,
      DM_STAT_SY => DM_STAT_SY
    );
-- synthesis translate_on
  
end syn;
