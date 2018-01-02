-- $Id: sys_conf2.vhd 984 2018-01-02 20:56:27Z mueller $
--
-- Copyright 2017- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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
-- Description:    Definitions for sys_tst_serloop2_n4d (for synthesis)
--
-- Dependencies:   -
-- Tool versions:  viv 2016.2; ghdl 0.33
-- Revision History: 
-- Date         Rev Version  Comment
-- 2017-01-04   838   1.0    Initial version
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

use work.slvtypes.all;

package sys_conf is

  -- configure clocks --------------------------------------------------------
  constant sys_conf_clksys_vcodivide   : positive :=   5;   -- f     20 Mhz
  constant sys_conf_clksys_vcomultiply : positive :=  36;   -- vco  720 MHz
  constant sys_conf_clksys_outdivide   : positive :=  10;   -- sys   72 MHz
  constant sys_conf_clksys_gentype     : string   := "MMCM";
  
  constant sys_conf_clksys_msecdiv  : integer := 1000; -- default msec

  constant sys_conf_clkser_vcodivide   : positive :=   1;
  constant sys_conf_clkser_vcomultiply : positive :=  12;   -- vco 1200 MHz
  constant sys_conf_clkser_outdivide   : positive :=  10;   -- sys  120 MHz
  constant sys_conf_clkser_gentype     : string   := "PLL";
  
  constant sys_conf_clkser_msecdiv  : integer := 1000; -- default msec

  -- configure hio interfaces -----------------------------------------------
  constant sys_conf_hio_debounce : boolean := true;   -- instantiate debouncers

  -- configure serport ------------------------------------------------------  
  constant sys_conf_uart_defbaud : integer := 115200;   -- default 115k baud

  -- derived constants =======================================================
  constant sys_conf_clksys : integer :=
    ((100000000/sys_conf_clksys_vcodivide)*sys_conf_clksys_vcomultiply) /
    sys_conf_clksys_outdivide;
  constant sys_conf_clksys_mhz : integer := sys_conf_clksys/1000000;

  constant sys_conf_clkser : integer :=
    ((100000000/sys_conf_clkser_vcodivide)*sys_conf_clkser_vcomultiply) /
    sys_conf_clkser_outdivide;
  constant sys_conf_clkser_mhz : integer := sys_conf_clkser/1000000;

  constant sys_conf_uart_cdinit : integer :=
    (sys_conf_clkser/sys_conf_uart_defbaud)-1;
  
end package sys_conf;
