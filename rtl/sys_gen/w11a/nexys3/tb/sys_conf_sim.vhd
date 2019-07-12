-- $Id: sys_conf_sim.vhd 1181 2019-07-08 17:00:50Z mueller $
-- SPDX-License-Identifier: GPL-3.0-or-later
-- Copyright 2011-2019 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
--
------------------------------------------------------------------------------
-- Package Name:   sys_conf
-- Description:    Definitions for sys_w11a_n3 (for simulation)
--
-- Dependencies:   -
-- Tool versions:  xst 13.1-14.7; ghdl 0.29-0.35
-- Revision History: 
-- Date         Rev Version  Comment
-- 2019-04-28  1142   1.8.1  add sys_conf_ibd_m9312
-- 2019-02-09  1110   1.8    use typ for DL,PC,LP; add dz11,ibtst
-- 2019-01-27  1108   1.7.5  drop iist
-- 2018-09-22  1050   1.7.4  add sys_conf_dmpcnt
-- 2018-09-08  1043   1.7.3  add sys_conf_ibd_kw11p
-- 2017-04-22   884   1.7.2  use sys_conf_dmcmon_awidth=8 (proper value)
-- 2017-01-29   847   1.7.1  add sys_conf_ibd_deuna
-- 2016-07-16   788   1.7    use cram_*delay functions to determine delays
-- 2016-05-28   770   1.6.1  sys_conf_mem_losize now type natural 
-- 2016-03-22   750   1.6    add sys_conf_cache_twidth
-- 2015-12-26   718   1.5.2  use clksys=64 (as since r692 in sys_conf.vhd)
-- 2015-06-26   695   1.5.1  add sys_conf_(dmscnt|dmhbpt*|dmcmon*)
-- 2015-03-14   658   1.5    add sys_conf_ibd_* definitions
-- 2015-02-15   647   1.4    drop bram and minisys options
-- 2014-12-22   619   1.3.1  add _rbmon_awidth
-- 2013-10-06   538   1.3    pll support, use clksys_vcodivide ect
-- 2013-04-21   509   1.2    add fx2 settings
-- 2011-11-25   432   1.0    Initial version (cloned from _n3)
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

use work.slvtypes.all;
use work.nxcramlib.all;

package sys_conf is

  -- configure clocks --------------------------------------------------------
  constant sys_conf_clksys_vcodivide   : positive :=  25;
  constant sys_conf_clksys_vcomultiply : positive :=  16;   -- dcm   64 MHz
  constant sys_conf_clksys_outdivide   : positive :=   1;   -- sys   64 MHz
  constant sys_conf_clksys_gentype     : string   := "DCM";

  -- configure rlink and hio interfaces --------------------------------------
  constant sys_conf_ser2rri_cdinit : integer := 1-1;   -- 1 cycle/bit in sim
  constant sys_conf_hio_debounce : boolean := false;   -- no debouncers

  -- fx2 settings: petowidth=10 -> 2^10 30 MHz clocks -> ~33 usec
  constant sys_conf_fx2_petowidth  : positive := 10;
  constant sys_conf_fx2_ccwidth  : positive := 5;
    
  -- configure memory controller ---------------------------------------------
  -- now under derived constants

  -- configure debug and monitoring units ------------------------------------
  constant sys_conf_rbmon_awidth  : integer := 9; -- use 0 to disable
  constant sys_conf_ibmon_awidth  : integer := 9; -- use 0 to disable
  constant sys_conf_ibtst         : boolean := true;
  constant sys_conf_dmscnt        : boolean := true;
  constant sys_conf_dmpcnt        : boolean := true;
  constant sys_conf_dmhbpt_nunit  : integer := 2; -- use 0 to disable
  constant sys_conf_dmcmon_awidth : integer := 8; -- use 0 to disable

  -- configure w11 cpu core --------------------------------------------------
  constant sys_conf_mem_losize     : natural := 8#167777#; --   4 MByte

  constant sys_conf_cache_fmiss    : slbit   := '0';     -- cache enabled
  constant sys_conf_cache_twidth   : integer :=  9;      -- 8kB cache

   -- configure w11 system devices --------------------------------------------
 -- configure character and communication devices
  -- typ for DL,DZ,PC,LP: -1->none; 0->unbuffered; 4-7 buffered (typ=AWIDTH)
  constant sys_conf_ibd_dl11_0 : integer :=  4;    -- 1st DL11
  constant sys_conf_ibd_dl11_1 : integer :=  4;    -- 2nd DL11
  constant sys_conf_ibd_dz11   : integer :=  5;    -- DZ11
  constant sys_conf_ibd_pc11   : integer :=  4;    -- PC11
  constant sys_conf_ibd_lp11   : integer :=  5;    -- LP11
  constant sys_conf_ibd_deuna  : boolean := true;  -- DEUNA

  -- configure mass storage devices
  constant sys_conf_ibd_rk11   : boolean := true;  -- RK11
  constant sys_conf_ibd_rl11   : boolean := true;  -- RL11
  constant sys_conf_ibd_rhrp   : boolean := true;  -- RHRP
  constant sys_conf_ibd_tm11   : boolean := true;  -- TM11

  -- configure other devices
  constant sys_conf_ibd_iist   : boolean := false; -- IIST
  constant sys_conf_ibd_kw11p  : boolean := true;  -- KW11P
  constant sys_conf_ibd_m9312  : boolean := true;  -- M9312

  -- derived constants =======================================================

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
