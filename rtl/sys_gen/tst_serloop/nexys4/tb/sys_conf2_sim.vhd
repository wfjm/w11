-- $Id: sys_conf2_sim.vhd 775 2016-06-18 13:42:00Z mueller $
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
-- Description:    Definitions for sys_tst_serloop2_n4 (for test bench)
--
-- Dependencies:   -
-- Tool versions:  viv 2015.4-2016.2; ghdl 0.33
-- Revision History: 
-- Date         Rev Version  Comment
-- 2016-06-18   775   1.0.1  use PLL for clkser_gentype
-- 2016-04-09   760   1.0    Initial version
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
  constant sys_conf_clksys_vcodivide   : positive :=   5;   -- f     20 Mhz
  constant sys_conf_clksys_vcomultiply : positive :=  36;   -- vco  720 MHz
  constant sys_conf_clksys_outdivide   : positive :=  10;   -- sys   72 MHz
  constant sys_conf_clksys_gentype     : string   := "MMCM";

  constant sys_conf_clksys_msecdiv  : integer := 2; -- shortened !!

  constant sys_conf_clkser_vcodivide   : positive :=   1;
  constant sys_conf_clkser_vcomultiply : positive :=  12;   -- vco 1200 MHz
  constant sys_conf_clkser_outdivide   : positive :=  10;   -- sys  120 MHz
  constant sys_conf_clkser_gentype     : string   := "PLL";

  constant sys_conf_clkser_msecdiv  : integer := 2; -- shortened !!

  -- configure hio interfaces -----------------------------------------------
  constant sys_conf_hio_debounce : boolean := false;  -- no  debouncers

  -- configure serport ------------------------------------------------------  
  constant sys_conf_uart_cdinit : integer := 1-1;     -- 1 cycle/bit in sim

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
