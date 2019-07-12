-- $Id: sys_conf_sim.vhd 1181 2019-07-08 17:00:50Z mueller $
-- SPDX-License-Identifier: GPL-3.0-or-later
-- Copyright 2011- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
--
------------------------------------------------------------------------------
-- Package Name:   sys_conf
-- Description:    Definitions for tb_nexys2_fusp_dummy (for simulation)
--
-- Dependencies:   -
-- Tool versions:  xst 13.1; ghdl 0.29
-- Revision History: 
-- Date         Rev Version  Comment
-- 2011-12-23   444   1.0    Initial version
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

use work.slvtypes.all;

package sys_conf is

  constant sys_conf_clkfx_divide : positive   :=   2;
  constant sys_conf_clkfx_multiply : positive :=   3;  -- ==> 75 MHz

  -- derived constants

  constant sys_conf_clksys : integer :=
    (50000000/sys_conf_clkfx_divide)*sys_conf_clkfx_multiply;
  constant sys_conf_clksys_mhz : integer := sys_conf_clksys/1000000;

end package sys_conf;

