-- $Id: tb_cmoda7_core.vhd 984 2018-01-02 20:56:27Z mueller $
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
-- Module Name:    tb_cmoda7_core - sim
-- Description:    Test bench for cmoda7 - core device handling
--
-- Dependencies:   -
--
-- To test:        generic, any cmoda7 target
--
-- Target Devices: generic
-- Tool versions:  viv 2016.4; ghdl 0.34
-- Revision History: 
-- Date         Rev Version  Comment
-- 2017-06-04   906   1.0    Initial version (derived from tb_arty_core)
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;
use std.textio.all;

use work.slvtypes.all;
use work.simbus.all;

entity tb_cmoda7_core is
  port (
    I_BTN : out slv2                    -- c7 buttons
  );
end tb_cmoda7_core;

architecture sim of tb_cmoda7_core is
  
  signal R_BTN    : slv2 := (others=>'0');

  constant sbaddr_btn:  slv8 := slv(to_unsigned( 17,8));

begin
  
  proc_simbus: process (SB_VAL)
  begin
    if SB_VAL'event and to_x01(SB_VAL)='1' then
      if SB_ADDR = sbaddr_btn then
        R_BTN <= to_x01(SB_DATA(R_BTN'range));
      end if;
    end if;
  end process proc_simbus;

  I_BTN <= R_BTN;
  
end sim;
