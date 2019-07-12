-- $Id: artylib.vhd 1181 2019-07-08 17:00:50Z mueller $
-- SPDX-License-Identifier: GPL-3.0-or-later
-- Copyright 2016-2018 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
--
------------------------------------------------------------------------------
-- Package Name:   artylib
-- Description:    Digilent Arty components
-- 
-- Dependencies:   -
-- Tool versions:  viv 2015.4; ghdl 0.33
--
-- Revision History: 
-- Date         Rev Version  Comment
-- 2018-10-29  1063   1.2    add arty_dram_aif
-- 2016-03-06   740   1.1    add A_VPWRN/P to baseline config
-- 2016-01-31   726   1.0    Initial version 
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

use work.slvtypes.all;

package artylib is

component arty_aif is                   -- ARTY, abstract iface, base
  port (
    I_CLK100 : in slbit;                -- 100 MHz clock
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
end component;

component arty_dram_aif is               -- ARTY, abstract iface, base+dram
  port (
    I_CLK100 : in slbit;                -- 100 MHz clock
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
    A_VPWRP : in slv4;                  -- arty pwrmon (pos)
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

end package artylib;
