-- $Id: sn_humanio.vhd 410 2011-09-18 11:23:09Z mueller $
--
-- Copyright 2010-2011 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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
-- Module Name:    sn_humanio - syn
-- Description:    All BTN, SWI, LED and DSP handling for s3board, nexys2/3
--
-- Dependencies:   xlib/iob_reg_o_gen
--                 bpgen/bp_swibtnled
--                 bpgen/sn_4x7segctl
--
-- Test bench:     -
--
-- Target Devices: generic
-- Tool versions:  xst 11.4, 12.1, 13.1; ghdl 0.26
--
-- Synthesized (xst):
-- Date         Rev  ise         Target      flop lutl lutm slic t peri
-- 2011-09-17   409 13.1    O40d xc3s1000-4    49   86    0   53 s  5.3 ns 
-- 2011-07-02   387 12.1    M53d xc3s1000-4    48   87    0   53 s  5.1 ns 
-- 2010-04-10   275 11.4    L68  xc3s1000-4    48   87    0   53 s  5.2 ns 
--
-- Revision History: 
-- Date         Rev Version  Comment
-- 2011-07-30   400   1.2.1  use CDWIDTH=7 for sn_4x7segctl (for 100 MHz)
-- 2011-07-08   390   1.2    renamed from s3_humanio, add BWIDTH generic
-- 2011-07-02   387   1.1.2  use bp_swibtnled
-- 2010-04-17   278   1.1.1  rename dispdrv -> s3_dispdrv
-- 2010-04-11   276   1.1    instantiate BTN/SWI debouncers via DEBOUNCE generic
-- 2010-04-10   275   1.0    Initial version
------------------------------------------------------------------------------
--    

library ieee;
use ieee.std_logic_1164.all;

use work.slvtypes.all;
use work.xlib.all;
use work.bpgenlib.all;

-- ----------------------------------------------------------------------------

entity sn_humanio is                    -- human i/o handling: swi,btn,led,dsp
  generic (
    BWIDTH : positive := 4;             -- BTN port width
    DEBOUNCE : boolean := true);        -- instantiate debouncer for SWI,BTN
  port (
    CLK : in slbit;                     -- clock
    RESET : in slbit := '0';            -- reset
    CE_MSEC : in slbit;                 -- 1 ms clock enable
    SWI : out slv8;                     -- switch settings, debounced
    BTN : out slv(BWIDTH-1 downto 0);   -- button settings, debounced
    LED : in slv8;                      -- led data
    DSP_DAT : in slv16;                 -- display data
    DSP_DP : in slv4;                   -- display decimal points
    I_SWI : in slv8;                    -- pad-i: switches
    I_BTN : in slv(BWIDTH-1 downto 0);  -- pad-i: buttons
    O_LED : out slv8;                   -- pad-o: leds
    O_ANO_N : out slv4;                 -- pad-o: 7 seg disp: anodes   (act.low)
    O_SEG_N : out slv8                  -- pad-o: 7 seg disp: segments (act.low)
  );
end sn_humanio;

architecture syn of sn_humanio is
  
  signal N_ANO_N :  slv4 := (others=>'0');
  signal N_SEG_N :  slv8 := (others=>'0');
  
begin

  IOB_ANO_N : iob_reg_o_gen
    generic map (DWIDTH => 4)
    port map (CLK => CLK, CE => '1', DO => N_ANO_N, PAD => O_ANO_N);
  
  IOB_SEG_N : iob_reg_o_gen
    generic map (DWIDTH => 8)
    port map (CLK => CLK, CE => '1', DO => N_SEG_N, PAD => O_SEG_N);

 HIO : bp_swibtnled
    generic map (
      SWIDTH   => 8,
      BWIDTH   => BWIDTH,
      LWIDTH   => 8,
      DEBOUNCE => DEBOUNCE)
    port map (
      CLK     => CLK,
      RESET   => RESET,
      CE_MSEC => CE_MSEC,
      SWI     => SWI,                   
      BTN     => BTN,                   
      LED     => LED,                   
      I_SWI   => I_SWI,                 
      I_BTN   => I_BTN,
      O_LED   => O_LED
    );

  DRV : sn_4x7segctl
    generic map (
      CDWIDTH => 7)                     -- 7 good for 100 MHz on nexys2
    port map (
      CLK   => CLK,
      DIN   => DSP_DAT,
      DP    => DSP_DP,
      ANO_N => N_ANO_N,
      SEG_N => N_SEG_N
    );
  
end syn;
