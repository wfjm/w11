-- $Id: rgbdrv_master.vhd 1181 2019-07-08 17:00:50Z mueller $
-- SPDX-License-Identifier: GPL-3.0-or-later
-- Copyright 2016- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
-- 
------------------------------------------------------------------------------
-- Module Name:    rgbdrv_master - syn
-- Description:    rgbled driver: master
--
-- Dependencies:   -
-- Test bench:     -
-- Target Devices: generic
-- Tool versions:  viv 2015.4; ghdl 0.31
--
-- Revision History: 
-- Date         Rev Version  Comment
-- 2016-02-20   734   1.0    Initial version 
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.slvtypes.all;

entity rgbdrv_master is              -- rgbled driver: master
  generic (
    DWIDTH : positive := 8);            -- dimmer width (must be >= 1)
  port (
    CLK : in slbit;                     -- clock
    RESET : in slbit := '0';            -- reset
    CE_USEC : in slbit;                 -- 1 us clock enable
    RGBCNTL : out slv3;                   -- rgb control
    DIMCNTL : out slv(DWIDTH-1 downto 0)  -- dim control
  );
end rgbdrv_master;

architecture syn of rgbdrv_master is

  type regs_type is record
    rgbena : slv3;                      -- rgb enables
    dimcnt : slv(DWIDTH-1 downto 0);    -- dim counter
  end record regs_type;

  constant dimones : slv(DWIDTH-1 downto 0) := (others=>'1');
  
  constant regs_init : regs_type := (
    "001",                              -- rgbena
    dimones                             -- dimcnt
  );

  signal R_REGS : regs_type := regs_init;  -- state registers
  signal N_REGS : regs_type := regs_init;  -- next value state regs

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


  proc_next: process (R_REGS, CE_USEC)
    variable r : regs_type := regs_init;
    variable n : regs_type := regs_init;
  begin

    r := R_REGS;
    n := R_REGS;
    
    if CE_USEC = '1' then
      n.dimcnt := slv(unsigned(r.dimcnt) + 1);
      if r.dimcnt = dimones then
        n.rgbena(2) := r.rgbena(1);
        n.rgbena(1) := r.rgbena(0);
        n.rgbena(0) := r.rgbena(2);
      end if;
    end if;

    N_REGS <= n;
    
  end process proc_next;

  RGBCNTL <= R_REGS.rgbena;
  DIMCNTL <= R_REGS.dimcnt;
  
end syn;
