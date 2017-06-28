-- $Id: cmoda7_dummy.vhd 906 2017-06-04 21:59:13Z mueller $
--
-- Copyright 2017- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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
-- Module Name:    cmoda7_dummy - syn
-- Description:    cmoda7 minimal target (base; serport loopback)
--
-- Dependencies:   -
-- To test:        tb_cmoda7
-- Target Devices: generic
-- Tool versions:  viv 2016.4; ghdl 0.34
--
-- Revision History: 
-- Date         Rev Version  Comment
-- 2017-06-04   906   1.0    Initial version
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

use work.slvtypes.all;

entity cmoda7_dummy is                  -- CmodA7 dummy (base; loopback)
                                        -- implements cmoda7_aif
  port (
    I_CLK12 : in slbit;                 -- 12 MHz board clock
    I_RXD : in slbit;                   -- receive data (board view)
    O_TXD : out slbit;                  -- transmit data (board view)
    I_BTN : in slv2;                    -- c7 buttons
    O_LED : out slv2;                   -- c7 leds
    O_RGBLED0_N : out slv3              -- c7 rgb-led 0        (act.low)
  );
end cmoda7_dummy;

architecture syn of cmoda7_dummy is
  
begin

  O_TXD    <= I_RXD;                    -- loop back serport

  O_LED    <= I_BTN;                    -- mirror BTN on LED

  O_RGBLED0_N(0) <= not I_BTN(0);       -- mirror BTN on RGBLED   0 -> red
  O_RGBLED0_N(1) <= not I_BTN(1);       --                        1 -> green
  O_RGBLED0_N(2) <= not (I_BTN(0) and I_BTN(1)); --             0+1 -> white
  
end syn;
