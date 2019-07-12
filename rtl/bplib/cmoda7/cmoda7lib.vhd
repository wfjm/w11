-- $Id: cmoda7lib.vhd 1181 2019-07-08 17:00:50Z mueller $
-- SPDX-License-Identifier: GPL-3.0-or-later
-- Copyright 2017- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
--
------------------------------------------------------------------------------
-- Package Name:   cmoda7lib
-- Description:    CmodA7 components
-- 
-- Dependencies:   -
-- Tool versions:  viv 2016.4-2017.1; ghdl 0.34
--
-- Revision History: 
-- Date         Rev Version  Comment
-- 2017-06-11   912   1.1    add c7_sram_memctl
-- 2017-06-04   906   1.0    Initial version 
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

use work.slvtypes.all;

package cmoda7lib is

component cmoda7_aif is                 -- CmodA7, abstract iface, base
  port (
    I_CLK12 : in slbit;                 -- 12 MHz clock
    I_RXD : in slbit;                   -- receive data (board view)
    O_TXD : out slbit;                  -- transmit data (board view)
    I_BTN : in slv2;                    -- c7 buttons
    O_LED : out slv2;                   -- c7 leds
    O_RGBLED0_N: out slv3               -- c7 rgb-led 0        (act.low)
  );
end component;

component cmoda7_sram_aif is            -- CmodA7, abstract iface, base+sram
  port (
    I_CLK12 : in slbit;                 -- 12 MHz clock
    I_RXD : in slbit;                   -- receive data (board view)
    O_TXD : out slbit;                  -- transmit data (board view)
    I_BTN : in slv2;                    -- c7 buttons
    O_LED : out slv2;                   -- c7 leds
    O_RGBLED0_N: out slv3;              -- c7 rgb-led 0        (act.low)
    O_MEM_CE_N : out slbit;             -- sram: chip enable   (act.low)
    O_MEM_WE_N : out slbit;             -- sram: write enable  (act.low)
    O_MEM_OE_N : out slbit;             -- sram: output enable (act.low)
    O_MEM_ADDR  : out slv19;            -- sram: address lines
    IO_MEM_DATA : inout slv8            -- sram: data lines
  );
end component;

component c7_sram_memctl is             -- SRAM controller
  port (
    CLK : in slbit;                     -- clock
    RESET : in slbit;                   -- reset
    REQ   : in slbit;                   -- request
    WE    : in slbit;                   -- write enable
    BUSY : out slbit;                   -- controller busy
    ACK_R : out slbit;                  -- acknowledge read
    ACK_W : out slbit;                  -- acknowledge write
    ACT_R : out slbit;                  -- signal active read
    ACT_W : out slbit;                  -- signal active write
    ADDR : in slv17;                    -- address
    BE : in slv4;                       -- byte enable
    DI : in slv32;                      -- data in  (memory view)
    DO : out slv32;                     -- data out (memory view)
    O_MEM_CE_N : out slbit;             -- sram: chip enable   (act.low)
    O_MEM_WE_N : out slbit;             -- sram: write enable  (act.low)
    O_MEM_OE_N : out slbit;             -- sram: output enable (act.low)
    O_MEM_ADDR  : out slv19;            -- sram: address lines
    IO_MEM_DATA : inout slv8            -- sram: data lines
  );
end component;

end package cmoda7lib;
