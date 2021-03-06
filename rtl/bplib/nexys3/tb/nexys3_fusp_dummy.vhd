-- $Id: nexys3_fusp_dummy.vhd 1181 2019-07-08 17:00:50Z mueller $
-- SPDX-License-Identifier: GPL-3.0-or-later
-- Copyright 2011- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
-- 
------------------------------------------------------------------------------
-- Module Name:    nexys3_dummy - syn
-- Description:    nexys3 minimal target (base; serport loopback)
--
-- Dependencies:   -
-- To test:        tb_nexys3
-- Target Devices: generic
-- Tool versions:  xst 13.1; ghdl 0.29
--
-- Revision History: 
-- Date         Rev Version  Comment
-- 2011-11-26   433   1.1    use nxcramlib
-- 2011-11-25   432   1.0    Initial version (derived from nexys2_fusp_dummy)
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

use work.slvtypes.all;
use work.nxcramlib.all;

entity nexys3_fusp_dummy is             -- NEXYS 3 dummy (base+fusp; loopback)
                                        -- implements nexys3_fusp_aif
  port (
    I_CLK100 : in slbit;                -- 100 MHz board clock
    I_RXD : in slbit;                   -- receive data (board view)
    O_TXD : out slbit;                  -- transmit data (board view)
    I_SWI : in slv8;                    -- n3 switches
    I_BTN : in slv5;                    -- n3 buttons
    O_LED : out slv8;                   -- n3 leds
    O_ANO_N : out slv4;                 -- 7 segment disp: anodes   (act.low)
    O_SEG_N : out slv8;                 -- 7 segment disp: segments (act.low)
    O_MEM_CE_N : out slbit;             -- cram: chip enable   (act.low)
    O_MEM_BE_N : out slv2;              -- cram: byte enables  (act.low)
    O_MEM_WE_N : out slbit;             -- cram: write enable  (act.low)
    O_MEM_OE_N : out slbit;             -- cram: output enable (act.low)
    O_MEM_ADV_N  : out slbit;           -- cram: address valid (act.low)
    O_MEM_CLK : out slbit;              -- cram: clock
    O_MEM_CRE : out slbit;              -- cram: command register enable
    I_MEM_WAIT : in slbit;              -- cram: mem wait
    O_MEM_ADDR  : out slv23;            -- cram: address lines
    IO_MEM_DATA : inout slv16;          -- cram: data lines
    O_PPCM_CE_N : out slbit;            -- ppcm: ...
    O_PPCM_RST_N : out slbit;           -- ppcm: ...
    O_FUSP_RTS_N : out slbit;           -- fusp: rs232 rts_n
    I_FUSP_CTS_N : in slbit;            -- fusp: rs232 cts_n
    I_FUSP_RXD : in slbit;              -- fusp: rs232 rx
    O_FUSP_TXD : out slbit              -- fusp: rs232 tx
  );
end nexys3_fusp_dummy;

architecture syn of nexys3_fusp_dummy is
  
begin

  O_TXD    <= I_RXD;                    -- loop back
  O_FUSP_TXD   <= I_FUSP_RXD;
  O_FUSP_RTS_N <= I_FUSP_CTS_N;

  CRAM : nx_cram_dummy                  -- connect CRAM to protection dummy
    port map (
      O_MEM_CE_N  => O_MEM_CE_N,
      O_MEM_BE_N  => O_MEM_BE_N,
      O_MEM_WE_N  => O_MEM_WE_N,
      O_MEM_OE_N  => O_MEM_OE_N,
      O_MEM_ADV_N => O_MEM_ADV_N,
      O_MEM_CLK   => O_MEM_CLK,
      O_MEM_CRE   => O_MEM_CRE,
      I_MEM_WAIT  => I_MEM_WAIT,
      O_MEM_ADDR  => O_MEM_ADDR,
      IO_MEM_DATA => IO_MEM_DATA
    );
  
  O_PPCM_CE_N  <= '1';                  -- keep parallel PCM memory disabled
  O_PPCM_RST_N <= '1';                  --

end syn;
