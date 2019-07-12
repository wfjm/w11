-- $Id: pdp11_ledmux.vhd 1181 2019-07-08 17:00:50Z mueller $
-- SPDX-License-Identifier: GPL-3.0-or-later
-- Copyright 2015-2018 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
--
------------------------------------------------------------------------------
-- Module Name:    pdp11_ledmux - syn
-- Description:    pdp11: hio led mux
--
-- Dependencies:   -
-- Test bench:     -
-- Target Devices: generic
-- Tool versions:  ise 14.7; viv 2018.2; ghdl 0.31-0.34
--
-- Revision History: 
-- Date         Rev Version  Comment
-- 2018-10-07  1054   1.1    use DM_STAT_EXP instead of DM_STAT_DP
-- 2015-02-27   652   1.0    Initial version 
-- 2015-02-20   649   0.1    First draft
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.slvtypes.all;
use work.pdp11.all;

-- ----------------------------------------------------------------------------

entity pdp11_ledmux is                  -- hio led mux
  generic (
    LWIDTH : positive := 8);            -- led width
  port (
    SEL : in slbit;                     -- select (0=stat;1=dr)
    STATLEDS : in slv8;                 -- 8 bit CPU status
    DM_STAT_EXP : in dm_stat_exp_type;  -- debug and monitor - exports
    LED : out slv(LWIDTH-1 downto 0)    -- hio leds
  );
end pdp11_ledmux;

architecture syn of pdp11_ledmux is
  
begin

  assert LWIDTH=8 or LWIDTH=16 
    report "assert(LWIDTH=8 or LWIDTH=16): unsupported LWIDTH"
    severity failure;

  proc_mux: process (SEL, STATLEDS, DM_STAT_EXP)
    variable iled : slv(LWIDTH-1 downto 0) := (others=>'0');
  begin
    iled := (others=>'0');

    if SEL = '0' then
      iled(STATLEDS'range) := STATLEDS;
    else
      if LWIDTH=8 then
        iled :=  DM_STAT_EXP.dp_dsrc(11 downto 4); --take middle part
      else
        iled :=  DM_STAT_EXP.dp_dsrc(iled'range);
      end if;
    end if;

    LED <= iled;
    
  end process proc_mux;

end syn;
