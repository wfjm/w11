-- $Id: ib_rlim_gen.vhd 1181 2019-07-08 17:00:50Z mueller $
-- SPDX-License-Identifier: GPL-3.0-or-later
-- Copyright 2019- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
--
------------------------------------------------------------------------------
-- Module Name:    ib_rlim_gen - syn
-- Description:    ibus rate limter - master
--
-- Dependencies:   -
-- Test bench:     -
-- Target Devices: generic
-- Tool versions:  ise 14.7; viv 2017.2; ghdl 0.35
--
-- Revision History: 
-- Date         Rev Version  Comment
-- 2019-04-14  1131   1.1    add CPUSUSP port; RLIM_CEV now slv8
-- 2019-03-17  1123   1.0    Initial version
-- 2019-03-15  1122   0.1    First draft
--
-- Notes:
--   cev   scale    rate in slv
--   (0)   none        8 clock cycles
--   (1)   1:  1       8 usec  125.0 kHz
--   (2)   1:  2      16 usec   62.5 kHz
--   (3)   1:  4      32 usec   31.2 kHz
--   (4)   1:  8      64 usec   15.6 kHz
--   (5)   1: 32     256 usec    3.9 kHz
--   (6)   1: 64     512 usec    2.0 kHz
--   (7)   1:128    1024 usec    1.0 kHz
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.slvtypes.all;

-- ----------------------------------------------------------------------------
entity ib_rlim_gen is                   -- ibus rate limter - master
  port (
    CLK : in slbit;                     -- clock
    CE_USEC : in slbit;                 -- usec pulse
    RESET : in slbit;                   -- system reset
    CPUSUSP : in slbit;                 -- cpu suspended
    RLIM_CEV : out slv8                 -- clock enable vector
  );
end ib_rlim_gen;

architecture syn of ib_rlim_gen is
  
  type regs_type is record              -- state registers
    cnt : slv7;                         -- usec counter
    cev : slv8;                         -- ce vector
  end record regs_type;

  constant regs_init : regs_type := (
    (others=>'0'),                      -- cnt
    (others=>'0')                       -- cev
  );

  signal R_REGS : regs_type := regs_init;
  signal N_REGS : regs_type := regs_init;

begin
  
  proc_regs: process (CLK)
  begin
    if rising_edge(CLK) then
      if RESET = '1' then
        R_REGS <= regs_init;
      else
        R_REGS <= N_REGS;
      end if;
    end if;
  end process proc_regs;

  proc_next : process (R_REGS, CE_USEC, CPUSUSP)
    variable r : regs_type := regs_init;
    variable n : regs_type := regs_init;
  begin

    r := R_REGS;
    n := R_REGS;

    n.cev := (others=>'0');
    if CPUSUSP = '0' then               -- run timers if CPU not suspended
      n.cev(0) := '1';                                                 -- none
      if CE_USEC = '1' then
        n.cev(1) := '1';                                               -- 1:  1
        n.cnt := slv(unsigned(r.cnt) + 1);
        if r.cnt(0 downto 0) =       "1" then n.cev(2) := '1'; end if; -- 1:  2
        if r.cnt(1 downto 0) =      "11" then n.cev(3) := '1'; end if; -- 1:  4
        if r.cnt(2 downto 0) =     "111" then n.cev(4) := '1'; end if; -- 1:  8
        if r.cnt(4 downto 0) =   "11111" then n.cev(5) := '1'; end if; -- 1: 32
        if r.cnt(5 downto 0) =  "111111" then n.cev(6) := '1'; end if; -- 1: 64
        if r.cnt(6 downto 0) = "1111111" then n.cev(7) := '1'; end if; -- 1:128
      end if;
    end if;
    
    N_REGS <= n;

    RLIM_CEV <= r.cev;
    
  end process proc_next;
  
end syn;
