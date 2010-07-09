-- $Id: tb_s3board_core.vhd 314 2010-07-09 17:38:41Z mueller $
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
-- Module Name:    tb_s3board_core - sim
-- Description:    Test bench for s3board - core device handling
--
-- Dependencies:   vlib/parts/issi/is61lv25616al
--
-- To test:        generic, any s3board target
--
-- Target Devices: generic
-- Tool versions:  xst 11.4; ghdl 0.26
-- Revision History: 
-- Date         Rev Version  Comment
-- 2010-05-02   287   1.0.1  add sbaddr_(swi|btn) defs, now sbus addr 16,17
-- 2010-04-24   282   1.0    Initial version (from vlib/s3board/tb/tb_s3board)
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_textio.all;
use std.textio.all;

use work.slvtypes.all;
use work.serport.all;
use work.simbus.all;

entity tb_s3board_core is
  port (
    I_SWI : out slv8;                   -- s3 switches
    I_BTN : out slv4;                   -- s3 buttons
    O_MEM_CE_N : in slv2;               -- sram: chip enables  (act.low)
    O_MEM_BE_N : in slv4;               -- sram: byte enables  (act.low)
    O_MEM_WE_N : in slbit;              -- sram: write enable  (act.low)
    O_MEM_OE_N : in slbit;              -- sram: output enable (act.low)
    O_MEM_ADDR  : in slv18;             -- sram: address lines
    IO_MEM_DATA : inout slv32           -- sram: data lines
  );
end tb_s3board_core;

architecture sim of tb_s3board_core is
  
  signal R_SWI : slv8 := (others=>'0');
  signal R_BTN : slv4 := (others=>'0');

  constant sbaddr_swi:  slv8 := conv_std_logic_vector( 16,8);
  constant sbaddr_btn:  slv8 := conv_std_logic_vector( 17,8);

begin
  
  MEM_L : entity work.is61lv25616al
    port map (
      CE_N => O_MEM_CE_N(0),
      OE_N => O_MEM_OE_N,
      WE_N => O_MEM_WE_N,
      UB_N => O_MEM_BE_N(1),
      LB_N => O_MEM_BE_N(0),
      ADDR => O_MEM_ADDR,
      DATA => IO_MEM_DATA(15 downto 0)
    );
  
  MEM_U : entity work.is61lv25616al
    port map (
      CE_N => O_MEM_CE_N(1),
      OE_N => O_MEM_OE_N,
      WE_N => O_MEM_WE_N,
      UB_N => O_MEM_BE_N(3),
      LB_N => O_MEM_BE_N(2),
      ADDR => O_MEM_ADDR,
      DATA => IO_MEM_DATA(31 downto 16)
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
