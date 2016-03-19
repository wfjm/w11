-- $Id: sys_conf_sim.vhd 743 2016-03-13 16:42:31Z mueller $
--
-- Copyright 2016- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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
-- Package Name:   sys_conf
-- Description:    Definitions for sys_tst_rlink_arty (for simulation)
--
-- Dependencies:   -
-- Tool versions:  viv 2015.4; ghdl 0.33
-- Revision History: 
-- Date         Rev Version  Comment
-- 2016-03-12   741   1.1    add sysmon_rbus
-- 2016-02-14   731   1.0    Initial version
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

use work.slvtypes.all;

package sys_conf is

  -- configure clocks --------------------------------------------------------
  constant sys_conf_clksys_vcodivide   : positive :=   1;
  constant sys_conf_clksys_vcomultiply : positive :=   1;   -- vco  --- MHz
  constant sys_conf_clksys_outdivide   : positive :=   1;   -- sys  100 MHz
  constant sys_conf_clksys_gentype     : string   := "MMCM";
  -- single clock design, clkser = clksys
  constant sys_conf_clkser_vcodivide   : positive := sys_conf_clksys_vcodivide;
  constant sys_conf_clkser_vcomultiply : positive := sys_conf_clksys_vcomultiply;
  constant sys_conf_clkser_outdivide   : positive := sys_conf_clksys_outdivide;
  constant sys_conf_clkser_gentype     : string   := sys_conf_clksys_gentype;

  -- configure rlink and hio interfaces --------------------------------------
  constant sys_conf_ser2rri_cdinit : integer := 1-1;   -- 1 cycle/bit in sim
  constant sys_conf_hio_debounce : boolean := false;   -- no debouncers

  -- configure further units -------------------------------------------------
  constant sys_conf_rbd_sysmon    : boolean := true;  -- SYSMON(XADC)

  -- derived constants =======================================================
  
  constant sys_conf_clksys : integer :=
    ((100000000/sys_conf_clksys_vcodivide)*sys_conf_clksys_vcomultiply) /
    sys_conf_clksys_outdivide;
  constant sys_conf_clksys_mhz : integer := sys_conf_clksys/1000000;

  constant sys_conf_clkser : integer :=
     ((100000000/sys_conf_clkser_vcodivide)*sys_conf_clkser_vcomultiply) /
    sys_conf_clkser_outdivide;
   constant sys_conf_clkser_mhz : integer := sys_conf_clkser/1000000;

end package sys_conf;
