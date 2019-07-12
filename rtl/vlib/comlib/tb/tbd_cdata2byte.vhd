-- $Id: tbd_cdata2byte.vhd 1181 2019-07-08 17:00:50Z mueller $
-- SPDX-License-Identifier: GPL-3.0-or-later
-- Copyright 2014- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
--
------------------------------------------------------------------------------
-- Module Name:    tbd_cdata2byte - syn
-- Description:    Wrapper for cdata2byte + byte2cdata.
--
-- Dependencies:   cdata2byte
--                 byte2cdata
--
-- To test:        cdata2byte
--                 byte2cdata
--
-- Target Devices: generic
--
-- Synthesized (xst):
-- Date         Rev  ise         Target      flop lutl lutm slic t peri
-- 2014-10-18   597  14.7        xc6slx16      25   67    0   28 s 3.56
--
-- Tool versions:  xst 14.7; ghdl 0.31
-- Revision History: 
-- Date         Rev Version  Comment
-- 2014-10-18   597   1.0    Initial version 
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.slvtypes.all;
use work.comlib.all;

entity tbd_cdata2byte is                -- cdata2byte + byte2cdata [tb design]
  port (
    CLK : in slbit;                     -- clock
    RESET : in slbit;                   -- reset
    C2B_ESCXON : in slbit;              -- c2b: enable xon/xoff escaping
    C2B_ESCFILL : in slbit;             -- c2b: enable fill escaping
    C2B_DI : in slv9;                   -- c2b: input data; bit 8 = comma flag
    C2B_ENA : in slbit;                 -- c2b: input data enable
    C2B_BUSY : out slbit;               -- c2b: input data busy    
    C2B_DO : out slv8;                  -- c2b: output data
    C2B_VAL : out slbit;                -- c2b: output data valid
    B2C_BUSY : out slbit;               -- b2c: input data busy
    B2C_DO : out slv9;                  -- b2c: output data; bit 8 = comma flag
    B2C_VAL : out slbit;                -- b2c: output data valid
    B2C_HOLD : in slbit                 -- b2c: output data hold
  );
end tbd_cdata2byte;


architecture syn of tbd_cdata2byte is

  signal C2B_DO_L   : slv8 := (others=>'0');
  signal C2B_VAL_L  : slbit := '0';
  signal B2C_BUSY_L : slbit := '0';

begin

  C2B : cdata2byte
    port map (
      CLK     => CLK,
      RESET   => RESET,
      ESCXON  => C2B_ESCXON,
      ESCFILL => C2B_ESCFILL,
      DI      => C2B_DI,
      ENA     => C2B_ENA,
      BUSY    => C2B_BUSY,
      DO      => C2B_DO_L,
      VAL     => C2B_VAL_L,
      HOLD    => B2C_BUSY_L
    );

  B2C : byte2cdata
    port map (
      CLK     => CLK,
      RESET   => RESET,
      DI      => C2B_DO_L,
      ENA     => C2B_VAL_L,
      ERR     => '0',
      BUSY    => B2C_BUSY_L,
      DO      => B2C_DO,
      VAL     => B2C_VAL,
      HOLD    => B2C_HOLD
    );

  C2B_DO   <= C2B_DO_L;
  C2B_VAL  <= C2B_VAL_L;
  B2C_BUSY <= B2C_BUSY_L;
  
end syn;
