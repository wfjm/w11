-- $Id: rutil.vhd 984 2018-01-02 20:56:27Z mueller $
--
-- Copyright 2017- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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
-- Package Name:   rutil
-- Description:    Miscellaneous helper functions
--
-- Dependencies:   -
-- Tool versions:  ise 14.7; viv 2017.1; ghdl 0.34
-- Revision History: 
-- Date         Rev Version  Comment
-- 2017-06-25    44   1.0    Initial version 
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

package rutil is
  function imin (left, right: integer) return integer;
end package rutil;

package body rutil is
  function imin (left, right: integer) return integer is
  begin
    if left < right then
      return left;
    else
      return right;
    end if;
  end imin;
end package body rutil;
