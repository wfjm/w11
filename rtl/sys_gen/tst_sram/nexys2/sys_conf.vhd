-- $Id: sys_conf.vhd 788 2016-07-16 22:23:23Z mueller $
--
-- Copyright 2010-2016 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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
-- Description:    Definitions for sys_tst_sram_n2 (for synthesis)
--
-- Dependencies:   -
-- Tool versions:  xst 11.4-14.7; ghdl 0.26-0.33
-- Revision History: 
-- Date         Rev Version  Comment
-- 2016-07-16   788   1.2    use cram_*delay functions to determine delays
-- 2012-12-20   614   1.1.4  use 85 MHz (max after rlv4 update)
-- 2010-11-27   341   1.1.3  add sys_conf_clksys_mhz (clksys in MHz)
-- 2010-11-26   340   1.1.2  default now clksys=60 MHz
-- 2010-11-22   339   1.1.1  add memctl related constants
-- 2010-11-13   338   1.1    add dcm related constants
-- 2010-05-23   294   1.0    Initial version 
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

use work.slvtypes.all;
use work.nxcramlib.all;

package sys_conf is

  constant sys_conf_clkfx_divide : positive   :=  10;
  constant sys_conf_clkfx_multiply : positive :=  17;

  constant sys_conf_ser2rri_defbaud : integer := 115200;   -- default 115k baud

  -- derived constants
  
  constant sys_conf_clksys : integer :=
    (50000000/sys_conf_clkfx_divide)*sys_conf_clkfx_multiply;
  constant sys_conf_clksys_mhz : integer := sys_conf_clksys/1000000;

  constant sys_conf_ser2rri_cdinit : integer :=
    (sys_conf_clksys/sys_conf_ser2rri_defbaud)-1;
  
  constant sys_conf_memctl_read0delay : positive :=
              cram_read0delay(sys_conf_clksys_mhz);
  constant sys_conf_memctl_read1delay : positive := 
              cram_read1delay(sys_conf_clksys_mhz);
  constant sys_conf_memctl_writedelay : positive := 
              cram_writedelay(sys_conf_clksys_mhz);

end package sys_conf;
