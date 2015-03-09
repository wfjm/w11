-- $Id: sys_conf.vhd 649 2015-02-21 21:10:16Z mueller $
--
-- Copyright 2015- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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
-- Description:    Definitions for sys_w11a_b3 (for synthesis)
--
-- Dependencies:   -
-- Tool versions:  viv 2014.4; ghdl 0.31
-- Revision History: 
-- Date         Rev Version  Comment
-- 2015-02-08   644   1.0    Initial version (derived from _n4 version)
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

use work.slvtypes.all;

package sys_conf is

  constant sys_conf_clksys_vcodivide   : positive :=   1;
  constant sys_conf_clksys_vcomultiply : positive :=   8;   -- vco  800 MHz
  constant sys_conf_clksys_outdivide   : positive :=  10;   -- sys   80 MHz
  constant sys_conf_clksys_gentype     : string   := "MMCM";
  -- single clock design, clkser = clksys
  constant sys_conf_clkser_vcodivide   : positive := sys_conf_clksys_vcodivide;
  constant sys_conf_clkser_vcomultiply : positive := sys_conf_clksys_vcomultiply;
  constant sys_conf_clkser_outdivide   : positive := sys_conf_clksys_outdivide;
  constant sys_conf_clkser_gentype     : string   := sys_conf_clksys_gentype;

  constant sys_conf_ser2rri_defbaud : integer := 115200;   -- default 115k baud

  constant sys_conf_hio_debounce : boolean := true;    -- instantiate debouncers

  constant sys_conf_memctl_mawidth : positive :=  4;
  constant sys_conf_memctl_nblock  : positive := 11;

  -- sys_conf_mem_losize is highest 64 byte MMU block number
  -- the bram_memcnt uses 4*4kB memory blocks => 1 MEM block = 256 MMU blocks
  constant sys_conf_mem_losize     : integer := 256*sys_conf_memctl_nblock-1;

  constant sys_conf_cache_fmiss    : slbit   := '0';     -- cache enabled

  -- derived constants

  constant sys_conf_clksys : integer :=
    ((100000000/sys_conf_clksys_vcodivide)*sys_conf_clksys_vcomultiply) /
    sys_conf_clksys_outdivide;
  constant sys_conf_clksys_mhz : integer := sys_conf_clksys/1000000;

  constant sys_conf_clkser : integer :=
    ((100000000/sys_conf_clkser_vcodivide)*sys_conf_clkser_vcomultiply) /
    sys_conf_clkser_outdivide;
  constant sys_conf_clkser_mhz : integer := sys_conf_clkser/1000000;

  constant sys_conf_ser2rri_cdinit : integer :=
    (sys_conf_clkser/sys_conf_ser2rri_defbaud)-1;
  
end package sys_conf;

-- Note: mem_losize holds 16 MSB of the PA of the addressable memory
--        2 211 111 111 110 000 000 000
--        1 098 765 432 109 876 543 210
--
--        0 000 000 011 111 111 000 000  -> 00037777  --> 14bit -->  16 kByte
--        0 000 000 111 111 111 000 000  -> 00077777  --> 15bit -->  32 kByte
--        0 000 001 111 111 111 000 000  -> 00177777  --> 16bit -->  64 kByte
--        0 000 011 111 111 111 000 000  -> 00377777  --> 17bit --> 128 kByte
--        0 011 111 111 111 111 000 000  -> 03777777  --> 20bit -->   1 MByte
--        1 110 111 111 111 111 000 000  -> 16777777  --> 22bit -->   4 MByte
--                                          upper 256 kB excluded for 11/70 UB
