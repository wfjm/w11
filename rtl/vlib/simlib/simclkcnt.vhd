-- $Id: simclkcnt.vhd 1181 2019-07-08 17:00:50Z mueller $
-- SPDX-License-Identifier: GPL-3.0-or-later
-- Copyright 2011- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
--
------------------------------------------------------------------------------
-- Module Name:    simclkcnt - sim
-- Description:    test bench system clock cycle counter
--
-- Dependencies:   -
-- Test bench:     -
-- Target Devices: generic
-- Tool versions:  xst 12.1-14.7; viv 2016.2; ghdl 0.29-0.33
--
-- Revision History: 
-- Date         Rev Version  Comment
-- 2011-12-23   444   2.0    CLK_CYCLE now an integer
-- 2011-11-12   423   1.0.1  now numeric_std clean
-- 2010-11-13    72   1.0    Initial version 
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use work.slvtypes.all;

entity simclkcnt is                   -- test bench system clock cycle counter
  port (
    CLK  : in slbit;                  -- clock
    CLK_CYCLE  : out integer          -- clock cycle number
  );
end entity simclkcnt;

architecture sim of simclkcnt is
  signal R_CLKCNT : integer := 0;
begin

  proc_clk: process (CLK)
  begin

    if rising_edge(CLK) then
      R_CLKCNT <= R_CLKCNT + 1;
    end if;
    
  end process proc_clk;

  CLK_CYCLE <= R_CLKCNT;
  
end sim;
