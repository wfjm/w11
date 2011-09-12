-- $Id: sys_tst_rlink_n2.vhd 406 2011-08-14 21:06:44Z mueller $
--
-- Copyright 2010-2011 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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
-- Module Name:    sys_tst_rlink_n2 - syn
-- Description:    rlink tester design for nexys2
--
-- Dependencies:   vlib/xlib/dcm_sp_sfs
--                 vlib/genlib/clkdivce
--                 bplib/bpgen/bp_rs232_2l4l_iob
--                 bplib/bpgen/sn_humanio_rbus
--                 tst_rlink
--                 vlib/nexys2/n2_cram_dummy
--
-- Test bench:     tb/tb_tst_rlink_n2
--
-- Target Devices: generic
-- Tool versions:  xst 12.1; ghdl 0.29
--
-- Synthesized (xst):
-- Date         Rev  ise         Target      flop lutl lutm slic t peri
-- 2011-06-26   385 12.1    M53d xc3s1200e-4  688 1500   68  993 t 16.2
-- 2011-04-02   375 12.1    M53d xc3s1200e-4  688 1572   68  994 t 13.8
-- 2010-12-29   351 12.1    M53d xc3s1200e-4  604 1298   68  851 t 14.7
--
-- Revision History: 
-- Date         Rev Version  Comment
-- 2011-07-09   391   1.1.2  use now bp_rs232_2l4l_iob
-- 2011-07-08   390   1.1.1  use now sn_humanio
-- 2011-06-26   385   1.1    move s3_humanio_rbus from tst_rlink to top level
-- 2010-12-29   351   1.0    Initial version
------------------------------------------------------------------------------
-- Usage of Nexys 2 Switches, Buttons, LEDs:
--
--    SWI(0):   0 -> main board RS232 port  - implemented in bp_rs232_2l4l_iob
--              1 -> Pmod B/top RS232 port  /
--       (1:7): no function (only connected to s3_humanio_rbus)
--
--    LED(0):   timer 0 busy 
--    LED(1):   timer 1 busy 
--    LED(2:6): no function (only connected to s3_humanio_rbus)
--    LED(7):   RL_SER_MONI.abact
--
--    DSP:      RL_SER_MONI.clkdiv  (from auto bauder)
--    DP(0):    RL_SER_MONI.rxact
--    DP(1):    RTS_N  (shows rx back preasure)
--    DP(2):    RL_SER_MONI.txact
--    DP(3):    CTS_N  (shows tx back preasure)
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

use work.slvtypes.all;
use work.xlib.all;
use work.genlib.all;
use work.rblib.all;
use work.rlinklib.all;
use work.bpgenlib.all;
use work.nexys2lib.all;
use work.sys_conf.all;

-- ----------------------------------------------------------------------------

entity sys_tst_rlink_n2 is              -- top level
                                        -- implements nexys2_fusp_aif
  port (
    I_CLK50 : in slbit;                 -- 50 MHz clock
    O_CLKSYS : out slbit;               -- DCM derived system clock
    I_RXD : in slbit;                   -- receive data (board view)
    O_TXD : out slbit;                  -- transmit data (board view)
    I_SWI : in slv8;                    -- s3 switches
    I_BTN : in slv4;                    -- s3 buttons
    O_LED : out slv8;                   -- s3 leds
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
    O_FLA_CE_N : out slbit;             -- flash ce..          (act.low)
    O_MEM_ADDR  : out slv23;            -- cram: address lines
    IO_MEM_DATA : inout slv16;          -- cram: data lines
    O_FUSP_RTS_N : out slbit;           -- fusp: rs232 rts_n
    I_FUSP_CTS_N : in slbit;            -- fusp: rs232 cts_n
    I_FUSP_RXD : in slbit;              -- fusp: rs232 rx
    O_FUSP_TXD : out slbit              -- fusp: rs232 tx
  );
end sys_tst_rlink_n2;

