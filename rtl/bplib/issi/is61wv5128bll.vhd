-- $Id: is61wv5128bll.vhd 1181 2019-07-08 17:00:50Z mueller $
-- SPDX-License-Identifier: GPL-3.0-or-later
-- Copyright 2017- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
-- 
------------------------------------------------------------------------------
-- Module Name:    is61wv5128bll - sim
-- Description:    ISSI IS61WV5128BLL SRAM model
--                 Currently a truely minimalistic functional model, without
--                 any timing checks. It assumes, that addr/data is stable at
--                 the trailing edge of we.
--
-- Dependencies:   -
-- Test bench:     -
-- Target Devices: generic
-- Tool versions:  viv 2016.4; ghdl 0.34
-- Revision History: 
-- Date         Rev Version  Comment
-- 2017-06-04   906   1.0    Initial version  (derived from is61lv25616al)
------------------------------------------------------------------------------
-- Truth table accoring to data sheet:
--  
--     Mode          WE_N CE_N OE_N  D
-- Not selected        X    H    X   high-Z
-- Output disabled     H    L    H   high-Z
--                     X    L    X   high-Z
-- Read                H    L    L   D_out
-- Write               L    L    X   D_in

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.slvtypes.all;

entity is61wv5128bll is                 -- ISSI 61WV5128bll SRAM model
  port (
    CE_N : in slbit;                    -- chip enable        (act.low)
    OE_N : in slbit;                    -- output enable      (act.low)
    WE_N : in slbit;                    -- write enable       (act.low)
    ADDR : in slv19;                    -- address lines
    DATA : inout slv8                   -- data lines
  );
end is61wv5128bll;


architecture sim of is61wv5128bll is

  constant T_rc   : Delay_length := 10 ns;  -- read cycle time      (min)
  constant T_aa   : Delay_length := 10 ns;  -- address access time  (max)
  constant T_oha  : Delay_length :=  2 ns;  -- output hold time     (min)
  constant T_ace  : Delay_length := 10 ns;  -- ce access time       (max)
  constant T_doe  : Delay_length :=4.5 ns;  -- oe access time       (max)
  constant T_hzoe : Delay_length :=  4 ns;  -- oe to high-Z output  (max)
  constant T_lzoe : Delay_length :=  0 ns;  -- oe to low-Z output   (min)
  constant T_hzce : Delay_length :=  4 ns;  -- ce to high-Z output  (min=0,max=4)
  constant T_lzce : Delay_length :=  3 ns;  -- ce to low-Z output   (min)

  constant memsize : positive := 2**(ADDR'length);
  constant datzero : slv(DATA'range) := (others=>'0');
  type ram_type is array (0 to memsize-1) of slv(DATA'range);
  
  signal CE : slbit := '0';
  signal OE : slbit := '0';
  signal WE : slbit := '0';
  signal WE_EFF : slbit := '0';
  
begin

  CE   <= not CE_N;
  OE   <= not OE_N;
  WE   <= not WE_N;
  
  WE_EFF <= CE and WE;
  
  proc_sram: process (CE, OE, WE, WE_EFF, ADDR, DATA)
    variable ram : ram_type := (others=>datzero);
  begin

    if falling_edge(WE_EFF) then        -- end of write cycle
                                        -- note: to_x01 used below to prevent
                                        --       that 'z' a written into mem.
      ram(to_integer(unsigned(ADDR))) := to_x01(DATA);
    end if;

    if CE='1' and OE='1' and WE='0' then -- output driver
      DATA <= ram(to_integer(unsigned(ADDR)));
    else
      DATA <= (others=>'Z');
    end if;

  end process proc_sram;
  
end sim;

