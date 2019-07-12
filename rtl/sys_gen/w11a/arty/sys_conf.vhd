-- $Id: sys_conf.vhd 1181 2019-07-08 17:00:50Z mueller $
-- SPDX-License-Identifier: GPL-3.0-or-later
-- Copyright 2018-2019 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
--
------------------------------------------------------------------------------
-- Package Name:   sys_conf
-- Description:    Definitions for sys_w11a_arty (for synthesis)
--
-- Dependencies:   -
-- Tool versions:  viv 2017.2-2018.3; ghdl 0.34-0.35
-- Revision History: 
-- Date         Rev Version  Comment
-- 2019-06-05  1159   1.1.2  down-rate to 72 MHz, viv 2019.1 fails with 75 MHz
-- 2019-04-28  1142   1.1.1  add sys_conf_ibd_m9312
-- 2019-02-09  1110   1.1    use typ for DL,PC,LP; add dz11,ibtst
-- 2019-01-27  1108   1.0.1  down-rate to 75 MHz, viv 2018.3 fails with 80 MHz
-- 2018-11-17  1071   1.0    Initial version (derived from _br_arty version)
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

use work.slvtypes.all;

package sys_conf is

  -- configure clocks --------------------------------------------------------
  constant sys_conf_clksys_vcodivide   : positive :=   5;
  constant sys_conf_clksys_vcomultiply : positive :=  54;   -- vco 1080 MHz
  constant sys_conf_clksys_outdivide   : positive :=  15;   -- sys   72 MHz
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

  -- configure debug and monitoring units ------------------------------------
  constant sys_conf_rbmon_awidth  : integer := 9; -- use 0 to disable
  constant sys_conf_ibmon_awidth  : integer := 9; -- use 0 to disable
  constant sys_conf_ibtst         : boolean := true;
  constant sys_conf_dmscnt        : boolean := false;
  constant sys_conf_dmpcnt        : boolean := true;
  constant sys_conf_dmhbpt_nunit  : integer := 2; -- use 0 to disable
  constant sys_conf_dmcmon_awidth : integer := 8; -- use 0 to disable, 8 to use

  -- configure w11 cpu core --------------------------------------------------
  constant sys_conf_mem_losize     : natural := 8#167777#; --   4 MByte
  constant sys_conf_cache_fmiss    : slbit   := '0';     -- cache enabled
  constant sys_conf_cache_twidth   : integer :=  7;      -- 32kB cache

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
  constant sys_conf_ibd_m9312  : boolean := true;  -- M9312

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
