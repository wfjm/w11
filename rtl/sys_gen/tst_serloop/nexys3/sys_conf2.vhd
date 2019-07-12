-- $Id: sys_conf2.vhd 1181 2019-07-08 17:00:50Z mueller $
-- SPDX-License-Identifier: GPL-3.0-or-later
-- Copyright 2011- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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
