-- $Id: sn_4x7segctl.vhd 400 2011-07-31 09:02:16Z mueller $
--
-- Copyright 2007-2011 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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
-- Module Name:    sn_4x7segctl - syn
-- Description:    Quad 7 segment display controller (for s3board and nexys2/3)
--
-- Dependencies:   -
-- Test bench:     -
-- Target Devices: generic
-- Tool versions:  xst 8.1, 8.2, 9.1, 9.2, 11.4, 12.1; ghdl 0.18-0.29
-- Revision History: 
-- Date         Rev Version  Comment
-- 2011-07-30   400   1.2    digit dark in last quarter (not 16 clocks)
-- 2011-07-08   390   1.1.2  renamed from s3_dispdrv
-- 2010-04-17   278   1.1.1  renamed from dispdrv
-- 2010-03-29   272   1.1    add all ANO off time to allow to driver turn-off
--                           delay and to avoid cross talk between digits
-- 2007-12-16   101   1.0.1  use _N for active low
-- 2007-09-16    83   1.0    Initial version 
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

use work.slvtypes.all;

entity sn_4x7segctl is                  -- Quad 7 segment display controller
  generic (
    CDWIDTH : positive := 6);           -- clk divider width (must be >= 5)
  port (
    CLK : in slbit;                     -- clock
    DIN : in slv16;                     -- data
    DP : in slv4;                       -- decimal points
    ANO_N : out slv4;                   -- anodes    (act.low)
    SEG_N : out slv8                    -- segements (act.low)
  );
end sn_4x7segctl;

architecture syn of sn_4x7segctl is

  type regs_type is record
    cdiv : std_logic_vector(CDWIDTH-1 downto 0); -- clock divider counter
    dcnt : slv2;                                 -- digit counter
  end record regs_type;

  constant regs_init : regs_type := (
    conv_std_logic_vector(0,CDWIDTH),
    (others=>'0')
  );

  type hex2segtbl_type is array (0 to 15) of slv7;

  constant hex2segtbl : hex2segtbl_type :=
     ("0111111",                        -- 0: "0000"
      "0000110",                        -- 1: "0001"
      "1011011",                        -- 2: "0010"
      "1001111",                        -- 3: "0011"
      "1100110",                        -- 4: "0100"
      "1101101",                        -- 5: "0101"
      "1111101",                        -- 6: "0110"
      "0000111",                        -- 7: "0111"
      "1111111",                        -- 8: "1000"
      "1101111",                        -- 9: "1001"
      "1110111",                        -- a: "1010"
      "1111100",                        -- b: "1011"
      "0111001",                        -- c: "1100"
      "1011110",                        -- d: "1101"
      "1111001",                        -- e: "1110"
      "1110001"                         -- f: "1111"
      );

  signal R_REGS : regs_type := regs_init;  -- state registers
  signal N_REGS : regs_type := regs_init;  -- next value state regs

begin

  assert CDWIDTH >= 5
  report "assert(CDWIDTH >= 5): CDWIDTH too small"
  severity FAILURE;

  proc_regs: process (CLK)
  begin

    if CLK'event and CLK='1' then
      R_REGS <= N_REGS;
    end if;

  end process proc_regs;


  proc_next: process (R_REGS, DIN, DP)

    variable r : regs_type := regs_init;
    variable n : regs_type := regs_init;
    variable cano : slv4 := "0000";
    variable chex : slv4 := "0000";
    variable cdp  : slbit := '0';
    
  begin

    r := R_REGS;
    n := R_REGS;

    n.cdiv := unsigned(r.cdiv) - 1;
    if unsigned(r.cdiv) = 0 then
      n.dcnt := unsigned(r.dcnt) + 1;
    end if;

    chex := "0000";
    cdp  := '0';
    
    case r.dcnt is
      when "00" => chex := DIN( 3 downto  0);  cdp := DP(0);
      when "01" => chex := DIN( 7 downto  4);  cdp := DP(1);
      when "10" => chex := DIN(11 downto  8);  cdp := DP(2);
      when "11" => chex := DIN(15 downto 12);  cdp := DP(3);
      when others => chex := "----";           cdp := '-';
    end case;

    -- the logic below ensures that the anode PNP driver transistor is switched
    -- off in the last quarter of the digit cycle.This  prevents 'cross talk'
    -- between digits due to transistor turn off delays.
    -- For a nexys2 board at 50 MHz observed:
    --   no or 4 cycles gap well visible cross talk
    --   with 8 cycles still some weak cross talk
    --   with 16 cycles none is visible.
    --   --> The turn-off delay of the anode driver PNP's this therefore
    --       larger 160 ns and below 320 ns.
    -- As consquence CDWIDTH should be at least 6 for 50 MHz and 7 for 100 MHz.

    cano := "1111";
    if r.cdiv(CDWIDTH-1 downto CDWIDTH-2) /= "00" then
      cano(conv_integer(unsigned(r.dcnt))) := '0';
    end if;
    
    N_REGS <= n;

    ANO_N <= cano;
    SEG_N <= not (cdp & hex2segtbl(conv_integer(unsigned(chex))));

  end process proc_next;
  
end syn;
