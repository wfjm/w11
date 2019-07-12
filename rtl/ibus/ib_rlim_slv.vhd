-- $Id: ib_rlim_slv.vhd 1181 2019-07-08 17:00:50Z mueller $
-- SPDX-License-Identifier: GPL-3.0-or-later
-- Copyright 2019- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
--
------------------------------------------------------------------------------
-- Module Name:    ib_rlim_slv - syn
-- Description:    ibus rate limter - slave
--
-- Dependencies:   -
-- Test bench:     -
-- Target Devices: generic
-- Tool versions:  ise 14.7; viv 2017.2; ghdl 0.35
--
-- Revision History: 
-- Date         Rev Version  Comment
-- 2019-04-14  1131   1.1    RLIM_CEV now slv8
-- 2019-03-17  1123   1.0    Initial version
-- 2019-03-15  1122   0.1    First draft
--
-- Notes:
--   sel ce-scale   rate in slv
--    0     -         8 cycles
--    1    1:  1      8 usec  125.0 kHz
--    2    1:  2     16 usec   62.5 kHz
--    3    1:  4     32 usec   31.2 kHz
--    4    1:  8     64 usec   15.6 kHz
--    5    1: 16    256 usec    3.9 kHz
--    6    1: 32    512 usec    2.0 kHz
--    7    1: 64   1024 usec    1.0 kHz
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.slvtypes.all;

-- ----------------------------------------------------------------------------
entity ib_rlim_slv is                   -- ibus rate limter - slave
  port (
    CLK : in slbit;                     -- clock
    RESET : in slbit;                   -- system reset
    RLIM_CEV : in  slv8;                -- clock enable vector
    SEL : in  slv3;                     -- rlim select
    START : in slbit;                   -- start timer
    STOP : in slbit;                    -- stop timer
    DONE : out slbit;                   -- 1 cycle pulse when expired 
    BUSY : out slbit                    -- timer running
  );
end ib_rlim_slv;

architecture syn of ib_rlim_slv is
  
  type regs_type is record              -- state registers
    cnt  : slv3;                        -- counter
    busy : slbit;                       -- busy
  end record regs_type;

  constant regs_init : regs_type := (
    (others=>'0'),                      -- cnt
    '0'                                 -- busy
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

  proc_next : process (R_REGS, RLIM_CEV, SEL, START, STOP)
    variable r : regs_type := regs_init;
    variable n : regs_type := regs_init;
    variable idone : slbit := '0';
    variable ice   : slbit := '0';
  begin

    r := R_REGS;
    n := R_REGS;

    ice := '0';
    case SEL is
      when "000" => ice := RLIM_CEV(0); -- every cycle
      when "001" => ice := RLIM_CEV(1); -- every       CE_USEC
      when "010" => ice := RLIM_CEV(2); -- every   2nd CE_USEC
      when "011" => ice := RLIM_CEV(3); -- every   4th CE_USEC
      when "100" => ice := RLIM_CEV(4); -- every   8th CE_USEC
      when "101" => ice := RLIM_CEV(5); -- every  32nd CE_USEC
      when "110" => ice := RLIM_CEV(6); -- every  64th CE_USEC
      when "111" => ice := RLIM_CEV(7); -- every 128th CE_USEC
      when others => null;
    end case;
    
    idone := '0';
    if STOP = '1' then
      n.busy := '0';
      idone  := r.busy;
    elsif START = '1' then
      n.busy := '1';
      n.cnt  := "000";
    elsif r.busy = '1' then
      if ice = '1' then
        n.cnt := slv(unsigned(r.cnt) + 1);
        if r.cnt = "111" then
          n.busy := '0';
          idone  := '1';
        end if;
      end if;
    end if;
    
    N_REGS <= n;

    DONE <= idone;
    BUSY <= r.busy;
    
  end process proc_next;
  
end syn;
