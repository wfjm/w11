-- $Id: pdp11_tmu_sb.vhd 1348 2023-01-08 13:33:01Z mueller $
-- SPDX-License-Identifier: GPL-3.0-or-later
-- Copyright 2009-2023 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
--
------------------------------------------------------------------------------
-- Module Name:    pdp11_tmu - sim
-- Description:    pdp11: trace and monitor unit; simbus wrapper
--
-- Dependencies:   simbus
-- Test bench:     -
-- Tool versions:  xst 8.1-14.7; viv 2016.2-2022.1; ghdl 0.18-2.0.0
-- Revision History: 
-- Date         Rev Version  Comment
-- 2023-01-08  1348   1.0.3  add port DM_STAT_SE
-- 2018-10-05  1053   1.0.2  use DM_STAT_CA instead of DM_STAT_SY
-- 2015-11-01   712   1.0.1  use sbcntl_sbf_tmu
-- 2009-05-10   214   1.0    Initial version 
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

use work.slvtypes.all;
use work.simlib.all;
use work.simbus.all;
use work.pdp11.all;

entity pdp11_tmu_sb is                  -- trace and mon. unit; simbus wrapper
  generic (
    ENAPIN : integer := sbcntl_sbf_tmu); -- SB_CNTL for tmu
  port (
    CLK : in slbit;                     -- clock
    DM_STAT_DP : in dm_stat_dp_type;    -- debug and monitor status - dpath
    DM_STAT_SE : in dm_stat_se_type;    -- debug and monitor status - sequencer
    DM_STAT_VM : in dm_stat_vm_type;    -- debug and monitor status - vmbox
    DM_STAT_CO : in dm_stat_co_type;    -- debug and monitor status - core
    DM_STAT_CA : in dm_stat_ca_type     -- debug and monitor status - cache
  );
end pdp11_tmu_sb;


architecture sim of pdp11_tmu_sb is

  signal ENA : slbit := '0';
  
begin

  assert ENAPIN>=SB_CNTL'low and ENAPIN<=SB_CNTL'high
    report "assert(ENAPIN in SB_CNTL'range)" severity failure;

  ENA <= to_x01(SB_CNTL(ENAPIN));
  
  CPMON : pdp11_tmu
    port map (
      CLK        => CLK,
      ENA        => ENA,
      DM_STAT_DP => DM_STAT_DP,
      DM_STAT_SE => DM_STAT_SE,
      DM_STAT_VM => DM_STAT_VM,
      DM_STAT_CO => DM_STAT_CO,
      DM_STAT_CA => DM_STAT_CA
    );
  
end sim;
