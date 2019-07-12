-- $Id: sys_conf.vhd 1181 2019-07-08 17:00:50Z mueller $
-- SPDX-License-Identifier: GPL-3.0-or-later
-- Copyright 2015-2019 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
--
------------------------------------------------------------------------------
-- Package Name:   sys_conf
-- Description:    Default definitions for ibdr_maxisys
--
-- Dependencies:   -
-- Tool versions:  xst 14.7; viv 2014.4-2018.3; ghdl 0.18-0.35
-- Revision History: 
-- Date         Rev Version  Comment
-- 2019-05-04  1146   1.1.1  add sys_conf_ibd_m9312
-- 2019-02-09  1110   1.1    use typ for DL,PC,LP; add dz11
-- 2018-09-08  1043   1.0.2  add sys_conf_ibd_kw11p
-- 2017-01-29   847   1.0.1  add sys_conf_ibd_deuna
-- 2015-03-14   658   1.0    Initial version 
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

use work.slvtypes.all;

package sys_conf is

  -- configure character and communication devices
  -- typ for DL,DZ,PC,LP: -1->none; 0->unbuffered; 4-7 buffered (typ=AWIDTH)
  constant sys_conf_ibd_dl11_0 : integer :=  4;    -- 1st DL11
  constant sys_conf_ibd_dl11_1 : integer :=  4;    -- 2nd DL11
  constant sys_conf_ibd_dz11   : integer :=  5;    -- DZ11
  constant sys_conf_ibd_pc11   : integer :=  4;    -- PC11
  constant sys_conf_ibd_lp11   : integer :=  5;    -- LP11
  constant sys_conf_ibd_deuna  : boolean := true;  -- DEUNA

  -- configure mass storage devices
  constant sys_conf_ibd_rk11   : boolean := true;  -- RK11
  constant sys_conf_ibd_rl11   : boolean := true;  -- RL11
  constant sys_conf_ibd_rhrp   : boolean := true;  -- RHRP
  constant sys_conf_ibd_tm11   : boolean := true;  -- TM11

  -- configure other devices
  constant sys_conf_ibd_iist   : boolean := true;  -- IIST
  constant sys_conf_ibd_kw11p  : boolean := true;  -- KW11P
  constant sys_conf_ibd_m9312  : boolean := true;  -- M9312

end package sys_conf;

