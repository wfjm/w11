-- $Id: tb_artys7_core.vhd 1038 2018-08-11 12:39:52Z mueller $
--
-- Copyright 2018- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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
-- Module Name:    tb_artys7_core - sim
-- Description:    Test bench for artys7 - core device handling
--
-- Dependencies:   -
--
-- To test:        generic, any artys7 target
--
-- Target Devices: generic
-- Tool versions:  viv 2017.2-2018.2; ghdl 0.34
-- Revision History: 
-- Date         Rev Version  Comment
-- 2018-08-05  1038   1.0    Initial version (derived from tb_artya7_core)
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;
use std.textio.all;

use work.slvtypes.all;
use work.simbus.all;

entity tb_artys7_core is
  port (
    I_SWI : out slv4;                   -- artys7 switches
    I_BTN : out slv4                    -- artys7 buttons
  );
end tb_artys7_core;

architecture sim of tb_artys7_core is
  
  signal R_SWI    : slv4 := (others=>'0');
  signal R_BTN    : slv4 := (others=>'0');

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
        R_BTN <= to_x01(SB_DATA(R_BTN'range));
      end if;
    end if;
  end process proc_simbus;

  I_SWI <= R_SWI;
  I_BTN <= R_BTN;
  
end sim;
