-- $Id: sys_conf.vhd 314 2010-07-09 17:38:41Z mueller $
--
-- Copyright 2007-2008 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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
-- Description:    Default definitions for pdp11core (for simple test benches)
--
-- Dependencies:   -
-- Tool versions:  xst 8.1, 8.2, 9.1, 9.2; ghdl 0.18-0.25
-- Revision History: 
-- Date         Rev Version  Comment
-- 2008-02-23   118   1.0    Initial version 
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

use work.slvtypes.all;

package sys_conf is

  constant sys_conf_bram_awidth    : integer := 15;       -- 32 kB BRAM
  constant sys_conf_mem_losize     : integer := 8#000777#;-- 32 kByte
--  constant sys_conf_bram_awidth    : integer := 14;       -- 16 kB BRAM
--  constant sys_conf_mem_losize     : integer := 8#000377#;-- 16 kByte

end package sys_conf;

-- Note: mem_losize holds 16 MSB of the PA of the addressable memory
--        2 211 111 111 110 000 000 000
--        1 098 765 432 109 876 543 210
--
--        0 000 000 011 111 111 000 000  -> 00037777  --> 14bit --> 16 kByte
--        0 000 000 011 111 111 000 000  -> 00077777  --> 15bit --> 32 kByte
--        0 011 111 111 111 111 000 000  -> 03777777  --> 20bit -->  1 MByte
--        1 110 111 111 111 111 000 000  -> 16777777  --> 22bit -->  4 MByte
--                                          upper 256 kB excluded for 11/70 UB
