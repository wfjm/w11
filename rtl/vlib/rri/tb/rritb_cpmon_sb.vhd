-- $Id: rritb_cpmon_sb.vhd 314 2010-07-09 17:38:41Z mueller $
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
-- Module Name:    rritb_cpmon_sb - sim
-- Description:    rritb: rri comm port monitor; simbus wrapper
--
-- Dependencies:   simbus
-- Test bench:     -
-- Tool versions:  xst 8.1, 8.2, 9.1, 9.2; ghdl 0.18-0.25
-- Revision History: 
-- Date         Rev Version  Comment
-- 2010-05-02   287   1.0.1  use sbcntl_sbf_cpmon def
-- 2007-08-25    75   1.0    Initial version 
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

use work.slvtypes.all;
use work.simlib.all;
use work.simbus.all;
use work.rritblib.all;

entity rritb_cpmon_sb is                -- simbus wrap rri comm port monitor
  generic (
    DWIDTH : positive :=  9;            -- data port width (8 or 9)
    ENAPIN : integer := sbcntl_sbf_cpmon); -- SB_CNTL signal to use for enable
  port (
    CLK  : in slbit;                    -- clock
    CP_DI : in slv(DWIDTH-1 downto 0);  -- comm port: data in
    CP_ENA : in slbit;                  -- comm port: data enable
    CP_BUSY : in slbit;                 -- comm port: data busy
    CP_DO : in slv(DWIDTH-1 downto 0);  -- comm port: data out
    CP_VAL : in slbit;                  -- comm port: data valid
    CP_HOLD : in slbit                  -- comm port: data hold
  );
end rritb_cpmon_sb;


architecture sim of rritb_cpmon_sb is

  signal ENA : slbit := '0';
  
begin

  assert ENAPIN>=SB_CNTL'low and ENAPIN<=SB_CNTL'high
    report "assert(ENAPIN in SB_CNTL'range)" severity failure;

  ENA <= to_x01(SB_CNTL(ENAPIN));
  
  CPMON : rritb_cpmon
    generic map (
      DWIDTH => DWIDTH)
    port map (
      CLK       => CLK,
      CLK_CYCLE => SB_CLKCYCLE,
      ENA       => ENA,
      CP_DI     => CP_DI,
      CP_ENA    => CP_ENA,
      CP_BUSY   => CP_BUSY,
      CP_DO     => CP_DO,
      CP_VAL    => CP_VAL,
      CP_HOLD   => CP_HOLD
    );
  
end sim;
