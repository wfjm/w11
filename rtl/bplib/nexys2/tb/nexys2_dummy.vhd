-- $Id: nexys2_dummy.vhd 1181 2019-07-08 17:00:50Z mueller $
-- SPDX-License-Identifier: GPL-3.0-or-later
-- Copyright 2010-2011 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
-- 
------------------------------------------------------------------------------
-- Module Name:    nexys2_dummy - syn
-- Description:    nexys2 minimal target (base; serport loopback)
--
-- Dependencies:   -
-- To test:        tb_nexys2
-- Target Devices: generic
-- Tool versions:  xst 11.4, 12.1, 13.1; ghdl 0.26-0.29
--
-- Revision History: 
-- Date         Rev Version  Comment
-- 2011-12-23   444   1.3    remove clksys output hack
-- 2011-11-26   433   1.2    use nxcramlib
-- 2011-11-23   432   1.1    remove O_FLA_CE_N port from n2_cram_dummy
-- 2010-11-13   338   1.0.2  add O_CLKSYS (for DCM derived system clock)
-- 2010-11-06   336   1.0.1  rename input pin CLK -> I_CLK50
-- 2010-05-23   294   1.0    Initial version (derived from s3board_dummy)
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

use work.slvtypes.all;
use work.nxcramlib.all;

entity nexys2_dummy is                  -- NEXYS 2 dummy (base; loopback)
                                        -- implements nexys2_aif
  port (
    I_CLK50 : in slbit;                 -- 50 MHz board clock
    I_RXD : in slbit;                   -- receive data (board view)
    O_TXD : out slbit;                  -- transmit data (board view)
    I_SWI : in slv8;                    -- n2 switches
    I_BTN : in slv4;                    -- n2 buttons
    O_LED : out slv8;                   -- n2 leds
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
    O_FLA_CE_N : out slbit              -- flash ce..          (act.low)
  );
end nexys2_dummy;

architecture syn of nexys2_dummy is
  
begin

  O_TXD    <= I_RXD;                    -- loop back

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
  
  O_FLA_CE_N  <= '1';                   -- keep Flash memory disabled

end syn;
