-- $Id: sys_conf_sim.vhd 1181 2019-07-08 17:00:50Z mueller $
-- SPDX-License-Identifier: GPL-3.0-or-later
-- Copyright 2013-2016 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
--
------------------------------------------------------------------------------
-- Package Name:   sys_conf
-- Description:    Definitions for sys_tst_sram_n4 (for simulation)
--
-- Dependencies:   -
-- Tool versions:  xst 14.5-14.7; ghdl 0.29-0.33
-- Revision History: 
-- Date         Rev Version  Comment
-- 2016-07-16   788   1.3    use cram_*delay functions to determine delays
-- 2016-07-10   786   1.2    memctl with page mode, new read1delay
-- 2016-06-18   775   1.1.1  use PLL for clkser_gentype
-- 2016-03-29   756   1.1    use serport_2clock2 -> define clkser
-- 2013-09-21   534   1.0    Initial version 
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

use work.slvtypes.all;
use work.nxcramlib.all;

package sys_conf is

  constant sys_conf_clksys_vcodivide   : positive :=   1;
  constant sys_conf_clksys_vcomultiply : positive :=   1;   -- vco  --- MHz
  constant sys_conf_clksys_outdivide   : positive :=   1;   -- sys  100 MHz
  constant sys_conf_clksys_gentype     : string   := "MMCM";
  -- dual clock design, clkser = 120 MHz
  constant sys_conf_clkser_vcodivide   : positive :=   1;
  constant sys_conf_clkser_vcomultiply : positive :=  12;   -- vco 1200 MHz
  constant sys_conf_clkser_outdivide   : positive :=  10;   -- sys  120 MHz
  constant sys_conf_clkser_gentype     : string   := "PLL";

  constant sys_conf_ser2rri_cdinit : integer := 1-1;   -- 1 cycle/bit in sim
  
  -- derived constants
  
  constant sys_conf_clksys : integer :=
    ((100000000/sys_conf_clksys_vcodivide)*sys_conf_clksys_vcomultiply) /
    sys_conf_clksys_outdivide;
  constant sys_conf_clksys_mhz : integer := sys_conf_clksys/1000000;

  constant sys_conf_clkser : integer :=
     ((100000000/sys_conf_clkser_vcodivide)*sys_conf_clkser_vcomultiply) /
    sys_conf_clkser_outdivide;
  constant sys_conf_clkser_mhz : integer := sys_conf_clkser/1000000;

  constant sys_conf_memctl_read0delay : positive :=
              cram_read0delay(sys_conf_clksys_mhz);
  constant sys_conf_memctl_read1delay : positive := 
              cram_read1delay(sys_conf_clksys_mhz);
  constant sys_conf_memctl_writedelay : positive := 
              cram_writedelay(sys_conf_clksys_mhz);
 
end package sys_conf;
