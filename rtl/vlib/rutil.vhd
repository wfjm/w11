-- $Id: rutil.vhd 1181 2019-07-08 17:00:50Z mueller $
-- SPDX-License-Identifier: GPL-3.0-or-later
-- Copyright 2017- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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
