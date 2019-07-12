-- $Id: sys_conf.vhd 1181 2019-07-08 17:00:50Z mueller $
-- SPDX-License-Identifier: GPL-3.0-or-later
-- Copyright 2011-2016 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
--
------------------------------------------------------------------------------
-- Package Name:   sys_conf
-- Description:    Definitions for sys_tst_sram_n3 (for synthesis)
--
-- Dependencies:   -
-- Tool versions:  xst 13.1-14.7; ghdl 0.29-0.33
-- Revision History: 
-- Date         Rev Version  Comment
-- 2016-07-10   786   1.2    memctl with page mode, new read1delay
-- 2013-10-06   538   1.1    pll support, use clksys_vcodivide ect
-- 2011-11-27   433   1.0    Initial version 
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

use work.slvtypes.all;
use work.nxcramlib.all;

package sys_conf is

  constant sys_conf_clksys_vcodivide   : positive :=   1;
  constant sys_conf_clksys_vcomultiply : positive :=   1;   -- dcm  100 MHz
  constant sys_conf_clksys_outdivide   : positive :=   1;   -- sys  100 MHz
  constant sys_conf_clksys_gentype     : string   := "DCM";
  
  constant sys_conf_ser2rri_defbaud : integer := 115200;   -- default 115k baud

  -- derived constants
  
  constant sys_conf_clksys : integer :=
    ((100000000/sys_conf_clksys_vcodivide)*sys_conf_clksys_vcomultiply) /
    sys_conf_clksys_outdivide;
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
