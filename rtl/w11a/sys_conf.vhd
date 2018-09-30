-- $Id: sys_conf.vhd 1051 2018-09-29 15:29:11Z mueller $
--
-- Copyright 2007-2018 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
--
-- This program is free software; you may redistribute and/or modify it under
-- the terms of the GNU General Public License as published by the Free
-- Software Foundation, either version 3, or (at your option) any later version.
--
-- This program is distributed in the hope that it will be useful, but
-- WITHOUT ANY WARRANTY, without even the implied warranty of MERCHANTABILITY
-- or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
-- for complete details.
--
------------------------------------------------------------------------------
-- Package Name:   sys_conf
-- Description:    Default definitions
--
-- Dependencies:   -
-- Tool versions:  xst 8.1-14.7; viv 2014.4-2018.2; ghdl 0.18-0.34
-- Revision History: 
-- Date         Rev Version  Comment
-- 2018-09-22  1051   1.1.3  add missing config's
-- 2016-05-28   770   1.1.2  sys_conf_mem_losize now type natural 
-- 2015-06-26   695   1.1.1  add sys_conf_dmscnt
-- 2015-05-01   672   1.1    adopt to pdp11_sys70
-- 2008-02-23   118   1.0    Initial version 
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

use work.slvtypes.all;

package sys_conf is

  constant sys_conf_cache_fmiss    : slbit   := '0';      -- cache enabled
  constant sys_conf_cache_twidth   : integer :=  9;       --   8kB cache

  constant sys_conf_bram_awidth    : integer := 15;       -- 32 kB BRAM
  constant sys_conf_mem_losize     : natural := 8#000777#;-- 32 kByte

  constant sys_conf_ibmon_awidth   : integer := 9; -- use 0 to disable ibmon
  constant sys_conf_dmscnt         : boolean := true;
  constant sys_conf_dmpcnt         : boolean := true;
  constant sys_conf_dmhbpt_nunit   : integer := 2; -- use 0 to disable
  constant sys_conf_dmcmon_awidth  : integer := 8; -- use 0 to disable, 8 to use

end package sys_conf;

