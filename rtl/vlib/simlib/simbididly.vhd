-- $Id: simbididly.vhd 1181 2019-07-08 17:00:50Z mueller $
-- SPDX-License-Identifier: GPL-3.0-or-later
-- Copyright 2016- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
--
------------------------------------------------------------------------------
-- Module Name:    simbididly - sim
-- Description:    Bi-directional bus delay for test benches
--
-- Dependencies:   -
-- Test bench:     tb_simbididly
-- Target Devices: generic
-- Tool versions:  xst 14.7; viv 2016.2; ghdl 0.33
-- Revision History: 
-- Date         Rev Version  Comment
-- 2016-07-23   793   1.0.1  ensure non-zero DELAY
-- 2016-07-17   789   1.0    Initial version (use separate driver regs now)
-- 2016-07-16   787   0.1    First draft
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.slvtypes.all;

entity simbididly is                  -- test bench bi-directional bus delay
  generic (
    DELAY : Delay_length;             -- transport delay between A and B (>0ns!)
    DWIDTH : positive := 16);         -- data port width
   port (
    A : inout slv(DWIDTH-1 downto 0); -- port A
    B : inout slv(DWIDTH-1 downto 0)  -- port B
  );
end entity simbididly;


architecture sim of simbididly is

  type state_type is (
    s_idle,                             -- s_idle: both ports high-z
    s_a2b,                              -- s_a2b: A drives, B listens
    s_b2a                               -- s_b2a: B drives, A listens
  );

  constant all_z : slv(DWIDTH-1 downto 0) := (others=>'Z');

  signal R_STATE : state_type := s_idle;
  signal R_A     : slv(DWIDTH-1 downto 0) := (others=>'Z');
  signal R_B     : slv(DWIDTH-1 downto 0) := (others=>'Z');

begin

  process

    variable istate : state_type := s_idle;
    
  begin

    -- the delay model can enter into a delta cycle oszillation mode
    -- when DELAY is 0 ns. So ensure the delay is non-zero
    assert DELAY > 0 ns report "DELAY > 0 ns" severity failure;
    
    while true loop
      
      -- if idle check whether A or B port starts to drive bus
      -- Note: both signal R_STATE and variable istate is updated
      --   istate is needed to control the driver section below in the
      --   same delta cycle based on the most recent state state
      istate := R_STATE;

      if now > 0 ns then                -- to avoid startup problems
        if R_STATE = s_idle then
          if A /= all_z then
            R_STATE <= s_a2b;
            istate  := s_a2b;
          elsif B /= all_z then
            R_STATE <= s_b2a;
            istate  := s_b2a;
          end if;
        end if;
      end if;
        
      case istate is
        when s_a2b =>
          R_B <= transport A after DELAY;
          if A = all_z then R_STATE <= s_idle after DELAY; end if;
        when s_b2a =>
          R_A <= transport B after DELAY;
          if B = all_z then R_STATE <= s_idle after DELAY; end if;
        when others => null;
      end case;

      -- Note: the driver clash check is done by comparing an internal signal
      --   with the external signal. If they differ this indicates a clash.
      --   Just checking for 'x' gives false alarms when the bus is driven
      --   with 'x', which can for example come from a memory model before
      --   valid data is available.
      if now > 0 ns then                -- to avoid startup problems
        case istate is
          when s_a2b =>
            assert B = R_B report "driver clash B port" severity error;
          when s_b2a =>
            assert A = R_A report "driver clash A port" severity error;
          when others => null;
        end case;
      end if;
      
      wait on A,B;
    end loop;

  end process;

  A <= R_A;
  B <= R_B;
  
end sim;
