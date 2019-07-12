-- $Id: nexys4d_dram_dummy.vhd 1181 2019-07-08 17:00:50Z mueller $
-- SPDX-License-Identifier: GPL-3.0-or-later
-- Copyright 2018- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
-- 
------------------------------------------------------------------------------
-- Module Name:    nexys4d_dram_dummy - syn
-- Description:    nexys4d target (base; serport loopback, dram project)
--
-- Dependencies:   -
-- To test:        tb_nexys4d_dram
-- Target Devices: generic
-- Tool versions:  viv 2017.2; ghdl 0.34
--
-- Revision History: 
-- Date         Rev Version  Comment
-- 2018-12-30  1099   1.0    Initial version (derived from nexys4_dummy)
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

use work.slvtypes.all;

entity nexys4d_dram_dummy is            -- NEXYS 4DDR dummy (base+dram)
                                        -- implements nexys4d_dram_aif
  port (
    I_CLK100 : in slbit;                -- 100 MHz board clock
    I_RXD : in slbit;                   -- receive data (board view)
    O_TXD : out slbit;                  -- transmit data (board view)
    O_RTS_N : out slbit;                -- rx rts (board view; act.low)
    I_CTS_N : in slbit;                 -- tx cts (board view; act.low)
    I_SWI : in slv16;                   -- n4d switches
    I_BTN : in slv5;                    -- n4d buttons
    I_BTNRST_N : in slbit;              -- n4d reset button
    O_LED : out slv16;                  -- n4d leds
    O_RGBLED0 : out slv3;               -- n4d rgb-led 0
    O_RGBLED1 : out slv3;               -- n4d rgb-led 1
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
end nexys4d_dram_dummy;

architecture syn of nexys4d_dram_dummy is
  
begin

  O_TXD    <= I_RXD;                    -- loop back serport
  O_RTS_N  <= I_CTS_N;

  O_LED    <= I_SWI;                    -- mirror SWI on LED

  O_RGBLED0 <= I_BTN(2 downto 0);       -- mirror BTN on RGBLED
  O_RGBLED1 <= not I_BTNRST_N & I_BTN(4) & I_BTN(3);

  O_ANO_N <= (others=>'1');
  O_SEG_N <= (others=>'1');
  
  DDR2_DQ      <= (others=>'Z');
  DDR2_DQS_P   <= (others=>'Z');
  DDR2_DQS_N   <= (others=>'Z');
  DDR2_ADDR    <= (others=>'0');
  DDR2_BA      <= (others=>'0');
  DDR2_RAS_N   <= '1';
  DDR2_CAS_N   <= '1';
  DDR2_WE_N    <= '1';
  DDR2_CK_P    <= (others=>'0');
  DDR2_CK_N    <= (others=>'1');
  DDR2_CKE     <= (others=>'0');
  DDR2_CS_N    <= (others=>'1');
  DDR2_DM      <= (others=>'0');
  DDR2_ODT     <= (others=>'0');
  
end syn;
