-- $Id: tst_rlink.vhd 375 2011-04-02 07:56:47Z mueller $
--
-- Copyright 2010- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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
-- Module Name:    tst_rlink - syn
-- Description:    tester for rlink
--
-- Dependencies:   rlink/rlink_base_serport
--                 rbus/rbd_tester
--                 rbus/rbd_bram
--                 rbus/rbd_rbmon
--                 rbus/rbd_eyemon
--                 rbus/rbd_timer
--                 s3board/s3_humanio_rbus
--                 rbus/rb_sres_or_4
--
-- Test bench:     nexys2/tb/tb_tst_rlink_n2
--
-- Target Devices: generic
-- Tool versions:  xst 12.1; ghdl 0.29
--
-- Revision History: 
-- Date         Rev Version  Comment
-- 2011-04-02   375   1.0.1  add rbd_eyemon and two timer
-- 2010-12-29   351   1.0    Initial version (inspired by sys_tst_rri)
------------------------------------------------------------------------------
-- Usage of Nexys 2 Switches, Buttons, LEDs:
--
--    SWI(0):   0 -> main board RS232 port  - implemented in sys_tst_rlink_*
--              1 -> Pmod B/top RS232 port  /
--       (1:7): no function (only connected to s3_humanio_rbus)
--
--    LED(0):   timer 0 busy 
--    LED(1):   timer 1 busy 
--    LED(2:7): no function (only connected to s3_humanio_rbus)
--
--    DSP:      RL_SER_MONI.clkdiv  (from auto bauder)
--    DP(0):    RXSD   (inverted to signal activity)
--    DP(1):    RTS_N  (shows rx back preasure)
--    DP(2):    TXSD   (inverted to signal activity)
--    DP(3):    CTS_N  (shows tx back preasure)

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

use work.slvtypes.all;
use work.rblib.all;
use work.rbdlib.all;
use work.rlinklib.all;
use work.s3boardlib.all;

-- ----------------------------------------------------------------------------

entity tst_rlink is                     -- tester for rlink
  generic (
    DEBOUNCE : boolean := true;
    CDINIT : natural := 15);
  port (
    CLK : in slbit;                     -- clock
    RESET : in slbit;                   -- reset
    CE_USEC : in slbit;                 -- usec pulse
    CE_MSEC : in slbit;                 -- msec pulse
    RXD : in slbit;                     -- receive data (board view)
    TXD : out slbit;                    -- transmit data (board view)
    CTS_N : in slbit;                   -- rs232 cts_n
    RTS_N : out slbit;                  -- rs232 rts_n
    SWI : out slv8;                     -- switches (for top cntl)
    BTN : out slv4;                     -- buttons  (for top cntl)
    I_SWI : in slv8;                    -- s3 switches
    I_BTN : in slv4;                    -- s3 buttons
    O_LED : out slv8;                   -- s3 leds
    O_ANO_N : out slv4;                 -- 7 segment disp: anodes   (act.low)
    O_SEG_N : out slv8                  -- 7 segment disp: segments (act.low)
  );
end tst_rlink;

architecture syn of tst_rlink is

  signal RTS_N_L : slbit := '0';
  signal DSP_DAT : slv16 := (others=>'0');
  signal DSP_DP  : slv4  := (others=>'0');

  signal SWI_L : slv8  := (others=>'0');
  signal BTN_L : slv4  := (others=>'0');
  signal LED :   slv8  := (others=>'0');

  signal RB_MREQ       : rb_mreq_type := rb_mreq_init;
  signal RB_SRES       : rb_sres_type := rb_sres_init;
  signal RB_SRES_TEST  : rb_sres_type := rb_sres_init;
  signal RB_SRES_BRAM  : rb_sres_type := rb_sres_init;
  signal RB_SRES_MON   : rb_sres_type := rb_sres_init;
  signal RB_SRES_EMON  : rb_sres_type := rb_sres_init;
  signal RB_SRES_TIM0  : rb_sres_type := rb_sres_init;
  signal RB_SRES_TIM1  : rb_sres_type := rb_sres_init;
  signal RB_SRES_HIO   : rb_sres_type := rb_sres_init;
  signal RB_SRES_SUM1  : rb_sres_type := rb_sres_init;

  signal RB_LAM  : slv16 := (others=>'0');
  signal RB_STAT :  slv3 := (others=>'0');

  signal RB_LAM_TEST : slv16 := (others=>'0');

  signal TIM0_DONE : slbit := '0';
  signal TIM0_BUSY : slbit := '0';
  signal TIM1_DONE : slbit := '0';
  signal TIM1_BUSY : slbit := '0';

  signal RL_MONI : rl_moni_type := rl_moni_init;
  signal RL_SER_MONI : rl_ser_moni_type := rl_ser_moni_init;

  constant rbaddr_mon   : slv8 := "11111100"; -- 111111xx
  constant rbaddr_emon  : slv8 := "11111000"; -- 111110xx
  constant rbaddr_bram  : slv8 := "11110100"; -- 111101xx
  constant rbaddr_test  : slv8 := "11110000"; -- 111100xx
  constant rbaddr_tim1  : slv8 := "11100001"; -- 11100001
  constant rbaddr_tim0  : slv8 := "11100000"; -- 11100000
  constant rbaddr_hio   : slv8 := "11000000"; -- 110000xx
  
