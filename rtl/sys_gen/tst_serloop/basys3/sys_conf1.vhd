-- $Id: sys_conf1.vhd 1369 2023-02-08 18:59:50Z mueller $
-- SPDX-License-Identifier: GPL-3.0-or-later
-- Copyright 2023- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
--
------------------------------------------------------------------------------
-- Package Name:   sys_conf
-- Description:    Definitions for sys_tst_serloop1_b3 (for synthesis)
--
-- Dependencies:   -
-- Tool versions:  viv 2022.1; ghdl 2.0.0
-- Revision History: 
-- Date         Rev Version  Comment
-- 2023-02-07  1369   1.0    Initial version
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

use work.slvtypes.all;

package sys_conf is

  -- configure clocks --------------------------------------------------------
  constant sys_conf_clksys_vcodivide   : positive :=   1;
  constant sys_conf_clksys_vcomultiply : positive :=  12;   -- vco 1200 MHz
  constant sys_conf_clksys_outdivide   : positive :=  10;   -- sys  120 MHz
  constant sys_conf_clksys_gentype     : string   := "MMCM";
  
  constant sys_conf_clkdiv_usecdiv : integer  :=  100; -- default usec 
  constant sys_conf_clkdiv_msecdiv  : integer := 1000; -- default msec

  -- configure hio interfaces -----------------------------------------------
  constant sys_conf_hio_debounce : boolean := true;   -- instantiate debouncers

  -- configure serport ------------------------------------------------------  
  constant sys_conf_uart_defbaud : integer := 115200;   -- default 115k baud

  -- derived constants =======================================================
  constant sys_conf_clksys : integer :=
    ((100000000/sys_conf_clksys_vcodivide)*sys_conf_clksys_vcomultiply) /
    sys_conf_clksys_outdivide;
  constant sys_conf_clksys_mhz : integer := sys_conf_clksys/1000000;

  constant sys_conf_uart_cdinit : integer :=
    (sys_conf_clksys/sys_conf_uart_defbaud)-1;
  
end package sys_conf;
