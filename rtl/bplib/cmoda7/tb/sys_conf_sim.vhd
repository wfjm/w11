-- $Id: sys_conf_sim.vhd 1181 2019-07-08 17:00:50Z mueller $
-- SPDX-License-Identifier: GPL-3.0-or-later
-- Copyright 2017- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
--
------------------------------------------------------------------------------
-- Package Name:   sys_conf
-- Description:    Definitions for tb_cmoda7_dummy (for simulation)
--
-- Dependencies:   -
-- Tool versions:  viv 2016.4; ghdl 0.34
-- Revision History: 
-- Date         Rev Version  Comment
-- 2017-06-04   906   1.0    Initial version
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

use work.slvtypes.all;

package sys_conf is

  constant sys_conf_clksys_vcodivide   : positive :=   1;
  constant sys_conf_clksys_vcomultiply : positive :=  60;   -- vco  720 MHz
  constant sys_conf_clksys_outdivide   : positive :=   9;   -- sys   80 MHz
  constant sys_conf_clksys_gentype     : string   := "MMCM";
  constant sys_conf_clkser_vcodivide   : positive :=   1;
  constant sys_conf_clkser_vcomultiply : positive :=  60;   -- vco  720 MHz
  constant sys_conf_clkser_outdivide   : positive :=   6;   -- sys  120 MHz
  constant sys_conf_clkser_gentype     : string   := "MMCM";

  -- derived constants

  constant sys_conf_clksys : integer :=
    ((12000000/sys_conf_clksys_vcodivide)*sys_conf_clksys_vcomultiply) /
    sys_conf_clksys_outdivide;
  constant sys_conf_clksys_mhz : integer := sys_conf_clksys/1000000;

  constant sys_conf_clkser : integer :=
    ((12000000/sys_conf_clkser_vcodivide)*sys_conf_clkser_vcomultiply) /
    sys_conf_clkser_outdivide;
  constant sys_conf_clkser_mhz : integer := sys_conf_clkser/1000000;

end package sys_conf;

