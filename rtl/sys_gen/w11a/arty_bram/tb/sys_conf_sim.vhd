-- $Id: sys_conf_sim.vhd 1111 2019-02-10 16:13:55Z mueller $
--
-- Copyright 2016-2019 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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
-- Description:    Definitions for sys_w11a_br_arty (for simulation)
--
-- Dependencies:   -
-- Tool versions:  viv 2015.4-2018.3; ghdl 0.33-0.35
-- Revision History: 
-- Date         Rev Version  Comment
-- 2019-02-09  1110   1.4    use typ for DL,PC,LP; add dz11,ibtst
-- 2018-09-22  1050   1.3.6  add sys_conf_dmpcnt
-- 2018-09-08  1043   1.3.5  add sys_conf_ibd_kw11p
-- 2017-01-29   847   1.3.4  add sys_conf_ibd_deuna
-- 2016-06-18   775   1.3.3  use PLL for clkser_gentype
-- 2016-05-28   770   1.3.2  sys_conf_mem_losize now type natural 
-- 2016-05-26   768   1.3.1  set dmscnt=0 (vivado fsm issue)
-- 2016-03-28   755   1.3    use serport_2clock2 -> define clkser
-- 2016-03-22   750   1.2    add sys_conf_cache_twidth
-- 2016-03-13   742   1.1    add sysmon_bus
-- 2016-02-27   736   1.0    Initial version
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
  constant sys_conf_memctl_mawidth : positive :=  4;
  constant sys_conf_memctl_nblock  : positive := 11;

  -- configure debug and monitoring units ------------------------------------
  constant sys_conf_rbmon_awidth  : integer := 0; -- no rbmon to save BRAMs
  constant sys_conf_ibmon_awidth  : integer := 0; -- no ibmon to save BRAMs
  constant sys_conf_ibtst         : boolean := true;
  constant sys_conf_dmscnt        : boolean := false;
  constant sys_conf_dmpcnt        : boolean := true;
  constant sys_conf_dmhbpt_nunit  : integer := 2; -- use 0 to disable
  constant sys_conf_dmcmon_awidth : integer := 0; -- no dmcmon to save BRAMs
  constant sys_conf_rbd_sysmon    : boolean := true;  -- SYSMON(XADC)

  -- configure w11 cpu core --------------------------------------------------
  -- sys_conf_mem_losize is highest 64 byte MMU block number
  -- the bram_memcnt uses 4*4kB memory blocks => 1 MEM block = 256 MMU blocks
  constant sys_conf_mem_losize     : natural := 256*sys_conf_memctl_nblock-1;
  
  constant sys_conf_cache_fmiss    : slbit   := '0';     -- cache enabled
  constant sys_conf_cache_twidth   : integer :=  9;      -- 8kB cache

  -- configure w11 system devices --------------------------------------------
  -- configure character and communication devices
  -- typ for DL,DZ,PC,LP: -1->none; 0->unbuffered; 4-7 buffered (typ=AWIDTH)
  constant sys_conf_ibd_dl11_0 : integer :=  6;    -- 1st DL11
  constant sys_conf_ibd_dl11_1 : integer :=  6;    -- 2nd DL11
  constant sys_conf_ibd_dz11   : integer :=  6;    -- DZ11
  constant sys_conf_ibd_pc11   : integer :=  6;    -- PC11
  constant sys_conf_ibd_lp11   : integer :=  7;    -- LP11
  constant sys_conf_ibd_deuna  : boolean := true;  -- DEUNA

  -- configure mass storage devices
  constant sys_conf_ibd_rk11   : boolean := true;  -- RK11
  constant sys_conf_ibd_rl11   : boolean := true;  -- RL11
  constant sys_conf_ibd_rhrp   : boolean := true;  -- RHRP
  constant sys_conf_ibd_tm11   : boolean := true;  -- TM11

  -- configure other devices
  constant sys_conf_ibd_iist   : boolean := true;  -- IIST
  constant sys_conf_ibd_kw11p  : boolean := true;  -- KW11P

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
