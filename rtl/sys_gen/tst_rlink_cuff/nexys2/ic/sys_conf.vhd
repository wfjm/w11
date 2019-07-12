-- $Id: sys_conf.vhd 1181 2019-07-08 17:00:50Z mueller $
-- SPDX-License-Identifier: GPL-3.0-or-later
-- Copyright 2012- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
--
------------------------------------------------------------------------------
-- Package Name:   sys_conf
-- Description:    Definitions for sys_tst_rlink_cuff_ic_n2 (for synthesis)
--
-- Dependencies:   -
-- Tool versions:  xst 13.3-14.7; ghdl 0.29-0.31
-- Revision History: 
-- Date         Rev Version  Comment
-- 2012-12-29   466   1.0    Initial version 
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

use work.slvtypes.all;

package sys_conf is

  constant sys_conf_clkfx_divide : positive   :=  1;
  constant sys_conf_clkfx_multiply : positive :=  1;

  constant sys_conf_ser2rri_defbaud : integer := 115200;   -- default 115k baud
  constant sys_conf_hio_debounce : boolean := true;    -- instantiate debouncers

  constant sys_conf_fx2_type : string := "ic2";

  -- dummy values defs for generic parameters of as controller
  constant sys_conf_fx2_rdpwldelay : positive := 1;
  constant sys_conf_fx2_rdpwhdelay : positive := 1;
  constant sys_conf_fx2_wrpwldelay : positive := 1;
  constant sys_conf_fx2_wrpwhdelay : positive := 1;
  constant sys_conf_fx2_flagdelay  : positive := 1;

  -- pktend timer setting
  --   petowidth=10 -> 2^10 30 MHz clocks -> ~33 usec (normal operation)
  constant sys_conf_fx2_petowidth  : positive := 10;

  constant sys_conf_fx2_ccwidth  : positive := 5;
   
  -- derived constants
  
  constant sys_conf_clksys : integer :=
    (50000000/sys_conf_clkfx_divide)*sys_conf_clkfx_multiply;
  constant sys_conf_clksys_mhz : integer := sys_conf_clksys/1000000;

  constant sys_conf_ser2rri_cdinit : integer :=
    (sys_conf_clksys/sys_conf_ser2rri_defbaud)-1;

end package sys_conf;
