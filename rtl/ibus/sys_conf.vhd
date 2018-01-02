-- $Id: sys_conf.vhd 984 2018-01-02 20:56:27Z mueller $
--
-- Copyright 2015-2017 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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
-- Description:    Default definitions for ibdr_maxisys
--
-- Dependencies:   -
-- Tool versions:  xst 14.7; viv 2014.4-2016.4; ghdl 0.18-0.33
-- Revision History: 
-- Date         Rev Version  Comment
-- 2017-01-29   847   1.0.1  add sys_conf_ibd_deuna
-- 2015-03-14   658   1.0    Initial version 
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

use work.slvtypes.all;

package sys_conf is

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

end package sys_conf;

