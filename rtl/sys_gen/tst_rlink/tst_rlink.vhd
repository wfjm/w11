-- $Id: tst_rlink.vhd 385 2011-06-26 22:10:57Z mueller $
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
-- Module Name:    tst_rlink - syn
-- Description:    tester for rlink
--
-- Dependencies:   rlink/rlink_base_serport
--                 rbus/rbd_tester
--                 rbus/rbd_bram
--                 rbus/rbd_rbmon
--                 rbus/rbd_eyemon
--                 rbus/rbd_timer
--                 rbus/rb_sres_or_4
--
-- Test bench:     nexys2/tb/tb_tst_rlink_n2
--
-- Target Devices: generic
-- Tool versions:  xst 12.1; ghdl 0.29
--
-- Revision History: 
-- Date         Rev Version  Comment
-- 2011-06-26   385   1.1    remove s3_humanio_rbus (will be in board design);
--                           remove hio interface ports, add rbus ports
-- 2011-04-02   375   1.0.1  add rbd_eyemon and two timer
-- 2010-12-29   351   1.0    Initial version (inspired by sys_tst_rri)
------------------------------------------------------------------------------
-- Usage of STAT signal:
--   STAT(0):   timer 0 busy 
--   STAT(1):   timer 1 busy 
--   STAT(2:7): unused

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

use work.slvtypes.all;
use work.rblib.all;
use work.rbdlib.all;
use work.rlinklib.all;

-- ----------------------------------------------------------------------------

entity tst_rlink is                     -- tester for rlink
  generic (
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
    RB_MREQ_TOP : out rb_mreq_type;     -- rbus: request  to top
    RB_SRES_TOP : in rb_sres_type;      -- rbus: response from top
    RL_SER_MONI: out rl_ser_moni_type;  -- rlink monitor
    STAT : out slv8                     -- status flags
  );
end tst_rlink;

architecture syn of tst_rlink is

  signal RB_MREQ       : rb_mreq_type := rb_mreq_init;
  signal RB_SRES       : rb_sres_type := rb_sres_init;
  signal RB_SRES_TEST  : rb_sres_type := rb_sres_init;
  signal RB_SRES_BRAM  : rb_sres_type := rb_sres_init;
  signal RB_SRES_MON   : rb_sres_type := rb_sres_init;
  signal RB_SRES_EMON  : rb_sres_type := rb_sres_init;
  signal RB_SRES_TIM0  : rb_sres_type := rb_sres_init;
  signal RB_SRES_TIM1  : rb_sres_type := rb_sres_init;
  signal RB_SRES_SUM1  : rb_sres_type := rb_sres_init;

  signal RB_LAM  : slv16 := (others=>'0');
  signal RB_STAT :  slv3 := (others=>'0');

  signal RB_LAM_TEST : slv16 := (others=>'0');

  signal TIM0_DONE : slbit := '0';
  signal TIM0_BUSY : slbit := '0';
  signal TIM1_DONE : slbit := '0';
  signal TIM1_BUSY : slbit := '0';

  signal RL_MONI : rl_moni_type := rl_moni_init;
  signal RL_SER_MONI_L : rl_ser_moni_type := rl_ser_moni_init;

  constant rbaddr_mon   : slv8 := "11111100"; -- 111111xx
  constant rbaddr_emon  : slv8 := "11111000"; -- 111110xx
  constant rbaddr_bram  : slv8 := "11110100"; -- 111101xx
  constant rbaddr_test  : slv8 := "11110000"; -- 111100xx
  constant rbaddr_tim1  : slv8 := "11100001"; -- 11100001
  constant rbaddr_tim0  : slv8 := "11100000"; -- 11100000
  
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
      RTS_N    => RTS_N,
      RB_MREQ  => RB_MREQ,
      RB_SRES  => RB_SRES,
      RB_LAM   => RB_LAM,
      RB_STAT  => RB_STAT,
      RL_MONI  => RL_MONI,
      RL_SER_MONI => RL_SER_MONI_L
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
      RXACT       => RL_SER_MONI_L.rxact
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

  RB_SRES_OR1 : rb_sres_or_4
    port map (
      RB_SRES_1  => RB_SRES_TEST,
      RB_SRES_2  => RB_SRES_BRAM,
      RB_SRES_3  => RB_SRES_MON,
      RB_SRES_4  => RB_SRES_TOP,
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

  RB_MREQ_TOP <= RB_MREQ;
  RL_SER_MONI <= RL_SER_MONI_L;

  STAT(0) <= TIM0_BUSY;
  STAT(1) <= TIM1_BUSY;
  STAT(7 downto 2) <= (others=>'0');
    
end syn;
