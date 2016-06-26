-- $Id: sys_conf_sim.vhd 775 2016-06-18 13:42:00Z mueller $
--
-- Copyright 2013-2016 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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
-- Description:    Definitions for sys_w11a_n4 (for simulation)
--
-- Dependencies:   -
-- Tool versions:  xst 14.5-14.7; viv 2016.1-2016.2; ghdl 0.29-0.33
-- Revision History: 
-- Date         Rev Version  Comment
-- 2016-06-18   775   1.4.5  use PLL for clkser_gentype
-- 2016-06-04   772   1.4.4  go for 80 MHz and 64 kB cache, best compromise
-- 2016-05-28   771   1.4.3  set dmcmon_awidth=0, useless without dmscnt
-- 2016-05-28   770   1.4.2  sys_conf_mem_losize now type natural 
-- 2016-05-26   768   1.4.1  set dmscnt=0 (vivado fsm issue); TW=8 (@90 MHz)
-- 2016-03-28   755   1.4    use serport_2clock2 -> define clkser
-- 2016-03-22   750   1.3    add sys_conf_cache_twidth
-- 2016-03-13   742   1.2.2  add sysmon_bus
-- 2015-06-26   695   1.2.1  add sys_conf_(dmscnt|dmhbpt*|dmcmon*)
-- 2015-03-14   658   1.2    add sys_conf_ibd_* definitions
-- 2015-02-07   643   1.1    drop bram and minisys options
-- 2013-09-34   534   1.0    Initial version (cloned from _n3)
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

use work.slvtypes.all;

package sys_conf is

  -- configure clocks --------------------------------------------------------
  constant sys_conf_clksys_vcodivide   : positive :=   1;
  constant sys_conf_clksys_vcomultiply : positive :=   8;   -- vco  800 MHz
  constant sys_conf_clksys_outdivide   : positive :=  10;   -- sys   80 MHz
  constant sys_conf_clksys_gentype     : string   := "MMCM";
  -- dual clock design, clkser = 120 MHz
  constant sys_conf_clkser_vcodivide   : positive :=   1;
  constant sys_conf_clkser_vcomultiply : positive :=  12;   -- vco 1200 MHz
  constant sys_conf_clkser_outdivide   : positive :=  10;   -- sys  120 MHz
  constant sys_conf_clkser_gentype     : string   := "PLL";

  -- configure rlink and hio interfaces --------------------------------------
  constant sys_conf_ser2rri_cdinit : integer := 1-1;   -- 1 cycle/bit in sim
  constant sys_conf_hio_debounce : boolean := false;   -- no debouncers
  
  -- configure memory controller ---------------------------------------------
  constant sys_conf_memctl_read0delay : positive := 6;   -- for 100 MHz
  constant sys_conf_memctl_read1delay : positive := sys_conf_memctl_read0delay;
  constant sys_conf_memctl_writedelay : positive := 7;

  -- configure debug and monitoring units ------------------------------------
  constant sys_conf_rbmon_awidth  : integer := 9; -- use 0 to disable
  constant sys_conf_ibmon_awidth  : integer := 9; -- use 0 to disable
  constant sys_conf_dmscnt        : boolean := false;
  constant sys_conf_dmhbpt_nunit  : integer := 2; -- use 0 to disable
  constant sys_conf_dmcmon_awidth : integer := 0; -- use 0 to disable, 9 to use
  constant sys_conf_rbd_sysmon    : boolean := true;  -- SYSMON(XADC)

  -- configure w11 cpu core --------------------------------------------------
  constant sys_conf_mem_losize     : natural := 8#167777#; --   4 MByte

  constant sys_conf_cache_fmiss    : slbit   := '0';     -- cache enabled
  constant sys_conf_cache_twidth   : integer :=  6;      -- 64kB cache

  -- configure w11 system devices --------------------------------------------
  -- configure character and communication devices
  constant sys_conf_ibd_dl11_1 : boolean := true;  -- 2nd DL11
  constant sys_conf_ibd_pc11   : boolean := true;  -- PC11
  constant sys_conf_ibd_lp11   : boolean := true;  -- LP11

  -- configure mass storage devices
  constant sys_conf_ibd_rk11   : boolean := true;  -- RK11
  constant sys_conf_ibd_rl11   : boolean := true;  -- RL11
  constant sys_conf_ibd_rhrp   : boolean := true;  -- RHRP
  constant sys_conf_ibd_tm11   : boolean := true;  -- TM11

  -- configure other devices
  constant sys_conf_ibd_iist   : boolean := true;  -- IIST

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
