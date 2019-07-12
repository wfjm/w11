-- $Id: sys_conf.vhd 1181 2019-07-08 17:00:50Z mueller $
-- SPDX-License-Identifier: GPL-3.0-or-later
-- Copyright 2011- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
--
------------------------------------------------------------------------------
-- Package Name:   sys_conf
-- Description:    Definitions for sys_tst_serloop_s3 (for synthesis)
--
-- Dependencies:   -
-- Tool versions:  xst 13.1-14.7; ghdl 0.29-0.31
-- Revision History: 
-- Date         Rev Version  Comment
-- 2011-11-13   424   1.0    Initial version
-- 2011-10-25   419   0.5    First draft 
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

use work.slvtypes.all;

package sys_conf is

  constant sys_conf_clkdiv_usecdiv : integer :=   60; -- default usec 
  constant sys_conf_clkdiv_msecdiv : integer := 1000; -- default msec
  constant sys_conf_hio_debounce : boolean := true;   -- instantiate debouncers
  constant sys_conf_uart_cdinit : integer := 521-1;   -- 60000000/115200

end package sys_conf;
