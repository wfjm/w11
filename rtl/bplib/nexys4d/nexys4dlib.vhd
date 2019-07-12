-- $Id: nexys4dlib.vhd 1181 2019-07-08 17:00:50Z mueller $
-- SPDX-License-Identifier: GPL-3.0-or-later
-- Copyright 2017- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
--
------------------------------------------------------------------------------
-- Package Name:   nexys4dlib
-- Description:    Nexys 4DDR components
-- 
-- Dependencies:   -
-- Tool versions:  viv 2016.2-2017.2; ghdl 0.33-0.34
--
-- Revision History: 
-- Date         Rev Version  Comment
-- 2018-12-30  1099   1.1    add nexys4d_dram_aif
-- 2017-01-04   838   1.0    Initial version 
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

use work.slvtypes.all;

package nexys4dlib is

component nexys4d_aif is                -- NEXYS 4D, abstract iface, base
  port (
    I_CLK100 : in slbit;                -- 100 MHz clock
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
end component;

component nexys4d_dram_aif is           -- NEXYS 4D, abstract iface, base+dram
  port (
    I_CLK100 : in slbit;                -- 100 MHz clock
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
    O_SEG_N : out slv8;                 -- 7 segment disp: segments (act.low)
    DDR2_DQ      : inout slv16;         -- dram: data in/out
    DDR2_DQS_P   : inout slv2;          -- dram: data strobe (diff-p)
    DDR2_DQS_N   : inout slv2;          -- dram: data strobe (diff-n)
    DDR2_ADDR    : out   slv13;         -- dram: address
    DDR2_BA      : out   slv3;          -- dram: bank address
    DDR2_RAS_N   : out   slbit;         -- dram: row addr strobe    (act.low)
    DDR2_CAS_N   : out   slbit;         -- dram: column addr strobe (act.low)
    DDR2_WE_N    : out   slbit;         -- dram: write enable       (act.low)
    DDR2_CK_P    : out   slv1;          -- dram: clock (diff-p)
    DDR2_CK_N    : out   slv1;          -- dram: clock (diff-n)
    DDR2_CKE     : out   slv1;          -- dram: clock enable
    DDR2_CS_N    : out   slv1;          -- dram: chip select        (act.low)
    DDR2_DM      : out   slv2;          -- dram: data input mask
    DDR2_ODT     : out   slv1           -- dram: on-die termination
    
  );
end component;

end package nexys4dlib;
