-- $Id: tb_nexys2_core.vhd 1181 2019-07-08 17:00:50Z mueller $
-- SPDX-License-Identifier: GPL-3.0-or-later
-- Copyright 2010-2016 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
-- 
------------------------------------------------------------------------------
-- Module Name:    tb_nexys2_core - sim
-- Description:    Test bench for nexys2 - core device handling
--
-- Dependencies:   simlib/simbididly
--                 bplib/micron/mt45w8mw16b
--
-- To test:        generic, any nexys2 target
--
-- Target Devices: generic
-- Tool versions:  xst 11.4-14.7; ghdl 0.26-0.33
-- Revision History: 
-- Date         Rev Version  Comment
-- 2016-07-20   791   1.2    use simbididly
-- 2011-11-26   433   1.1.1  remove O_FLA_CE_N from tb_nexys2_core
-- 2011-11-21   432   1.1    update O_FLA_CE_N usage
-- 2011-11-19   427   1.0.1  now numeric_std clean
-- 2010-05-23   294   1.0    Initial version (derived from tb_s3board_core)
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;
use std.textio.all;

use work.slvtypes.all;
use work.simlib.all;
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
    O_MEM_ADDR  : in slv23;             -- cram: address lines
    IO_MEM_DATA : inout slv16           -- cram: data lines
  );
end tb_nexys2_core;

architecture sim of tb_nexys2_core is
  
  signal MM_MEM_CE_N  : slbit := '1';
  signal MM_MEM_BE_N  : slv2 := (others=>'1');
  signal MM_MEM_WE_N  : slbit := '1';
  signal MM_MEM_OE_N  : slbit := '1';
  signal MM_MEM_ADV_N : slbit := '1';
  signal MM_MEM_CLK   : slbit := '0';
  signal MM_MEM_CRE   : slbit := '0';
  signal MM_MEM_WAIT  : slbit := '0';
  signal MM_MEM_ADDR  : slv23 := (others=>'Z');
  signal MM_MEM_DATA  : slv16 := (others=>'0');

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
  MM_MEM_ADV_N <= O_MEM_ADV_N after pcb_delay;
  MM_MEM_CLK   <= O_MEM_CLK   after pcb_delay;
  MM_MEM_CRE   <= O_MEM_CRE   after pcb_delay;
  MM_MEM_ADDR  <= O_MEM_ADDR  after pcb_delay;
  I_MEM_WAIT   <= MM_MEM_WAIT after pcb_delay;

  BUSDLY: simbididly
    generic map (
      DELAY  => pcb_delay,
      DWIDTH => 16)
    port map (
      A => IO_MEM_DATA,
      B => MM_MEM_DATA);

  MEM : entity work.mt45w8mw16b
    port map (
      CLK   => MM_MEM_CLK,
      CE_N  => MM_MEM_CE_N,
      OE_N  => MM_MEM_OE_N,
      WE_N  => MM_MEM_WE_N,
      UB_N  => MM_MEM_BE_N(1),
      LB_N  => MM_MEM_BE_N(0),
      ADV_N => MM_MEM_ADV_N,
      CRE   => MM_MEM_CRE,
      MWAIT => MM_MEM_WAIT,
      ADDR  => MM_MEM_ADDR,
      DATA  => MM_MEM_DATA
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
