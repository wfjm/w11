-- $Id: sys_conf.vhd 1181 2019-07-08 17:00:50Z mueller $
-- SPDX-License-Identifier: GPL-3.0-or-later
-- Copyright 2017- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
--
------------------------------------------------------------------------------
-- Package Name:   sys_conf
-- Description:    Definitions for sys_tst_sram_c7 (for synthesis)
--
-- Dependencies:   -
-- Tool versions:  viv 2017.1; ghdl 0.34
-- Revision History: 
-- Date         Rev Version  Comment
-- 2017-06-11   912   1.0    Initial version 
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

use work.slvtypes.all;

package sys_conf is

  constant sys_conf_clksys_vcodivide   : positive :=   1;
  constant sys_conf_clksys_vcomultiply : positive :=  60;   -- vco  720 MHz
  constant sys_conf_clksys_outdivide   : positive :=   9;   -- sys   80 MHz
  constant sys_conf_clksys_gentype     : string   := "MMCM";
  -- dual clock design, clkser = 120 MHz
  constant sys_conf_clkser_vcodivide   : positive :=   1;
  constant sys_conf_clkser_vcomultiply : positive :=  60;   -- vco  720 MHz
  constant sys_conf_clkser_outdivide   : positive :=   6;   -- sys  120 MHz
  constant sys_conf_clkser_gentype     : string   := "MMCM";
  
  constant sys_conf_ser2rri_defbaud : integer := 115200;   -- default 115k baud

  -- derived constants
  
  constant sys_conf_clksys : integer :=
    ((12000000/sys_conf_clksys_vcodivide)*sys_conf_clksys_vcomultiply) /
    sys_conf_clksys_outdivide;
  constant sys_conf_clksys_mhz : integer := sys_conf_clksys/1000000;

  constant sys_conf_clkser : integer :=
     ((12000000/sys_conf_clkser_vcodivide)*sys_conf_clkser_vcomultiply) /
    sys_conf_clkser_outdivide;
  constant sys_conf_clkser_mhz : integer := sys_conf_clkser/1000000;

  constant sys_conf_ser2rri_cdinit : integer :=
    (sys_conf_clkser/sys_conf_ser2rri_defbaud)-1;

end package sys_conf;
