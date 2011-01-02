-- $Id: rlink_mon_sb.vhd 347 2010-12-24 12:10:42Z mueller $
--
-- Copyright 2007-2010 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
--
-- This program is free software; you may redistribute and/or modify it under
-- the terms of the GNU General Public License as published by the Free
-- Software Foundation, either version 2, or at your option any later version.
--
-- This program is distributed in the hope that it will be useful, but
-- WITHOUT ANY WARRANTY, without even the implied warranty of MERCHANTABILITY
-- or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
-- for complete details.
--
------------------------------------------------------------------------------
-- Module Name:    rlink_mon_sb - sim
-- Description:    simbus wrapper for rlink monitor
--
-- Dependencies:   simbus
-- Test bench:     -
-- Tool versions:  xst 8.1, 8.2, 9.1, 9.2, 12.1; ghdl 0.18-0.29
--
-- Revision History: 
-- Date         Rev Version  Comment
-- 2010-12-24   347   3.0.1  rename: CP_*->RL->*
-- 2010-12-22   346   3.0    renamed rritb_cpmon_sb -> rlink_mon_sb
-- 2010-05-02   287   1.0.1  use sbcntl_sbf_cpmon def
-- 2007-08-25    75   1.0    Initial version 
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

use work.slvtypes.all;
use work.simlib.all;
use work.simbus.all;
use work.rlinklib.all;

entity rlink_mon_sb is                  -- simbus wrap for rlink monitor
  generic (
    DWIDTH : positive :=  9;            -- data port width (8 or 9)
    ENAPIN : integer := sbcntl_sbf_rlmon); -- SB_CNTL signal to use for enable
  port (
    CLK  : in slbit;                    -- clock
    RL_DI : in slv(DWIDTH-1 downto 0);  -- rlink: data in
    RL_ENA : in slbit;                  -- rlink: data enable
    RL_BUSY : in slbit;                 -- rlink: data busy
    RL_DO : in slv(DWIDTH-1 downto 0);  -- rlink: data out
    RL_VAL : in slbit;                  -- rlink: data valid
    RL_HOLD : in slbit                  -- rlink: data hold
  );
end rlink_mon_sb;


architecture sim of rlink_mon_sb is

  signal ENA : slbit := '0';
  
begin

  assert ENAPIN>=SB_CNTL'low and ENAPIN<=SB_CNTL'high
    report "assert(ENAPIN in SB_CNTL'range)" severity failure;

  ENA <= to_x01(SB_CNTL(ENAPIN));
  
  CPMON : rlink_mon
    generic map (
      DWIDTH => DWIDTH)
    port map (
      CLK       => CLK,
      CLK_CYCLE => SB_CLKCYCLE,
      ENA       => ENA,
      RL_DI     => RL_DI,
      RL_ENA    => RL_ENA,
      RL_BUSY   => RL_BUSY,
      RL_DO     => RL_DO,
      RL_VAL    => RL_VAL,
      RL_HOLD   => RL_HOLD
    );
  
end sim;
