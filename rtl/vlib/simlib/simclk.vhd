-- $Id: simclk.vhd 1181 2019-07-08 17:00:50Z mueller $
-- SPDX-License-Identifier: GPL-3.0-or-later
-- Copyright 2007-2016 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
--
------------------------------------------------------------------------------
-- Module Name:    simclk - sim
-- Description:    Clock generator for test benches
--
-- Dependencies:   -
-- Test bench:     -
-- Target Devices: generic
-- Tool versions:  xst 8.2-14.7; viv 2016.2; ghdl 0.18-0.33
--
-- Revision History: 
-- Date         Rev Version  Comment
-- 2016-09-03   805   2.0.1  CLK_STOP now optional port
-- 2011-12-23   444   2.0    remove CLK_CYCLE output port
-- 2011-11-18   427   1.0.3  now numeric_std clean
-- 2008-03-24   129   1.0.2  CLK_CYCLE now 31 bits
-- 2007-10-12    88   1.0.1  avoid ieee.std_logic_unsigned, use cast to unsigned
-- 2007-08-10    72   1.0    Initial version 
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use work.slvtypes.all;

entity simclk is                      -- test bench clock generator
  generic (
    PERIOD : Delay_length := 20 ns;   -- clock period
    OFFSET : Delay_length := 200 ns); -- clock offset (first up transition)
  port (
    CLK  : out slbit;                 -- clock
    CLK_STOP : in slbit := '0'        -- clock stop trigger
  );
end entity simclk;

architecture sim of simclk is
begin

  proc_clk: process
    constant clock_halfperiod : Delay_length := PERIOD/2;
  begin

    CLK <= '0';
    wait for OFFSET;

    clk_loop: loop
      CLK <= '1';
      wait for clock_halfperiod;
      CLK <= '0';
      wait for PERIOD-clock_halfperiod;
      exit clk_loop when CLK_STOP = '1';
    end loop;
    
    CLK <= '1';                         -- final clock cycle for clk_sim
    wait for clock_halfperiod;
    CLK <= '0';
    wait for PERIOD-clock_halfperiod;
    
    wait;                               -- endless wait, simulator will stop
    
  end process proc_clk;

end sim;
