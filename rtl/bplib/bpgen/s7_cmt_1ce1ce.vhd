-- $Id: s7_cmt_1ce1ce.vhd 1181 2019-07-08 17:00:50Z mueller $
-- SPDX-License-Identifier: GPL-3.0-or-later
-- Copyright 2018- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
-- 
------------------------------------------------------------------------------
-- Module Name:    s7_cmt_1ce1ce - syn
-- Description:    clocking block for 7-Series: 2 clk with CEs
--
-- Dependencies:   s7_cmt_sfs
--                 clkdivce
-- Test bench:     -
-- Target Devices: generic 7-Series
-- Tool versions:  viv 2017.2; ghdl 0.34
--
-- Revision History: 
-- Date         Rev Version  Comment
-- 2018-12-16  1086   1.0    Initial version 
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

use work.slvtypes.all;
use work.xlib.all;
use work.genlib.all;

entity s7_cmt_1ce1ce  is                -- clocking block: 2 clk with CEs
  generic (
    CLKIN_PERIOD  : real := 10.0;       -- CLKIN period (def is 10.0 ns)
    CLKIN_JITTER  : real := 0.01;       -- CLKIN jitter (def is 10 ps)
    STARTUP_WAIT  : boolean := false;   -- hold FPGA startup till LOCKED
    CLK0_VCODIV   : positive := 1;      -- clk0: vco clock divide
    CLK0_VCOMUL   : positive := 1;      -- clk0: vco clock multiply 
    CLK0_OUTDIV   : positive := 1;      -- clk0: output divide
    CLK0_GENTYPE  : string := "PLL";    -- clk0: PLL or MMCM
    CLK0_CDUWIDTH : positive :=   7;    -- clk0: usec clock divider width
    CLK0_USECDIV  : positive :=  50;    -- clk0: divider ratio for usec pulse
    CLK0_MSECDIV  : positive := 1000;   -- clk0: divider ratio for msec pulse
    CLK1_VCODIV   : positive := 1;      -- clk1: vco clock divide
    CLK1_VCOMUL   : positive := 1;      -- clk1: vco clock multiply 
    CLK1_OUTDIV   : positive := 1;      -- clk1: output divide
    CLK1_GENTYPE  : string := "MMCM";   -- clk1: PLL or MMCM
    CLK1_CDUWIDTH : positive :=   7;    -- clk1: usec clock divider width
    CLK1_USECDIV  : positive :=  50;    -- clk1: divider ratio for usec pulse
    CLK1_MSECDIV  : positive := 1000);  -- clk1: divider ratio for msec pulse
  port (
    CLKIN    : in slbit;                -- clock input
    CLK0     : out slbit;               -- clk0: clock output
    CE0_USEC : out slbit;               -- clk0: usec pulse
    CE0_MSEC : out slbit;               -- clk0: msec pulse
    CLK1     : out slbit;               -- clk1: clock output
    CE1_USEC : out slbit;               -- clk1: usec pulse
    CE1_MSEC : out slbit;               -- clk1: msec pulse
    LOCKED   : out slbit                -- all PLL/MMCM locked
  );
end s7_cmt_1ce1ce;

architecture syn of s7_cmt_1ce1ce is
  
  signal CLK0_L  : slbit := '0';
  signal CLK1_L  : slbit := '0';
  signal LOCKED0 : slbit := '0';
  signal LOCKED1 : slbit := '0';

begin

  GEN_CLK0 : s7_cmt_sfs                 -- clock generator 0 -----------------
    generic map (
      VCO_DIVIDE     => CLK0_VCODIV,
      VCO_MULTIPLY   => CLK0_VCOMUL,
      OUT_DIVIDE     => CLK0_OUTDIV,
      CLKIN_PERIOD   => CLKIN_PERIOD,
      CLKIN_JITTER   => CLKIN_JITTER,
      STARTUP_WAIT   => STARTUP_WAIT,
      GEN_TYPE       => CLK0_GENTYPE)
    port map (
      CLKIN   => CLKIN,
      CLKFX   => CLK0_L,
      LOCKED  => LOCKED0
    );

  DIV_CLK0 : clkdivce                   -- usec/msec clock divider 0 ---------
    generic map (
      CDUWIDTH => CLK0_CDUWIDTH,
      USECDIV  => CLK0_USECDIV,
      MSECDIV  => CLK0_MSECDIV)
    port map (
      CLK     => CLK0_L,
      CE_USEC => CE0_USEC,
      CE_MSEC => CE0_MSEC
    );

  GEN_CLK1 : s7_cmt_sfs                 -- clock generator serport -----------
    generic map (
      VCO_DIVIDE     => CLK1_VCODIV,
      VCO_MULTIPLY   => CLK1_VCOMUL,
      OUT_DIVIDE     => CLK1_OUTDIV,
      CLKIN_PERIOD   => CLKIN_PERIOD,
      CLKIN_JITTER   => CLKIN_JITTER,
      STARTUP_WAIT   => STARTUP_WAIT,
      GEN_TYPE       => CLK1_GENTYPE)
    port map (
      CLKIN   => CLKIN,
      CLKFX   => CLK1_L,
      LOCKED  => LOCKED1
    );

  DIV_CLK1 : clkdivce                   -- usec/msec clock divider 1 ---------
    generic map (
      CDUWIDTH => CLK1_CDUWIDTH,
      USECDIV  => CLK1_USECDIV,
      MSECDIV  => CLK1_MSECDIV)
    port map (
      CLK     => CLK1_L,
      CE_USEC => CE1_USEC,
      CE_MSEC => CE1_MSEC
    );

  CLK0   <= CLK0_L;
  CLK1   <= CLK1_L;
  LOCKED <= LOCKED0 and LOCKED1;
  
end syn;