begin

  RLINK : rlink_base_serport
    generic map (
      ATOWIDTH =>  6,                   -- 64 cycles access timeout
      ITOWIDTH =>  6,                   -- 64 periods max idle timeout
      CPREF    => c_rlink_cpref,
      IFAWIDTH =>  5,
      OFAWIDTH =>  0,
      ENAPIN_RLMON => sbcntl_sbf_rlmon,
      ENAPIN_RBMON => sbcntl_sbf_rbmon,
      RB_ADDR  => conv_std_logic_vector(2#11111110#,8),
      CDWIDTH  => 13,
      CDINIT   => CDINIT)
    port map (
      CLK      => CLK,
      CE_USEC  => CE_USEC,
      CE_MSEC  => CE_MSEC,
      CE_INT   => CE_MSEC,
      RESET    => RESET,
      RXSD     => RXD,
      TXSD     => TXD,
      CTS_N    => CTS_N,
      RTS_N    => RTS_N_L,
      RB_MREQ  => RB_MREQ,
      RB_SRES  => RB_SRES,
      RB_LAM   => RB_LAM,
      RB_STAT  => RB_STAT,
      RL_MONI  => RL_MONI,
      RL_SER_MONI => RL_SER_MONI
    );

  RB_LAM(15 downto 2) <= RB_LAM_TEST(15 downto 2);
  RB_LAM(1)           <= TIM1_DONE;
  RB_LAM(0)           <= TIM0_DONE;
  
  TEST : rbd_tester
    generic map (
      RB_ADDR => rbaddr_test)
    port map (
      CLK      => CLK,
      RESET    => RESET,
      RB_MREQ  => RB_MREQ,
      RB_SRES  => RB_SRES_TEST,
      RB_LAM   => RB_LAM_TEST,
      RB_STAT  => RB_STAT
    );
  
  BRAM : rbd_bram
    generic map (
      RB_ADDR => rbaddr_bram)
    port map (
      CLK      => CLK,
      RESET    => RESET,
      RB_MREQ  => RB_MREQ,
      RB_SRES  => RB_SRES_BRAM
    );
  
  MON : rbd_rbmon
    generic map (
      RB_ADDR => rbaddr_mon,
      AWIDTH  => 9)
    port map (
      CLK         => CLK,
      RESET       => RESET,
      RB_MREQ     => RB_MREQ,
      RB_SRES     => RB_SRES_MON,
      RB_SRES_SUM => RB_SRES
    );

  EMON : rbd_eyemon
    generic map (
      RB_ADDR => rbaddr_emon,
      RDIV    => conv_std_logic_vector(0,8))
    port map (
      CLK         => CLK,
      RESET       => RESET,
      RB_MREQ     => RB_MREQ,
      RB_SRES     => RB_SRES_EMON,
      RXSD        => RXD,
      RXACT       => RL_SER_MONI.rxact
    );

  TIM0 : rbd_timer
    generic map (
      RB_ADDR => rbaddr_tim0)
    port map (
      CLK         => CLK,
      CE_USEC     => CE_USEC,
      RESET       => RESET,
      RB_MREQ     => RB_MREQ,
      RB_SRES     => RB_SRES_TIM0,
      DONE        => TIM0_DONE,
      BUSY        => TIM0_BUSY
    );

  TIM1 : rbd_timer
    generic map (
      RB_ADDR => rbaddr_tim1)
    port map (
      CLK         => CLK,
      CE_USEC     => CE_USEC,
      RESET       => RESET,
      RB_MREQ     => RB_MREQ,
      RB_SRES     => RB_SRES_TIM1,
      DONE        => TIM1_DONE,
      BUSY        => TIM1_BUSY
    );

  HIO : s3_humanio_rbus
    generic map (
      DEBOUNCE => DEBOUNCE,
      RB_ADDR  => rbaddr_hio)
    port map (
      CLK     => CLK,
      RESET   => RESET,
      CE_MSEC => CE_MSEC,
      RB_MREQ => RB_MREQ,
      RB_SRES => RB_SRES_HIO,
      SWI     => SWI_L,                   
      BTN     => BTN_L,                   
      LED     => LED,                   
      DSP_DAT => DSP_DAT,               
      DSP_DP  => DSP_DP,
      I_SWI   => I_SWI,                 
      I_BTN   => I_BTN,
      O_LED   => O_LED,
      O_ANO_N => O_ANO_N,
      O_SEG_N => O_SEG_N
    );

  RB_SRES_OR1 : rb_sres_or_4
    port map (
      RB_SRES_1  => RB_SRES_TEST,
      RB_SRES_2  => RB_SRES_BRAM,
      RB_SRES_3  => RB_SRES_MON,
      RB_SRES_4  => RB_SRES_HIO,
      RB_SRES_OR => RB_SRES_SUM1
    );

  RB_SRES_OR : rb_sres_or_4
    port map (
      RB_SRES_1  => RB_SRES_SUM1,
      RB_SRES_2  => RB_SRES_EMON,
      RB_SRES_3  => RB_SRES_TIM0,
      RB_SRES_4  => RB_SRES_TIM1,
      RB_SRES_OR => RB_SRES
    );

  DSP_DAT   <= RL_SER_MONI.clkdiv;
  DSP_DP(0) <= RL_SER_MONI.rxact;
  DSP_DP(1) <= RTS_N_L;
  DSP_DP(2) <= RL_SER_MONI.txact;
  DSP_DP(3) <= CTS_N;

  LED(0) <= TIM0_BUSY;
  LED(1) <= TIM1_BUSY;
  LED(7) <= RL_SER_MONI.abact;
  
  RTS_N <= RTS_N_L;
  SWI   <= SWI_L;
  BTN   <= BTN_L;
  
end syn;