architecture syn of sys_tst_rlink_n2 is

  signal CLK :   slbit := '0';

  signal RXD :   slbit := '1';
  signal TXD :   slbit := '0';
  signal RTS_N : slbit := '0';
  signal CTS_N : slbit := '0';
    
  signal SWI     : slv8  := (others=>'0');
  signal BTN     : slv4  := (others=>'0');
  signal LED     : slv8  := (others=>'0');
  signal DSP_DAT : slv16 := (others=>'0');
  signal DSP_DP  : slv4  := (others=>'0');

  signal RESET   : slbit := '0';
  signal CE_USEC : slbit := '0';
  signal CE_MSEC : slbit := '0';

  signal RB_MREQ_TOP : rb_mreq_type := rb_mreq_init;
  signal RB_SRES_TOP : rb_sres_type := rb_sres_init;
  signal RL_SER_MONI : rl_ser_moni_type := rl_ser_moni_init;
  signal STAT    : slv8  := (others=>'0');

  constant rbaddr_hio   : slv8 := "11000000"; -- 110000xx

begin

  assert (sys_conf_clksys mod 1000000) = 0
    report "assert sys_conf_clksys on MHz grid"
    severity failure;

  RESET <= '0';                         -- so far not used
  
  DCM : dcm_sp_sfs
    generic map (
      CLKFX_DIVIDE   => sys_conf_clkfx_divide,
      CLKFX_MULTIPLY => sys_conf_clkfx_multiply,
      CLKIN_PERIOD   => 20.0)
    port map (
      CLKIN   => I_CLK50,
      CLKFX   => CLK,
      LOCKED  => open
    );

  O_CLKSYS <= CLK;

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

  IOB_RS232 : bp_rs232_2l4l_iob
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

  HIO : sn_humanio_rbus
    generic map (
      DEBOUNCE => sys_conf_hio_debounce,
      RB_ADDR  => rbaddr_hio)
    port map (
      CLK     => CLK,
      RESET   => RESET,
      CE_MSEC => CE_MSEC,
      RB_MREQ => RB_MREQ_TOP,
      RB_SRES => RB_SRES_TOP,
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

  RLTEST : entity work.tst_rlink
    generic map (
      CDINIT   => sys_conf_ser2rri_cdinit)
    port map (
      CLK         => CLK,
      RESET       => RESET,
      CE_USEC     => CE_USEC,
      CE_MSEC     => CE_MSEC,
      RXD         => RXD,
      TXD         => TXD,
      CTS_N       => CTS_N,
      RTS_N       => RTS_N,
      RB_MREQ_TOP => RB_MREQ_TOP,
      RB_SRES_TOP => RB_SRES_TOP,
      RL_SER_MONI => RL_SER_MONI,
      STAT        => STAT
    );

  SRAM_PROT : n2_cram_dummy            -- connect CRAM to protection dummy
    port map (
      O_MEM_CE_N  => O_MEM_CE_N,
      O_MEM_BE_N  => O_MEM_BE_N,
      O_MEM_WE_N  => O_MEM_WE_N,
      O_MEM_OE_N  => O_MEM_OE_N,
      O_MEM_ADV_N => O_MEM_ADV_N,
      O_MEM_CLK   => O_MEM_CLK,
      O_MEM_CRE   => O_MEM_CRE,
      I_MEM_WAIT  => I_MEM_WAIT,
      O_FLA_CE_N  => O_FLA_CE_N,
      O_MEM_ADDR  => O_MEM_ADDR,
      IO_MEM_DATA => IO_MEM_DATA
    );

  DSP_DAT   <= RL_SER_MONI.clkdiv;
  DSP_DP(0) <= RL_SER_MONI.rxact;
  DSP_DP(1) <= RTS_N;
  DSP_DP(2) <= RL_SER_MONI.txact;
  DSP_DP(3) <= CTS_N;

  LED(7) <= RL_SER_MONI.abact;
  LED(6 downto 2) <= (others=>'0');
  LED(1) <= STAT(1);
  LED(0) <= STAT(0);
   
end syn;
