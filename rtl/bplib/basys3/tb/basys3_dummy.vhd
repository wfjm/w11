-- $Id: basys3_dummy.vhd 1181 2019-07-08 17:00:50Z mueller $
-- SPDX-License-Identifier: GPL-3.0-or-later
-- Copyright 2015-2016 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
-- 
------------------------------------------------------------------------------
-- Module Name:    basys3_dummy - syn
-- Description:    basys3 minimal target (base; serport loopback)
--
-- Dependencies:   -
-- To test:        tb_basys3
-- Target Devices: generic
-- Tool versions:  xst 14.7; viv 2014.4; ghdl 0.31
--
-- Revision History: 
-- Date         Rev Version  Comment
-- 2016-01-31   726   1.0.1  fix typos
-- 2015-01-15   634   1.0    Initial version (derived from nexys4_dummy)
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

use work.slvtypes.all;

entity basys3_dummy is                  -- BASYS 3 dummy (base; loopback)
                                        -- implements basys3_aif
  port (
    I_CLK100 : in slbit;                -- 100 MHz board clock
    I_RXD : in slbit;                   -- receive data (board view)
    O_TXD : out slbit;                  -- transmit data (board view)
    I_SWI : in slv16;                   -- b3 switches
    I_BTN : in slv5;                    -- b3 buttons
    O_LED : out slv16;                  -- b3 leds
    O_ANO_N : out slv4;                 -- 7 segment disp: anodes   (act.low)
    O_SEG_N : out slv8                  -- 7 segment disp: segments (act.low)
  );
end basys3_dummy;

architecture syn of basys3_dummy is
  
begin

  O_TXD    <= I_RXD;                    -- loop back serport

  O_LED    <= I_SWI;                    -- mirror SWI on LED

  O_ANO_N <= (others=>'1');
  O_SEG_N <= (others=>'1');
  
end syn;
