-- $Id: sys_tst_snhumanio_n4d.vhd 1247 2022-07-06 07:04:33Z mueller $
-- SPDX-License-Identifier: GPL-3.0-or-later
-- Copyright 2017-2022 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
--
------------------------------------------------------------------------------
-- Module Name:    sys_tst_snhumanio_n4d - syn
-- Description:    snhumanio tester design for nexys4d
--
-- Dependencies:   vlib/genlib/clkdivce
--                 bplib/bpgen/sn_humanio
--                 tst_snhumanio
--
-- Test bench:     -
--
-- Target Devices: generic
-- Tool versions:  viv 2016.2-2022.1; ghdl 0.31-2.0.0
--
-- Synthesized:
-- Date         Rev  viv    Target       flop  lutl  lutm  bram  slic
-- 2022-07-05  1247 2022.1  xc7a100t-1    154   164     0     0    67
-- 2019-02-02  1108 2018.3  xc7a100t-1    154   187     0     0    74  
-- 2019-02-02  1108 2017.2  xc7a100t-1    154   185     0     0    68  
--
-- Revision History: 
-- Date         Rev Version  Comment
-- 2017-01-04   838   1.0    Initial version
------------------------------------------------------------------------------
-- Usage of Nexys 4DDR Switches, Buttons, LEDs:
--

library ieee;
use ieee.std_logic_1164.all;

use work.slvtypes.all;
use work.genlib.all;
use work.bpgenlib.all;
use work.sys_conf.all;

-- ----------------------------------------------------------------------------

entity sys_tst_snhumanio_n4d is         -- top level
                                        -- implements nexys4d_aif
  port (
    I_CLK100 : in slbit;                -- 100  MHz clock
    I_RXD : in slbit;                   -- receive data (board view)
    O_TXD : out slbit;                  -- transmit data (board view)
    O_RTS_N : out slbit;                -- rx rts (board view; act.low)
    I_CTS_N : in slbit;                 -- tx cts (board view; act.low)
    I_SWI : in slv16;                   -- n4d switches
    I_BTN : in slv5;                    -- n4d buttons
    I_BTNRST_N : in slbit;              -- n4d reset button
    O_LED : out slv16;                  -- n4d leds
    O_RGBLED0 : out slv3;               -- n4d rgb-led 0
    O_RGBLED1 : out slv3;               -- n4d rgb-led 1
    O_ANO_N : out slv8;                 -- 7 segment disp: anodes   (act.low)
    O_SEG_N : out slv8                  -- 7 segment disp: segments (act.low)
  );
end sys_tst_snhumanio_n4d;

architecture syn of sys_tst_snhumanio_n4d is

  signal CLK :   slbit := '0';

  signal SWI     : slv8  := (others=>'0');
  signal BTN     : slv5  := (others=>'0');
  signal LED     : slv8  := (others=>'0');
  signal DSP_DAT : slv16 := (others=>'0');
  signal DSP_DP  : slv4  := (others=>'0');

  signal RESET   : slbit := '0';
  signal CE_MSEC : slbit := '0';

begin

  RESET <= '0';                         -- so far not used
  
  CLK <= I_CLK100;

  CLKDIV : clkdivce
    generic map (
      CDUWIDTH => 7,
      USECDIV  => 100,
      MSECDIV  => 1000)
    port map (
      CLK     => CLK,
      CE_USEC => open,
      CE_MSEC => CE_MSEC
    );

  HIO : sn_humanio
    generic map (
      BWIDTH   => 5,
      DEBOUNCE => sys_conf_hio_debounce)
    port map (
      CLK     => CLK,
      RESET   => RESET,
      CE_MSEC => CE_MSEC,
      SWI     => SWI,                   
      BTN     => BTN,                   
      LED     => LED,                   
      DSP_DAT => DSP_DAT,               
      DSP_DP  => DSP_DP,
      I_SWI   => I_SWI(7 downto 0),                 
      I_BTN   => I_BTN,
      O_LED   => O_LED(7 downto 0),
      O_ANO_N => O_ANO_N(3 downto 0),
      O_SEG_N => O_SEG_N
    );

  HIOTEST : entity work.tst_snhumanio
    generic map (
      BWIDTH => 5)
    port map (
      CLK     => CLK,
      RESET   => RESET,
      CE_MSEC => CE_MSEC,
      SWI     => SWI,
      BTN     => BTN,
      LED     => LED,
      DSP_DAT => DSP_DAT,
      DSP_DP  => DSP_DP
    );

  O_TXD   <= I_RXD;
  O_RTS_N <= I_CTS_N;

  O_LED(15 downto 8)  <= not I_SWI(15 downto 8);
  O_ANO_N(7 downto 4) <= (others=>'1');

  O_RGBLED0 <= (others=>'0');
  O_RGBLED1 <= (others=>not I_BTNRST_N);
  
end syn;
