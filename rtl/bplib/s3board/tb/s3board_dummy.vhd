-- $Id: s3board_dummy.vhd 1181 2019-07-08 17:00:50Z mueller $
-- SPDX-License-Identifier: GPL-3.0-or-later
-- Copyright 2007-2010 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
-- 
------------------------------------------------------------------------------
-- Module Name:    s3board_dummy - syn
-- Description:    s3board minimal target (base; serport loopback)
--
-- Dependencies:   -
-- To test:        tb_s3board
-- Target Devices: generic
-- Tool versions:  xst 8.1, 8.2, 9.1, 9.2; ghdl 0.18-0.25
-- Revision History: 
-- Date         Rev Version  Comment
-- 2010-11-06   336   1.1.3  rename input pin CLK -> I_CLK50
-- 2010-04-17   278   1.1.2  rename sram_dummy -> s3_sram_dummy
-- 2007-12-16   101   1.1.1  use _N for active low
-- 2007-12-09   100   1.1    add sram memory signals, dummy handle them
-- 2007-09-23    85   1.0    Initial version 
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

use work.slvtypes.all;
use work.s3boardlib.all;

entity s3board_dummy is                 -- S3BOARD dummy (base; loopback)
                                        -- implements s3board_aif
  port (
    I_CLK50 : in slbit;                 -- 50 MHz board clock
    I_RXD : in slbit;                   -- receive data (board view)
    O_TXD : out slbit;                  -- transmit data (board view)
    I_SWI : in slv8;                    -- s3 switches
    I_BTN : in slv4;                    -- s3 buttons
    O_LED : out slv8;                   -- s3 leds
    O_ANO_N : out slv4;                 -- 7 segment disp: anodes   (act.low)
    O_SEG_N : out slv8;                 -- 7 segment disp: segments (act.low)
    O_MEM_CE_N : out slv2;              -- sram: chip enables  (act.low)
    O_MEM_BE_N : out slv4;              -- sram: byte enables  (act.low)
    O_MEM_WE_N : out slbit;             -- sram: write enable  (act.low)
    O_MEM_OE_N : out slbit;             -- sram: output enable (act.low)
    O_MEM_ADDR  : out slv18;            -- sram: address lines
    IO_MEM_DATA : inout slv32           -- sram: data lines
  );
end s3board_dummy;

architecture syn of s3board_dummy is
  
begin

  O_TXD <= I_RXD;

  SRAM : s3_sram_dummy                  -- connect SRAM to protection dummy
    port map (
      O_MEM_CE_N => O_MEM_CE_N,
      O_MEM_BE_N => O_MEM_BE_N,
      O_MEM_WE_N => O_MEM_WE_N,
      O_MEM_OE_N => O_MEM_OE_N,
      O_MEM_ADDR  => O_MEM_ADDR,
      IO_MEM_DATA => IO_MEM_DATA
    );
  
end syn;
