-- $Id: artys7lib.vhd 1181 2019-07-08 17:00:50Z mueller $
-- SPDX-License-Identifier: GPL-3.0-or-later
-- Copyright 2018-2019 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
--
------------------------------------------------------------------------------
-- Package Name:   artys7lib
-- Description:    Digilent Arty S7 components
-- 
-- Dependencies:   -
-- Tool versions:  viv 2017.2-2018.2; ghdl 0.34-0.35
--
-- Revision History: 
-- Date         Rev Version  Comment
-- 2019-01-12  1105   1.1    add artys7_dram_aif
-- 2018-08-05  1028   1.0    Initial version 
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

use work.slvtypes.all;

package artys7lib is

component artys7_aif is                 -- ARTY S7, abstract iface, base
  port (
    I_CLK100 : in slbit;                -- 100 MHz clock
    I_RXD : in slbit;                   -- receive data (board view)
    O_TXD : out slbit;                  -- transmit data (board view)
    I_SWI : in slv4;                    -- artys7 switches
    I_BTN : in slv4;                    -- artys7 buttons
    O_LED : out slv4;                   -- artys7 leds
    O_RGBLED0 : out slv3;               -- artys7 rgb-led 0
    O_RGBLED1 : out slv3                -- artys7 rgb-led 1
  );
end component;

component artys7_dram_aif is            -- ARTY S7, abstract iface, base+dram
  port (
    I_CLK100 : in slbit;                -- 100 MHz clock
    I_RXD : in slbit;                   -- receive data (board view)
    O_TXD : out slbit;                  -- transmit data (board view)
    I_SWI : in slv4;                    -- artys7 switches
    I_BTN : in slv4;                    -- artys7 buttons
    O_LED : out slv4;                   -- artys7 leds
    O_RGBLED0 : out slv3;               -- artys7 rgb-led 0
    O_RGBLED1 : out slv3;               -- artys7 rgb-led 1
    DDR3_DQ      : inout slv16;         -- dram: data in/out
    DDR3_DQS_P   : inout slv2;          -- dram: data strobe (diff-p)
    DDR3_DQS_N   : inout slv2;          -- dram: data strobe (diff-n)
    DDR3_ADDR    : out   slv14;         -- dram: address
    DDR3_BA      : out   slv3;          -- dram: bank address
    DDR3_RAS_N   : out   slbit;         -- dram: row addr strobe    (act.low)
    DDR3_CAS_N   : out   slbit;         -- dram: column addr strobe (act.low)
    DDR3_WE_N    : out   slbit;         -- dram: write enable       (act.low)
    DDR3_RESET_N : out   slbit;         -- dram: reset              (act.low)
    DDR3_CK_P    : out   slv1;          -- dram: clock (diff-p)
    DDR3_CK_N    : out   slv1;          -- dram: clock (diff-n)
    DDR3_CKE     : out   slv1;          -- dram: clock enable
    DDR3_CS_N    : out   slv1;          -- dram: chip select        (act.low)
    DDR3_DM      : out   slv2;          -- dram: data input mask
    DDR3_ODT     : out   slv1           -- dram: on-die termination
  );
end component;

end package artys7lib;
