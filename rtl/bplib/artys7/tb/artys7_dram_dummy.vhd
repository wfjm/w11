-- $Id: artys7_dram_dummy.vhd 1181 2019-07-08 17:00:50Z mueller $
-- SPDX-License-Identifier: GPL-3.0-or-later
-- Copyright 2019- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
-- 
------------------------------------------------------------------------------
-- Module Name:    artys7_dram_dummy - syn
-- Description:    artys7target (base; serport loopback, dram project)
--
-- Dependencies:   -
-- To test:        tb_artys7_dram
-- Target Devices: generic
-- Tool versions:  viv 2017.2; ghdl 0.35
--
-- Revision History: 
-- Date         Rev Version  Comment
-- 2019-01-12  1105   1.0    Initial version (cloned from artys7)
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

use work.slvtypes.all;

entity artys7_dram_dummy is             -- ARTY S7 dummy (base+dram)
                                        -- implements artys7_dram_aif
  port (
    I_CLK100 : in slbit;                -- 100 MHz board clock
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
end artys7_dram_dummy;

architecture syn of artys7_dram_dummy is
  
begin

  O_TXD    <= I_RXD;                    -- loop back serport

  O_LED    <= I_SWI;                    -- mirror SWI on LED

  O_RGBLED0 <= I_BTN(2 downto 0);       -- mirror BTN on RGBLED0
  O_RGBLED1 <= (others=>'0');

  DDR3_DQ      <= (others=>'Z');
  DDR3_DQS_P   <= (others=>'Z');
  DDR3_DQS_N   <= (others=>'Z');
  DDR3_ADDR    <= (others=>'0');
  DDR3_BA      <= (others=>'0');
  DDR3_RAS_N   <= '1';
  DDR3_CAS_N   <= '1';
  DDR3_WE_N    <= '1';
  DDR3_RESET_N <= '1';
  DDR3_CK_P    <= (others=>'0');
  DDR3_CK_N    <= (others=>'1');
  DDR3_CKE     <= (others=>'0');
  DDR3_CS_N    <= (others=>'1');
  DDR3_DM      <= (others=>'0');
  DDR3_ODT     <= (others=>'0');

end syn;
