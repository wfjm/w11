-- $Id: tb_nexys2_core.vhd 314 2010-07-09 17:38:41Z mueller $
--
-- Copyright 2010- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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
-- Module Name:    tb_nexys2_core - sim
-- Description:    Test bench for nexys2 - core device handling
--
-- Dependencies:   vlib/parts/micron/mt45w8mw16b
--
-- To test:        generic, any nexys2 target
--
-- Target Devices: generic
-- Tool versions:  xst 11.4; ghdl 0.26
-- Revision History: 
-- Date         Rev Version  Comment
-- 2010-05-23   294   1.0    Initial version (derived from tb_s3board_core)
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_textio.all;
use std.textio.all;

use work.slvtypes.all;
use work.serport.all;
use work.simbus.all;

entity tb_nexys2_core is
  port (
    I_SWI : out slv8;                   -- n2 switches
    I_BTN : out slv4;                   -- n2 buttons
    O_MEM_CE_N : in slbit;              -- cram: chip enable   (act.low)
    O_MEM_BE_N : in slv2;               -- cram: byte enables  (act.low)
    O_MEM_WE_N : in slbit;              -- cram: write enable  (act.low)
    O_MEM_OE_N : in slbit;              -- cram: output enable (act.low)
    O_MEM_ADV_N  : in slbit;            -- cram: address valid (act.low)
    O_MEM_CLK : in slbit;               -- cram: clock
    O_MEM_CRE : in slbit;               -- cram: command register enable
    I_MEM_WAIT : out slbit;             -- cram: mem wait
    O_FLA_CE_N : in slbit;              -- flash ce..          (act.low)
    O_MEM_ADDR  : in slv23;             -- cram: address lines
    IO_MEM_DATA : inout slv16           -- cram: data lines
  );
end tb_nexys2_core;

architecture sim of tb_nexys2_core is
  
  signal R_SWI : slv8 := (others=>'0');
  signal R_BTN : slv4 := (others=>'0');

  constant sbaddr_swi:  slv8 := conv_std_logic_vector( 16,8);
  constant sbaddr_btn:  slv8 := conv_std_logic_vector( 17,8);

begin
  
  MEM : entity work.mt45w8mw16b
    port map (
      CLK   => O_MEM_CLK,
      CE_N  => O_MEM_CE_N,
      OE_N  => O_MEM_OE_N,
      WE_N  => O_MEM_WE_N,
      UB_N  => O_MEM_BE_N(1),
      LB_N  => O_MEM_BE_N(0),
      ADV_N => O_MEM_ADV_N,
      CRE   => O_MEM_CRE,
      MWAIT => I_MEM_WAIT,
      ADDR  => O_MEM_ADDR,
      DATA  => IO_MEM_DATA
    );
  
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
