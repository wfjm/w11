-- $Id: rlink_cext_vhpi.vhd 1181 2019-07-08 17:00:50Z mueller $
-- SPDX-License-Identifier: GPL-3.0-or-later
-- Copyright 2007-2010 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
-- 
------------------------------------------------------------------------------
-- Package Name:   rlink_cext_vhpi
-- Description:    VHDL procedural interface: VHDL declaration side
--
-- Dependencies:   -
-- Tool versions:  ghdl 0.18-0.31
-- Revision History: 
-- Date         Rev Version  Comment
-- 2010-12-29   351   1.1    rename vhpi_rriext->rlink_cext_vhpi; new rbv3 names
-- 2007-08-26    76   1.0    Initial version 
------------------------------------------------------------------------------

package rlink_cext_vhpi is

  impure function rlink_cext_getbyte (
    clk : integer)                      -- clock cycle
    return integer;
  attribute foreign of rlink_cext_getbyte :
    function is "VHPIDIRECT rlink_cext_getbyte";
  
  impure function rlink_cext_putbyte (
    dat : integer)                      -- data byte
    return integer;
  attribute foreign of rlink_cext_putbyte :
    function is "VHPIDIRECT rlink_cext_putbyte";

end package rlink_cext_vhpi;

package body rlink_cext_vhpi is

  impure function rlink_cext_getbyte (
    clk : integer)                      -- clock cycle
    return integer is
  begin
    report "rlink_cext_getbyte not vhpi'ed" severity failure;
  end rlink_cext_getbyte;

  impure function rlink_cext_putbyte (
    dat : integer)                      -- data byte
    return integer is
  begin
    report "rlink_cext_getbyte not vhpi'ed" severity failure;
  end rlink_cext_putbyte;

end package body rlink_cext_vhpi;
