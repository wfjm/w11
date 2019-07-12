-- $Id: nexys4d_dummy.vhd 1181 2019-07-08 17:00:50Z mueller $
-- SPDX-License-Identifier: GPL-3.0-or-later
-- Copyright 2017- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
-- 
------------------------------------------------------------------------------
-- Module Name:    nexys4d_dummy - syn
-- Description:    nexys4d minimal target (base; serport loopback)
--
-- Dependencies:   -
-- To test:        tb_nexys4d
-- Target Devices: generic
-- Tool versions:  viv 2016.4; ghdl 0.33
--
-- Revision History: 
-- Date         Rev Version  Comment
-- 2017-01-04   838   1.0    Initial version (derived from nexys4_dummy)
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

use work.slvtypes.all;

entity nexys4d_dummy is                 -- NEXYS 4DDR dummy (base; loopback)
                                        -- implements nexys4d_aif
  port (
    I_CLK100 : in slbit;                -- 100 MHz board clock
    I_RXD : in slbit;                   -- receive data (board view)
    O_TXD : out slbit;                  -- transmit data (board view)
    O_RTS_N : out slbit;                -- rx rts (board view; act.low)
    I_CTS_N : in slbit;                 -- tx cts (board view; act.low)
    I_SWI : in slv16;                   -- n4d switches
    I_BTN : in slv5;                    -- n4d buttons
    I_BTNRST_N : in slbit;              -- n4d reset button
    O_LED : out slv16;                  -- n4d leds
    O_RGBLED0 : out slv3;               -- n4d rgb-led 0
    O_RGBLED1 : out slv3;               -- n4d rgb-led 1
    O_ANO_N : out slv8;                 -- 7 segment disp: anodes   (act.low)
    O_SEG_N : out slv8                  -- 7 segment disp: segments (act.low)
  );
end nexys4d_dummy;

architecture syn of nexys4d_dummy is
  
begin

  O_TXD    <= I_RXD;                    -- loop back serport
  O_RTS_N  <= I_CTS_N;

  O_LED    <= I_SWI;                    -- mirror SWI on LED

  O_RGBLED0 <= I_BTN(2 downto 0);       -- mirror BTN on RGBLED
  O_RGBLED1 <= not I_BTNRST_N & I_BTN(4) & I_BTN(3);

  O_ANO_N <= (others=>'1');
  O_SEG_N <= (others=>'1');
  
end syn;
