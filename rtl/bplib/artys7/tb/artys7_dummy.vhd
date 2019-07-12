-- $Id: artys7_dummy.vhd 1181 2019-07-08 17:00:50Z mueller $
-- SPDX-License-Identifier: GPL-3.0-or-later
-- Copyright 2018- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
-- 
------------------------------------------------------------------------------
-- Module Name:    artys7_dummy - syn
-- Description:    artys7 minimal target (base; serport loopback)
--
-- Dependencies:   -
-- To test:        tb_artys7
-- Target Devices: generic
-- Tool versions:  viv 2017.2-2018.2; ghdl 0.34
--
-- Revision History: 
-- Date         Rev Version  Comment
-- 2018-08-05  1038   1.0    Initial version (cloned from artya7)
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

use work.slvtypes.all;

entity artys7_dummy is                  -- ARTY S7 dummy (base; loopback)
                                        -- implements artys7_aif
  port (
    I_CLK100 : in slbit;                -- 100 MHz board clock
    I_RXD : in slbit;                   -- receive data (board view)
    O_TXD : out slbit;                  -- transmit data (board view)
    I_SWI : in slv4;                    -- artys7 switches
    I_BTN : in slv4;                    -- artys7 buttons
    O_LED : out slv4;                   -- artys7 leds
    O_RGBLED0 : out slv3;               -- artys7 rgb-led 0
    O_RGBLED1 : out slv3                -- artys7 rgb-led 1
  );
end artys7_dummy;

architecture syn of artys7_dummy is
  
begin

  O_TXD    <= I_RXD;                    -- loop back serport

  O_LED    <= I_SWI;                    -- mirror SWI on LED

  O_RGBLED0 <= I_BTN(2 downto 0);       -- mirror BTN on RGBLED0
  O_RGBLED1 <= (others=>'0');

end syn;
