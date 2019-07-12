-- $Id: sys_conf1_sim.vhd 1181 2019-07-08 17:00:50Z mueller $
-- SPDX-License-Identifier: GPL-3.0-or-later
-- Copyright 2011- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
--
------------------------------------------------------------------------------
-- Package Name:   sys_conf
-- Description:    Definitions for sys_tst_serloop1_n3 (for test bench)
--
-- Dependencies:   -
-- Tool versions:  xst 13.1-14.7; ghdl 0.29-0.31
-- Revision History: 
-- Date         Rev Version  Comment
-- 2011-12-11   438   1.0    Initial version 
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

use work.slvtypes.all;

package sys_conf is

  -- in simulation a usec is shortened to 20 cycles (0.2 usec) and a msec
  -- to 100 cycles (1 usec). This affects the pulse generators (usec) and
  -- mainly the autobauder. A break will be detected after 128 msec periods,
  -- this in simulation after 128 usec or 6400 cycles. This is compatible with
  -- bitrates of 115200 baud or higher (115200 <-> 8.68 usec <-> 521 cycles)
  
  constant sys_conf_clkdiv_usecdiv : integer :=   20; -- default usec 
  constant sys_conf_clkdiv_msecdiv : integer :=    5; -- shortened !
  constant sys_conf_hio_debounce : boolean := false;  -- no debouncers
  constant sys_conf_uart_cdinit : integer := 1-1;     -- 1 cycle/bit in sim
  
end package sys_conf;
