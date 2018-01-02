-- $Id: sys_conf2.vhd 984 2018-01-02 20:56:27Z mueller $
--
-- Copyright 2011- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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
-- Description:    Definitions for sys_tst_serloop2_n3 (for synthesis)
--
-- Dependencies:   -
-- Tool versions:  xst 13.1; ghdl 0.29
-- Revision History: 
-- Date         Rev Version  Comment
-- 2011-12-11   438   1.0.1  use with ser=usr=100 MHz
-- 2011-11-27   433   1.0    Initial version
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

use work.slvtypes.all;

package sys_conf is

  constant sys_conf_clkudiv_usecdiv : integer :=  100; -- default usec (was 150)
  constant sys_conf_clksdiv_usecdiv : integer :=  100; -- default usec (was  60)
  constant sys_conf_clkdiv_msecdiv  : integer := 1000; -- default msec
  constant sys_conf_hio_debounce : boolean := true;   -- instantiate debouncers
  constant sys_conf_uart_cdinit : integer := 868-1;   -- 100000000/115200
  
end package sys_conf;
