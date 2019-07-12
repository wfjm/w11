-- $Id: pdp11_sim.vhd 1181 2019-07-08 17:00:50Z mueller $
-- SPDX-License-Identifier: GPL-3.0-or-later
-- Copyright 2006-2007 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
--
------------------------------------------------------------------------------
-- Package Name:   pdp11_sim
-- Description:    Definitions for simulations
--
-- Dependencies:   -
-- Tool versions:  xst 8.1-14.7; ghdl 0.18-0.31
-- Revision History: 
-- Date         Rev Version  Comment
-- 2007-10-12    88   1.0.2  avoid ieee.std_logic_unsigned, use cast to unsigned
-- 2007-06-14    56   1.0.1  Use slvtypes.all
-- 2007-05-12    26   1.0    Initial version 
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_textio.all;
use std.textio.all;

package pdp11_sim is

  constant clock_period : Delay_length :=  20 ns;
  constant clock_offset : Delay_length := 200 ns;
  constant setup_time : Delay_length := 5 ns;
  constant c2out_time : Delay_length := 5 ns;

end package pdp11_sim;

