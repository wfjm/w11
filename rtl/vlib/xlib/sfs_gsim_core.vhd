-- $Id: sfs_gsim_core.vhd 1181 2019-07-08 17:00:50Z mueller $
-- SPDX-License-Identifier: GPL-3.0-or-later
-- Copyright 2018- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
--
------------------------------------------------------------------------------
-- Module Name:    sfs_gsim_core - sim
-- Description:    simple frequency synthesis (SIM only!)
--                 simple vhdl model, without Xilinx UNISIM primitives
--
-- Dependencies:   -
-- Test bench:     -
-- Target Devices: generic
-- Tool versions:  xst 14.7; viv 2015.4-2018.2; ghdl 0.31-0.34
--
-- Revision History: 
-- Date         Rev Version  Comment
-- 2018-11-03  1064   1.0    Initial version (derived from s7_cmt_sfs_gsim)
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

use work.slvtypes.all;

entity sfs_gsim_core is                 -- frequency synthesis for simulation
  generic (
    VCO_DIVIDE   : positive := 1;       -- vco clock divide
    VCO_MULTIPLY : positive := 1;       -- vco clock multiply 
    OUT_DIVIDE   : positive := 1);      -- output divide
  port (
    CLKIN  : in slbit;                  -- clock input
    CLKFX  : out slbit;                 -- clock output (synthesized freq.) 
    LOCKED : out slbit                  -- pll/mmcm locked
  );
end sfs_gsim_core;


architecture sim of sfs_gsim_core is
  signal CLK_DIVPULSE : slbit := '0';
  signal CLKOUT_PERIOD : Delay_length := 0 ns;
  signal R_CLKOUT : slbit := '0';
  signal R_LOCKED : slbit := '0';
  
begin

  proc_clkin : process (CLKIN)
    variable t_lastclkin : time := 0 ns;
    variable t_lastperiod : Delay_length := 0 ns;
    variable t_period : Delay_length := 0 ns;
    variable nclkin : integer := 1;
  begin
    
    if CLKIN'event then
      if CLKIN = '1' then               -- if CLKIN rising edge

        if t_lastclkin > 0 ns then
          t_lastperiod := t_period;
          t_period := now - t_lastclkin;
          CLKOUT_PERIOD <= (t_period * VCO_DIVIDE * OUT_DIVIDE) / VCO_MULTIPLY;
          if t_lastperiod > 0 ns and abs(t_period-t_lastperiod) > 1 ps then
            report "sfs_gsim_core: CLKIN unstable" severity warning;
          end if;
        end if;
        t_lastclkin := now;
        
        if t_period > 0 ns then
          nclkin := nclkin - 1;
          if nclkin <= 0 then
            nclkin := VCO_DIVIDE * OUT_DIVIDE;
            CLK_DIVPULSE <= '1';
            R_LOCKED     <= '1';
          end if;
        end if;

      else                              -- if CLKIN falling edge
        CLK_DIVPULSE <= '0';
      end if;     
    end if;
    
  end process proc_clkin;

  proc_clkout : process
  begin

    loop
      wait until CLK_DIVPULSE = '1';

      for i in 1 to VCO_MULTIPLY loop
        R_CLKOUT <= '1';
        wait for CLKOUT_PERIOD/2;
        R_CLKOUT <= '0';
        if i /= VCO_MULTIPLY then
          wait for CLKOUT_PERIOD/2;
        end if;
      end loop;  -- i

    end loop;
    
  end process proc_clkout;

  CLKFX  <= R_CLKOUT;
  LOCKED <= R_LOCKED;
  
end sim;
