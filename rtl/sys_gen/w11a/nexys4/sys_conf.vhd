-- $Id: sys_conf.vhd 1181 2019-07-08 17:00:50Z mueller $
-- SPDX-License-Identifier: GPL-3.0-or-later
-- Copyright 2013-2019 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
--
------------------------------------------------------------------------------
-- Package Name:   sys_conf
-- Description:    Definitions for sys_w11a_n4 (for synthesis)
--
-- Dependencies:   -
-- Tool versions:  ise 14.5-14.7; viv 2014.4-2018.3; ghdl 0.29-0.35
-- Revision History: 
-- Date         Rev Version  Comment
-- 2019-04-28  1142   1.6.1  add sys_conf_ibd_m9312
-- 2019-02-09  1110   1.6    use typ for DL,PC,LP; add dz11,ibtst
-- 2018-09-22  1050   1.5.6  add sys_conf_dmpcnt
-- 2018-09-09  1044   1.5.5  use _cache_twidth TW=7 (32 kByte), timing issues
-- 2018-09-08  1043   1.5.4  add sys_conf_ibd_kw11p
-- 2017-04-22   884   1.5.3  re-enable dmcmon
-- 2017-03-04   858   1.5.2  enable deuna
-- 2017-01-29   847   1.5.1  add sys_conf_ibd_deuna
-- 2016-07-16   788   1.5    use cram_*delay functions to determine delays
-- 2016-06-18   775   1.4.5  use PLL for clkser_gentype
-- 2016-06-04   772   1.4.4  go for 80 MHz and 64 kB cache, best compromise
-- 2016-05-28   771   1.4.3  set dmcmon_awidth=0, useless without dmscnt
-- 2016-05-28   770   1.4.2  sys_conf_mem_losize now type natural 
-- 2016-05-26   768   1.4.1  set dmscnt=0 (vivado fsm issue); TW=8 (@90 MHz)
-- 2016-03-28   755   1.4    use serport_2clock2 -> define clkser  (@75 MHz)
-- 2016-03-22   750   1.3    add sys_conf_cache_twidth, use TW=8 (16 kByte)
-- 2016-03-13   742   1.2.2  add sysmon_bus
-- 2015-06-26   695   1.2.1  add sys_conf_(dmscnt|dmhbpt*|dmcmon*)
-- 2015-03-14   658   1.2    add sys_conf_ibd_* definitions
-- 2015-02-07   643   1.1    drop bram and minisys options
-- 2013-09-22   534   1.0    Initial version (derived from _n3 version)
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

use work.slvtypes.all;
use work.nxcramlib.all;

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
  -- now under derived constants

  -- configure debug and monitoring units ------------------------------------
  constant sys_conf_rbmon_awidth  : integer := 9; -- use 0 to disable
  constant sys_conf_ibmon_awidth  : integer := 9; -- use 0 to disable
  constant sys_conf_ibtst         : boolean := true;
  constant sys_conf_dmscnt        : boolean := false;
  constant sys_conf_dmpcnt        : boolean := true;
  constant sys_conf_dmhbpt_nunit  : integer := 2; -- use 0 to disable
  constant sys_conf_dmcmon_awidth : integer := 8; -- use 0 to disable, 8 to use
  constant sys_conf_rbd_sysmon    : boolean := true;  -- SYSMON(XADC)

  -- configure w11 cpu core --------------------------------------------------
  constant sys_conf_mem_losize     : natural := 8#167777#; --   4 MByte
  
  constant sys_conf_cache_fmiss    : slbit   := '0';     -- cache enabled
  constant sys_conf_cache_twidth   : integer :=  7;      --  32kB cache
    
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
  
  -- configure memory controller ---------------------------------------------
  constant sys_conf_memctl_read0delay : positive :=
              cram_read0delay(sys_conf_clksys_mhz);
  constant sys_conf_memctl_read1delay : positive := 
              cram_read1delay(sys_conf_clksys_mhz);
  constant sys_conf_memctl_writedelay : positive := 
              cram_writedelay(sys_conf_clksys_mhz);

end package sys_conf;
