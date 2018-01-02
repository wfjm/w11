-- $Id: sys_conf_sim.vhd 984 2018-01-02 20:56:27Z mueller $
--
-- Copyright 2011-2016 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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
-- Description:    Definitions for sys_tst_sram_n3 (for simulation)
--
-- Dependencies:   -
-- Tool versions:  xst 13.1-14.7; ghdl 0.29-0.33
-- Revision History: 
-- Date         Rev Version  Comment
-- 2016-07-16   788   1.2    use cram_*delay functions to determine delays
-- 2013-10-06   538   1.1    pll support, use clksys_vcodivide ect
-- 2011-11-27   433   1.0    Initial version 
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

use work.slvtypes.all;
use work.nxcramlib.all;

package sys_conf is

  constant sys_conf_clksys_vcodivide   : positive :=   1;
  constant sys_conf_clksys_vcomultiply : positive :=   1;   -- dcm  100 MHz
  constant sys_conf_clksys_outdivide   : positive :=   1;   -- sys  100 MHz
  constant sys_conf_clksys_gentype     : string   := "DCM";
  
  constant sys_conf_ser2rri_cdinit : integer := 1-1;   -- 1 cycle/bit in sim
  
  -- derived constants
  
  constant sys_conf_clksys : integer :=
    ((100000000/sys_conf_clksys_vcodivide)*sys_conf_clksys_vcomultiply) /
    sys_conf_clksys_outdivide;
  constant sys_conf_clksys_mhz : integer := sys_conf_clksys/1000000;

  constant sys_conf_memctl_read0delay : positive :=
              cram_read0delay(sys_conf_clksys_mhz);
  constant sys_conf_memctl_read1delay : positive := 
              cram_read1delay(sys_conf_clksys_mhz);
  constant sys_conf_memctl_writedelay : positive := 
              cram_writedelay(sys_conf_clksys_mhz);

end package sys_conf;
