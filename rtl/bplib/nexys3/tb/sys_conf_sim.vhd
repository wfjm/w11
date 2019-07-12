-- $Id: sys_conf_sim.vhd 1181 2019-07-08 17:00:50Z mueller $
-- SPDX-License-Identifier: GPL-3.0-or-later
-- Copyright 2011-2013 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
--
------------------------------------------------------------------------------
-- Package Name:   sys_conf
-- Description:    Definitions for tb_nexys3_fusp_dummy (for simulation)
--
-- Dependencies:   -
-- Tool versions:  xst 13.1, 14.6; ghdl 0.29
-- Revision History: 
-- Date         Rev Version  Comment
-- 2013-10-06   538   1.1    pll support, use clksys_vcodivide ect
-- 2011-11-25   433   1.0    Initial version
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

use work.slvtypes.all;

package sys_conf is

  constant sys_conf_clksys_vcodivide   : positive :=   4;
  constant sys_conf_clksys_vcomultiply : positive :=   3;   -- dcm   75 MHz
  constant sys_conf_clksys_outdivide   : positive :=   1;   -- sys   75 MHz
  constant sys_conf_clksys_gentype     : string   := "DCM";

  -- derived constants

  constant sys_conf_clksys : integer :=
    ((100000000/sys_conf_clksys_vcodivide)*sys_conf_clksys_vcomultiply) /
    sys_conf_clksys_outdivide;
  constant sys_conf_clksys_mhz : integer := sys_conf_clksys/1000000;

end package sys_conf;

