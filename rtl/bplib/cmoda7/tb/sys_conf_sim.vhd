-- $Id: sys_conf_sim.vhd 984 2018-01-02 20:56:27Z mueller $
--
-- Copyright 2017- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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

