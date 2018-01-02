-- $Id: serportlib_tb.vhd 984 2018-01-02 20:56:27Z mueller $
--
-- Copyright 2007-2016 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
--
-- This program is free software; you may redistribute and/or modify it under
-- the terms of the GNU General Public License as published by the Free
-- Software Foundation, either version 3, or (at your option) any later version.
--
-- This program is distributed in the hope that it will be useful, but
-- WITHOUT ANY WARRANTY, without even the implied warranty of MERCHANTABILITY
-- or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
-- for complete details.
--
------------------------------------------------------------------------------
-- Package Name:   serportlib_tb
-- Description:    serial port interface components (SIM only!)
--
-- Dependencies:   -
-- Tool versions:  ghdl 0.18-0.31
--
-- Revision History: 
-- Date         Rev Version  Comment
-- 2016-01-03   724   1.0    Initial version (copied from serportlib)
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

use work.slvtypes.all;

package serportlib_tb is

  -- here only constant definitions
  -- no component defintions, use direct instantiation !
  
  constant c_serport_xon  : slv8 := "00010001"; -- char xon:  ^Q = hex 11
  constant c_serport_xoff : slv8 := "00010011"; -- char xoff  ^S = hex 13
  constant c_serport_xesc : slv8 := "00011011"; -- char xesc  ^[ = ESC = hex 1B  
  
end package serportlib_tb;
