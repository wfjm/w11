-- $Id: sys_conf.vhd 1325 2022-12-07 11:52:36Z mueller $
-- SPDX-License-Identifier: GPL-3.0-or-later
-- Copyright 2007-2022 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
--
------------------------------------------------------------------------------
-- Package Name:   sys_conf
-- Description:    Definitions for sys_w11a_s3 (for synthesis)
--
-- Dependencies:   -
-- Tool versions:  xst 8.1-14.7; ghdl 0.18-2022.1
-- Revision History: 
-- Date         Rev Version  Comment
-- 2022-12-05  1324   1.4.2  disable dmhbpt,dmcmon,m9312 for timing closure
-- 2019-04-28  1142   1.4.1  add sys_conf_ibd_m9312
-- 2019-02-09  1110   1.4    use typ for DL,PC,LP; add dz11,ibtst
-- 2019-01-27  1108   1.3.7  drop iist
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
  constant sys_conf_ibtst         : boolean := true;
  constant sys_conf_dmscnt        : boolean := true;
  constant sys_conf_dmpcnt        : boolean := true;
  constant sys_conf_dmhbpt_nunit  : integer := 0; -- use 0 to disable
  constant sys_conf_dmcmon_awidth : integer := 0; -- use 0 to disable

  -- configure w11 cpu core --------------------------------------------------
  constant sys_conf_mem_losize     : natural := 8#037777#; --   1 MByte
  
  constant sys_conf_cache_fmiss    : slbit   := '0';     -- cache enabled
  constant sys_conf_cache_twidth   : integer :=  9;      -- 8kB cache

  -- configure w11 system devices --------------------------------------------
  -- configure character and communication devices
  -- typ for DL,DZ,PC,LP: -1->none; 0->unbuffered; 4-7 buffered (typ=AWIDTH)
  constant sys_conf_ibd_dl11_0 : integer :=  4;    -- 1st DL11
  constant sys_conf_ibd_dl11_1 : integer :=  4;    -- 2nd DL11
  constant sys_conf_ibd_dz11   : integer :=  5;    -- DZ11
  constant sys_conf_ibd_pc11   : integer :=  4;    -- PC11
  constant sys_conf_ibd_lp11   : integer :=  5;    -- LP11
  constant sys_conf_ibd_deuna  : boolean := false; -- DEUNA

  -- configure mass storage devices
  constant sys_conf_ibd_rk11   : boolean := true;  -- RK11
  constant sys_conf_ibd_rl11   : boolean := true;  -- RL11
  constant sys_conf_ibd_rhrp   : boolean := true;  -- RHRP
  constant sys_conf_ibd_tm11   : boolean := true;  -- TM11

  -- configure other devices
  constant sys_conf_ibd_iist   : boolean := false; -- IIST
  constant sys_conf_ibd_kw11p  : boolean := false; -- KW11P
  constant sys_conf_ibd_m9312  : boolean := false; -- M9312

end package sys_conf;
