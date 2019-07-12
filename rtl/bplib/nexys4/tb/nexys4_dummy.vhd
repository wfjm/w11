-- $Id: nexys4_dummy.vhd 1181 2019-07-08 17:00:50Z mueller $
-- SPDX-License-Identifier: GPL-3.0-or-later
-- Copyright 2013-2015 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
-- 
------------------------------------------------------------------------------
-- Module Name:    nexys4_dummy - syn
-- Description:    nexys4 minimal target (base; serport loopback)
--
-- Dependencies:   -
-- To test:        tb_nexys4
-- Target Devices: generic
-- Tool versions:  ise 14.5-14.7; viv 2014.4; ghdl 0.29-0.31
--
-- Revision History: 
-- Date         Rev Version  Comment
-- 2015-02-06   643   1.3    factor out memory
-- 2015-02-01   641   1.1    separate I_BTNRST_N
-- 2013-09-21   534   1.0    Initial version (derived from nexys3_dummy)
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

use work.slvtypes.all;

entity nexys4_dummy is                  -- NEXYS 4 dummy (base; loopback)
                                        -- implements nexys4_aif
  port (
    I_CLK100 : in slbit;                -- 100 MHz board clock
    I_RXD : in slbit;                   -- receive data (board view)
    O_TXD : out slbit;                  -- transmit data (board view)
    O_RTS_N : out slbit;                -- rx rts (board view; act.low)
    I_CTS_N : in slbit;                 -- tx cts (board view; act.low)
    I_SWI : in slv16;                   -- n4 switches
    I_BTN : in slv5;                    -- n4 buttons
    I_BTNRST_N : in slbit;              -- n4 reset button
    O_LED : out slv16;                  -- n4 leds
    O_RGBLED0 : out slv3;               -- n4 rgb-led 0
    O_RGBLED1 : out slv3;               -- n4 rgb-led 1
    O_ANO_N : out slv8;                 -- 7 segment disp: anodes   (act.low)
    O_SEG_N : out slv8                  -- 7 segment disp: segments (act.low)
  );
end nexys4_dummy;

architecture syn of nexys4_dummy is
  
begin

  O_TXD    <= I_RXD;                    -- loop back serport
  O_RTS_N  <= I_CTS_N;

  O_LED    <= I_SWI;                    -- mirror SWI on LED

  O_RGBLED0 <= I_BTN(2 downto 0);       -- mirror BTN on RGBLED
  O_RGBLED1 <= not I_BTNRST_N & I_BTN(4) & I_BTN(3);

  O_ANO_N <= (others=>'1');
  O_SEG_N <= (others=>'1');
  
end syn;
