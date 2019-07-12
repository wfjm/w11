-- $Id: sys_conf1_sim.vhd 1181 2019-07-08 17:00:50Z mueller $
-- SPDX-License-Identifier: GPL-3.0-or-later
-- Copyright 2015-2016 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
--
------------------------------------------------------------------------------
-- Package Name:   sys_conf
-- Description:    Definitions for sys_tst_serloop1_n4 (for test bench)
--
-- Dependencies:   -
-- Tool versions:  viv 2014.4-2015.4; ghdl 0.31-0.33
-- Revision History: 
-- Date         Rev Version  Comment
-- 2016-03-27   753   1.1    clock now from cmt and configurable
-- 2015-02-21   649   1.0    Initial version (cloned from sys_tst_serloop1_n3)
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

use work.slvtypes.all;

package sys_conf is

  -- in simulation a usec stays to 120 cycles (1.0 usec) and a msec to
  -- 240 cycles (2 usec). This affects mainly the autobauder. A break will be
  -- detected after 128 msec periods,  this in simulation after 256 usec or
  -- 30720 cycles. This is compatible with bitrates of 115200 baud or higher
  -- (115200 <-> 8.68 usec <-> 1040 cycles)
  
  -- configure clocks --------------------------------------------------------
  constant sys_conf_clksys_vcodivide   : positive :=   1;
  constant sys_conf_clksys_vcomultiply : positive :=  12;   -- vco 1200 MHz
  constant sys_conf_clksys_outdivide   : positive :=  10;   -- sys  120 MHz
  constant sys_conf_clksys_gentype     : string   := "MMCM";
  
  constant sys_conf_clkdiv_msecdiv  : integer := 2; -- shortened !!

  -- configure hio interfaces -----------------------------------------------
  constant sys_conf_hio_debounce : boolean := false;  -- no  debouncers

  -- configure serport ------------------------------------------------------  
  constant sys_conf_uart_cdinit : integer := 1-1;     -- 1 cycle/bit in sim

  -- derived constants =======================================================
  constant sys_conf_clksys : integer :=
    ((100000000/sys_conf_clksys_vcodivide)*sys_conf_clksys_vcomultiply) /
    sys_conf_clksys_outdivide;
  constant sys_conf_clksys_mhz : integer := sys_conf_clksys/1000000;
  
end package sys_conf;
