-- $Id: tb_s3board_core.vhd 1181 2019-07-08 17:00:50Z mueller $
-- SPDX-License-Identifier: GPL-3.0-or-later
-- Copyright 2010-2016 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
-- 
------------------------------------------------------------------------------
-- Module Name:    tb_s3board_core - sim
-- Description:    Test bench for s3board - core device handling
--
-- Dependencies:   simlib/simbididly
--                 bplib/issi/is61lv25616al
--
-- To test:        generic, any s3board target
--
-- Target Devices: generic
-- Tool versions:  xst 11.4-14.7; ghdl 0.26-0.33
-- Revision History: 
-- Date         Rev Version  Comment
-- 2016-07-23   793   1.1    use simbididly
-- 2011-11-19   427   1.0.2  now numeric_std clean
-- 2010-05-02   287   1.0.1  add sbaddr_(swi|btn) defs, now sbus addr 16,17
-- 2010-04-24   282   1.0    Initial version (from vlib/s3board/tb/tb_s3board)
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;
use std.textio.all;

use work.slvtypes.all;
use work.simlib.all;
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
  
  signal MM_MEM_CE_N  : slv2 := (others=>'1');
  signal MM_MEM_BE_N  : slv4 := (others=>'1');
  signal MM_MEM_WE_N  : slbit := '1';
  signal MM_MEM_OE_N  : slbit := '1';
  signal MM_MEM_ADDR  : slv18 := (others=>'Z');
  signal MM_MEM_DATA  : slv32 := (others=>'0');

  signal R_SWI : slv8 := (others=>'0');
  signal R_BTN : slv4 := (others=>'0');

  constant sbaddr_swi:  slv8 := slv(to_unsigned( 16,8));
  constant sbaddr_btn:  slv8 := slv(to_unsigned( 17,8));
  constant pcb_delay : Delay_length := 1 ns;

begin
  
  MM_MEM_CE_N  <= O_MEM_CE_N  after pcb_delay;
  MM_MEM_BE_N  <= O_MEM_BE_N  after pcb_delay;
  MM_MEM_WE_N  <= O_MEM_WE_N  after pcb_delay;
  MM_MEM_OE_N  <= O_MEM_OE_N  after pcb_delay;
  MM_MEM_ADDR  <= O_MEM_ADDR  after pcb_delay;

  BUSDLY: simbididly
    generic map (
      DELAY  => pcb_delay,
      DWIDTH => 32)
    port map (
      A => IO_MEM_DATA,
      B => MM_MEM_DATA);

  MEM_L : entity work.is61lv25616al
    port map (
      CE_N => MM_MEM_CE_N(0),
      OE_N => MM_MEM_OE_N,
      WE_N => MM_MEM_WE_N,
      UB_N => MM_MEM_BE_N(1),
      LB_N => MM_MEM_BE_N(0),
      ADDR => MM_MEM_ADDR,
      DATA => MM_MEM_DATA(15 downto 0)
    );
  
  MEM_U : entity work.is61lv25616al
    port map (
      CE_N => MM_MEM_CE_N(1),
      OE_N => MM_MEM_OE_N,
      WE_N => MM_MEM_WE_N,
      UB_N => MM_MEM_BE_N(3),
      LB_N => MM_MEM_BE_N(2),
      ADDR => MM_MEM_ADDR,
      DATA => MM_MEM_DATA(31 downto 16)
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
