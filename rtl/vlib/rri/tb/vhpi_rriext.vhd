-- $Id: vhpi_rriext.vhd 314 2010-07-09 17:38:41Z mueller $
--
-- Copyright 2007- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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
-- Package Name:   vhpi_rriext
-- Description:    VHDL procedural interface: VHDL declaration side
--
-- Dependencies:   -
-- Tool versions:  xst 8.1, 8.2, 9.1, 9.2; ghdl 0.18-0.25
-- Revision History: 
-- Date         Rev Version  Comment
-- 2007-08-26    76   1.0    Initial version 
------------------------------------------------------------------------------

package vhpi_rriext is

  impure function cext_getbyte (
    clk : integer)                      -- clock cycle
    return integer;
  attribute foreign of cext_getbyte : function is "VHPIDIRECT cext_getbyte";
  
  impure function cext_putbyte (
    dat : integer)                      -- data byte
    return integer;
  attribute foreign of cext_putbyte : function is "VHPIDIRECT cext_putbyte";

end vhpi_rriext;

package body vhpi_rriext is

  impure function cext_getbyte (
    clk : integer)                      -- clock cycle
    return integer is
  begin
    report "cext_getbyte not vhpi'ed" severity failure;
  end cext_getbyte;

  impure function cext_putbyte (
    dat : integer)                      -- data byte
    return integer is
  begin
    report "cext_getbyte not vhpi'ed" severity failure;
  end cext_putbyte;

end vhpi_rriext;
