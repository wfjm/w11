-- $Id: s3_humanio.vhd 314 2010-07-09 17:38:41Z mueller $
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
-- Module Name:    s3_humanio - syn
-- Description:    All BTN, SWI, LED and DSP handling for s3board
--
-- Dependencies:   xlib/iob_reg_i_gen
--                 xlib/iob_reg_o_gen
--                 genlib/debounce_gen
--                 s3board/s3_dispdrv
--
-- Test bench:     -
--
-- Target Devices: generic
-- Tool versions:  xst 11.4; ghdl 0.26
--
-- Synthesized (xst):
-- Date         Rev  ise         Target      flop lutl lutm slic t peri
-- 2010-04-10   275 11.4    L68  xc3s1000-4    80   87    0   53 s  5.2 ns 
--
-- Revision History: 
-- Date         Rev Version  Comment
-- 2010-04-17   278   1.1.1  rename dispdrv -> s3_dispdrv
-- 2010-04-11   276   1.1    instantiate BTN/SWI debouncers via DEBOUNCE generic
-- 2010-04-10   275   1.0    Initial version
------------------------------------------------------------------------------
--    

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

use work.slvtypes.all;
use work.xlib.all;
use work.genlib.all;
use work.s3boardlib.all;

-- ----------------------------------------------------------------------------

entity s3_humanio is                    -- human i/o handling: swi,btn,led,dsp
  generic (
    DEBOUNCE : boolean := true);        -- instantiate debouncer for SWI,BTN
  port (
    CLK : in slbit;                     -- clock
    RESET : in slbit;                   -- reset
    CE_MSEC : in slbit;                 -- 1 ms clock enable
    SWI : out slv8;                     -- switch settings, debounced
    BTN : out slv4;                     -- button settings, debounced
    LED : in slv8;                      -- led data
    DSP_DAT : in slv16;                 -- display data
    DSP_DP : in slv4;                   -- display decimal points
    I_SWI : in slv8;                    -- pad-i: switches
    I_BTN : in slv4;                    -- pad-i: buttons
    O_LED : out slv8;                   -- pad-o: leds
    O_ANO_N : out slv4;                 -- pad-o: 7 seg disp: anodes   (act.low)
    O_SEG_N : out slv8                  -- pad-o: 7 seg disp: segments (act.low)
  );
end s3_humanio;

architecture syn of s3_humanio is
  
  signal RI_SWI :  slv8 := (others=>'0');
  signal RI_BTN :  slv4 := (others=>'0');

  signal N_ANO_N :  slv4 := (others=>'0');
  signal N_SEG_N :  slv8 := (others=>'0');
  
begin

  IOB_SWI : iob_reg_i_gen
    generic map (DWIDTH => 8)
    port map (CLK => CLK, CE => '1', DI => RI_SWI, PAD => I_SWI);
  
  IOB_BTN : iob_reg_i_gen
    generic map (DWIDTH => 4)
    port map (CLK => CLK, CE => '1', DI => RI_BTN, PAD => I_BTN);
  
  IOB_LED : iob_reg_o_gen
    generic map (DWIDTH => 8)
    port map (CLK => CLK, CE => '1', DO => LED,    PAD => O_LED);
  
  IOB_ANO_N : iob_reg_o_gen
    generic map (DWIDTH => 4)
    port map (CLK => CLK, CE => '1', DO => N_ANO_N, PAD => O_ANO_N);
  
  IOB_SEG_N : iob_reg_o_gen
    generic map (DWIDTH => 8)
    port map (CLK => CLK, CE => '1', DO => N_SEG_N, PAD => O_SEG_N);

  DEB: if DEBOUNCE generate

    DEB_SWI : debounce_gen
      generic map (
        CWIDTH => 2,
        CEDIV  => 3,
        DWIDTH => 8)
      port map (
        CLK    => CLK,
        RESET  => RESET,
        CE_INT => CE_MSEC,
        DI     => RI_SWI,
        DO     => SWI
      );

    DEB_BTN : debounce_gen
      generic map (
        CWIDTH => 2,
        CEDIV  => 3,
        DWIDTH => 4)
      port map (
        CLK    => CLK,
        RESET  => RESET,
        CE_INT => CE_MSEC,
        DI     => RI_BTN,
        DO     => BTN
      );
    
  end generate DEB;

  NODEB: if not DEBOUNCE generate
    SWI <= RI_SWI;
    BTN <= RI_BTN;
  end generate NODEB;
  
  DRV : s3_dispdrv
    generic map (
      CDWIDTH => 6)
    port map (
      CLK   => CLK,
      DIN   => DSP_DAT,
      DP    => DSP_DP,
      ANO_N => N_ANO_N,
      SEG_N => N_SEG_N
    );
  
end syn;
