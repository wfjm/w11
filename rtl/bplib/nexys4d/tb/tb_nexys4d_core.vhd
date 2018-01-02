-- $Id: tb_nexys4d_core.vhd 984 2018-01-02 20:56:27Z mueller $
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
-- Module Name:    tb_nexys4d_core - sim
-- Description:    Test bench for nexys4d - core device handling
--
-- Dependencies:   -
--
-- To test:        generic, any nexys4d target
--
-- Target Devices: generic
-- Tool versions:  viv 2016.2; ghdl 0.33
-- Revision History: 
-- Date         Rev Version  Comment
-- 2017-01-04   834   1.0    Initial version (derived from tb_nexys4_core)
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;
use std.textio.all;

use work.slvtypes.all;
use work.simbus.all;

entity tb_nexys4d_core is
  port (
    I_SWI : out slv16;                  -- n4d switches
    I_BTN : out slv5;                   -- n4d buttons
    I_BTNRST_N : out slbit              -- n4d reset button
  );
end tb_nexys4d_core;

architecture sim of tb_nexys4d_core is
  
  signal R_SWI    : slv16 := (others=>'0');
  signal R_BTN    : slv5  := (others=>'0');
  signal R_BTNRST : slbit := '0';

  constant sbaddr_swi:  slv8 := slv(to_unsigned( 16,8));
  constant sbaddr_btn:  slv8 := slv(to_unsigned( 17,8));

begin
  
  proc_simbus: process (SB_VAL)
  begin
    if SB_VAL'event and to_x01(SB_VAL)='1' then
      if SB_ADDR = sbaddr_swi then
        R_SWI <= to_x01(SB_DATA(R_SWI'range));
      end if;
      if SB_ADDR = sbaddr_btn then
        R_BTN    <= to_x01(SB_DATA(R_BTN'range));
        R_BTNRST <= to_x01(SB_DATA(5));
      end if;
    end if;
  end process proc_simbus;

  I_SWI <= R_SWI;
  I_BTN <= R_BTN;
  I_BTNRST_N <= not R_BTNRST;
  
end sim;
