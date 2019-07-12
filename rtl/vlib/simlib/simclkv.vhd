-- $Id: simclkv.vhd 1181 2019-07-08 17:00:50Z mueller $
-- SPDX-License-Identifier: GPL-3.0-or-later
-- Copyright 2007-2016 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
--
------------------------------------------------------------------------------
-- Module Name:    simclkv - sim
-- Description:    Clock generator for test benches, variable period
--
-- Dependencies:   -
-- Test bench:     -
-- Target Devices: generic
-- Tool versions:  xst 8.2-14.7; viv 2016.2; ghdl 0.18-0.33
-- Revision History: 
-- Date         Rev Version  Comment
-- 2016-09-03   805   2.0.1  CLK_STOP,CLK_HOLD now optional ports
-- 2011-12-23   444   2.0    remove CLK_CYCLE output port
-- 2011-11-21   432   1.0.2  now numeric_std clean
-- 2008-03-24   129   1.0.1  CLK_CYCLE now 31 bits
-- 2007-12-27   106   1.0    Initial version 
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.slvtypes.all;

entity simclkv is                     -- test bench clock generator
                                      --   with variable period
  port (
    CLK  : out slbit;                 -- clock
    CLK_PERIOD : in Delay_length;     -- clock period
    CLK_HOLD : in slbit := '0';       -- if 1, hold clocks in 0 state
    CLK_STOP : in slbit := '0'        -- clock stop trigger
  );
end entity simclkv;


architecture sim of simclkv is
begin

  clk_proc: process
    variable half_period : Delay_length := 0 ns;
  begin

    CLK <= '0';

    clk_loop: loop
      
      if CLK_HOLD = '1' then
        wait until CLK_HOLD='0';
      end if;
      half_period := CLK_PERIOD/2;
      
      CLK <= '1';
      wait for half_period;
      CLK <= '0';
      wait for CLK_PERIOD-half_period;
      exit clk_loop when CLK_STOP = '1';
    end loop;
    
    CLK <= '1';                         -- final clock cycle for clk_sim
    wait for CLK_PERIOD/2;
    CLK <= '0';
    wait for CLK_PERIOD-CLK_PERIOD/2;
    
    wait;                               -- endless wait, simulator will stop
    
  end process;

end sim;
