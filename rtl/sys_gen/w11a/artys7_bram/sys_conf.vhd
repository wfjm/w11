-- $Id: sys_conf.vhd 1043 2018-09-09 10:20:12Z mueller $
--
-- Copyright 2018- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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
-- Description:    Definitions for sys_w11a_br_artys7 (for synthesis)
--
-- Dependencies:   -
-- Tool versions:  viv 2017.2-2018.2; ghdl 0.34
-- Revision History: 
-- Date         Rev Version  Comment
-- 2018-09-08  1043   1.0.1  add sys_conf_ibd_kw11p
-- 2018-08-11  1038   1.0    Initial version (derived from _aa7 version)
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
  constant sys_conf_ser2rri_defbaud : integer := 115200;   -- default 115k baud
  constant sys_conf_hio_debounce : boolean := true;    -- instantiate debouncers

  -- configure memory controller ---------------------------------------------
  constant sys_conf_memctl_mawidth : positive :=  4;
  constant sys_conf_memctl_nblock  : positive := 16;

  -- configure debug and monitoring units ------------------------------------
  constant sys_conf_rbmon_awidth  : integer := 0; -- no rbmon to save BRAMs
  constant sys_conf_ibmon_awidth  : integer := 0; -- no ibmon to save BRAMs
  constant sys_conf_dmscnt        : boolean := false;
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

  constant sys_conf_ser2rri_cdinit : integer :=
    (sys_conf_clkser/sys_conf_ser2rri_defbaud)-1;
  
end package sys_conf;
