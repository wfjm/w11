-- $Id: simbus.vhd 1181 2019-07-08 17:00:50Z mueller $
-- SPDX-License-Identifier: GPL-3.0-or-later
-- Copyright 2007-2016 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
--
------------------------------------------------------------------------------
-- Package Name:   simbus
-- Description:    Global signals for support control in test benches
--
-- Dependencies:   -
-- Tool versions:  xst 8.2-14.7; viv 2016.2; ghdl 0.18-0.33
-- Revision History: 
-- Date         Rev Version  Comment
-- 2016-09-02   805   2.1    rename SB_CLKSTOP > SB_SIMSTOP; init with 'L'
-- 2011-12-23   444   2.0    remove global clock cycle signal SB_CLKCYCLE
-- 2010-04-24   282   1.1    add SB_(VAL|ADDR|DATA)
-- 2008-03-24   129   1.0.1  use 31 bits for SB_CLKCYCLE
-- 2007-08-27    76   1.0    Initial version 
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

use work.slvtypes.all;

package simbus is
  
  signal SB_SIMSTOP : slbit := 'L';             -- global simulation stop
  signal SB_CNTL : slv16 := (others=>'L');      -- global signals tb -> uut
  signal SB_STAT : slv16 := (others=>'0');      -- global signals uut -> tb
  signal SB_VAL : slbit := 'L';                 -- init bcast valid
  signal SB_ADDR : slv8 := (others=>'L');       -- init bcast address
  signal SB_DATA : slv16 := (others=>'L');      -- init bcast data

  -- Note: SB_SIMSTOP, SB_CNTL, SB_VAL, SB_ADDR, SB_DATA can have weak
  --       ('L','H') and strong ('0','1') drivers. Therefore always remove
  --       strenght before using, e.g. with to_x01()
  
end package simbus;
