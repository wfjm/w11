-- $Id: arty_dummy.vhd 1181 2019-07-08 17:00:50Z mueller $
-- SPDX-License-Identifier: GPL-3.0-or-later
-- Copyright 2016- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
-- 
------------------------------------------------------------------------------
-- Module Name:    arty_dummy - syn
-- Description:    arty minimal target (base; serport loopback)
--
-- Dependencies:   -
-- To test:        tb_arty
-- Target Devices: generic
-- Tool versions:  viv 2015.4; ghdl 0.33
--
-- Revision History: 
-- Date         Rev Version  Comment
-- 2016-03-06   740   1.1    add A_VPWRN/P to baseline config
-- 2016-01-31   726   1.0    Initial version (cloned from basys3)
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

use work.slvtypes.all;

entity arty_dummy is                    -- ARTY dummy (base; loopback)
                                        -- implements arty_aif
  port (
    I_CLK100 : in slbit;                -- 100 MHz board clock
    I_RXD : in slbit;                   -- receive data (board view)
    O_TXD : out slbit;                  -- transmit data (board view)
    I_SWI : in slv4;                    -- arty switches
    I_BTN : in slv4;                    -- arty buttons
    O_LED : out slv4;                   -- arty leds
    O_RGBLED0 : out slv3;               -- arty rgb-led 0
    O_RGBLED1 : out slv3;               -- arty rgb-led 1
    O_RGBLED2 : out slv3;               -- arty rgb-led 2
    O_RGBLED3 : out slv3;               -- arty rgb-led 3
    A_VPWRN : in slv4;                  -- arty pwrmon (neg)
    A_VPWRP : in slv4                   -- arty pwrmon (pos)
  );
end arty_dummy;

architecture syn of arty_dummy is
  
begin

  O_TXD    <= I_RXD;                    -- loop back serport

  O_LED    <= I_SWI;                    -- mirror SWI on LED

  O_RGBLED0 <= I_BTN(2 downto 0);       -- mirror BTN on RGBLED0
  O_RGBLED1 <= (others=>'0');
  O_RGBLED2 <= (others=>'0');
  O_RGBLED3 <= (others=>'0');

end syn;
