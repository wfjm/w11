-- $Id: basys3lib.vhd 1181 2019-07-08 17:00:50Z mueller $
-- SPDX-License-Identifier: GPL-3.0-or-later
-- Copyright 2015- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
--
------------------------------------------------------------------------------
-- Package Name:   basys3lib
-- Description:    Basys 3 components
-- 
-- Dependencies:   -
-- Tool versions:  xst 14.7; viv 2014.4; ghdl 0.31
--
-- Revision History: 
-- Date         Rev Version  Comment
-- 2015-01-15   634   1.0    Initial version 
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

use work.slvtypes.all;

package basys3lib is

component basys3_aif is                 -- BASYS 3, abstract iface, base
  port (
    I_CLK100 : in slbit;                -- 100 MHz clock
    I_RXD : in slbit;                   -- receive data (board view)
    O_TXD : out slbit;                  -- transmit data (board view)
    I_SWI : in slv16;                   -- b3 switches
    I_BTN : in slv5;                    -- b3 buttons
    O_LED : out slv16;                  -- b3 leds
    O_ANO_N : out slv4;                 -- 7 segment disp: anodes   (act.low)
    O_SEG_N : out slv8                  -- 7 segment disp: segments (act.low)
  );
end component;

end package basys3lib;
