-- $Id: sys_conf.vhd 1050 2018-09-23 15:46:42Z mueller $
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
-- Description:    Definitions for sys_w11a_s3 (for synthesis)
--
-- Dependencies:   -
-- Tool versions:  xst 8.1-14.7; ghdl 0.18-0.34
-- Revision History: 
-- Date         Rev Version  Comment
-- 2018-09-22  1050   1.3.6  add sys_conf_dmpcnt
-- 2018-09-08  1043   1.3.5  add sys_conf_ibd_kw11p
-- 2017-04-22   884   1.3.4  use sys_conf_dmcmon_awidth=8 (proper value)
-- 2017-03-04   858   1.3.3  enable deuna
-- 2017-01-29   847   1.3.2  add sys_conf_ibd_deuna
-- 2016-05-27   770   1.3.1  sys_conf_mem_losize now type natural 
-- 2016-03-22   750   1.3    add sys_conf_cache_twidth
-- 2015-06-26   695   1.2.1  add sys_conf_(dmscnt|dmhbpt*|dmcmon*)
-- 2015-03-14   658   1.2    add sys_conf_ibd_* definitions
-- 2014-12-22   619   1.1.2  add _rbmon_awidth
-- 2010-05-05   288   1.1.1  add sys_conf_hio_debounce
-- 2008-02-23   118   1.1    add memory config
-- 2007-09-23    84   1.0    Initial version 
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

use work.slvtypes.all;

package sys_conf is

  -- configure rlink and hio interfaces --------------------------------------
  constant sys_conf_ser2rri_cdinit : integer := 434-1;   -- 50000000/115200
  constant sys_conf_hio_debounce : boolean := true;    -- instantiate debouncers

  -- configure debug and monitoring units ------------------------------------
  constant sys_conf_rbmon_awidth  : integer := 9; -- use 0 to disable
  constant sys_conf_ibmon_awidth  : integer := 9; -- use 0 to disable
  constant sys_conf_dmscnt        : boolean := true;
  constant sys_conf_dmpcnt        : boolean := true;
  constant sys_conf_dmhbpt_nunit  : integer := 2; -- use 0 to disable
  constant sys_conf_dmcmon_awidth : integer := 8; -- use 0 to disable

  -- configure w11 cpu core --------------------------------------------------
  constant sys_conf_mem_losize     : natural := 8#037777#; --   1 MByte
  
  constant sys_conf_cache_fmiss    : slbit   := '0';     -- cache enabled
  constant sys_conf_cache_twidth   : integer :=  9;      -- 8kB cache

  -- configure w11 system devices --------------------------------------------
  -- configure character and communication devices
  constant sys_conf_ibd_dl11_1 : boolean := true;  -- 2nd DL11
  constant sys_conf_ibd_pc11   : boolean := true;  -- PC11
  constant sys_conf_ibd_lp11   : boolean := true;  -- LP11
  constant sys_conf_ibd_deuna  : boolean := true;  -- DEUNA

  -- configure mass storage devices
  constant sys_conf_ibd_rk11   : boolean := true;  -- RK11
  constant sys_conf_ibd_rl11   : boolean := true;  -- RL11
  constant sys_conf_ibd_rhrp   : boolean := true;  -- RHRP
  constant sys_conf_ibd_tm11   : boolean := true;  -- TM11

  -- configure other devices
  constant sys_conf_ibd_iist   : boolean := true;  -- IIST
  constant sys_conf_ibd_kw11p  : boolean := true;  -- KW11P

end package sys_conf;
