-- $Id: sys_conf_sim.vhd 1181 2019-07-08 17:00:50Z mueller $
-- SPDX-License-Identifier: GPL-3.0-or-later
-- Copyright 2010-2016 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
--
------------------------------------------------------------------------------
-- Package Name:   sys_conf
-- Description:    Definitions for sys_* (for simulation)
--
-- Dependencies:   -
-- Tool versions:  xst 11.4-14.7; ghdl 0.26-0.33
-- Revision History: 
-- Date         Rev Version  Comment
-- 2016-07-16   788   1.2    use cram_*delay functions to determine delays
-- 2011-11-27   433   1.1.2  use /1*1 to skip dcm, _ssim fails with dcm
-- 2010-11-22   339   1.1.1  add memctl related constants; now clksys=60 MHz
-- 2010-11-13   338   1.1    add dcm related constants
-- 2010-05-25   294   1.0    Initial version 
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

use work.slvtypes.all;
use work.nxcramlib.all;

package sys_conf is

  constant sys_conf_clkfx_divide : positive   := 1; -- skip dcm for sim !!
  constant sys_conf_clkfx_multiply : positive := 1;
  
  constant sys_conf_ser2rri_cdinit : integer := 1-1;   -- 1 cycle/bit in sim
  
  -- derived constants
  
  constant sys_conf_clksys : integer :=
    (50000000/sys_conf_clkfx_divide)*sys_conf_clkfx_multiply;
  constant sys_conf_clksys_mhz : integer := sys_conf_clksys/1000000;

  constant sys_conf_memctl_read0delay : positive :=
              cram_read0delay(sys_conf_clksys_mhz);
  constant sys_conf_memctl_read1delay : positive := 
              cram_read1delay(sys_conf_clksys_mhz);
  constant sys_conf_memctl_writedelay : positive := 
              cram_writedelay(sys_conf_clksys_mhz);

end package sys_conf;
