-- $Id: cdc_pulse.vhd 1181 2019-07-08 17:00:50Z mueller $
-- SPDX-License-Identifier: GPL-3.0-or-later
-- Copyright 2011-2016 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
-- 
------------------------------------------------------------------------------
-- Module Name:    cdc_pulse - syn
-- Description:    clock domain crossing for a pulse
--
-- Dependencies:   -
-- Test bench:     -
-- Target Devices: generic
-- Tool versions:  xst 13.1-14.7; viv 2015.4-2016.2; ghdl 0.29-0.33
-- Revision History: 
-- Date         Rev Version    Comment
-- 2016-06-11   774   1.2      add INIT generic
-- 2016-03-29   756   1.1      rename regs; add ASYNC_REG attributes
-- 2011-11-09   422   1.0      Initial version
-- 
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

use work.slvtypes.all;

entity cdc_pulse is                     -- clock domain cross for pulse
  generic (
    POUT_SINGLE : boolean := false;     -- if true: single cycle pout
    BUSY_WACK : boolean := false;       -- if true: busy waits for ack
    INIT : slbit := '0');               -- initial state
  port (
    CLKM : in slbit;                    -- M|clock master
    RESET : in slbit := '0';            -- M|reset
    CLKS : in slbit;                    -- S|clock slave
    PIN : in slbit;                     -- M|pulse in
    BUSY : out slbit;                   -- M|busy
    POUT : out slbit                    -- S|pulse out
  );
end entity cdc_pulse;


architecture syn of cdc_pulse is

  signal RM_REQ    : slbit := INIT;     -- request active
  signal RS_REQ_S0 : slbit := INIT;     -- request: CLKM->CLKS
  signal RS_REQ_S1 : slbit := INIT;     -- request: CLKS->CLKS
  signal RM_ACK_S0 : slbit := '0';      -- acknowledge: CLKS->CLKM
  signal RM_ACK_S1 : slbit := '0';      -- acknowledge: CLKM->CLKM

  attribute ASYNC_REG: string;

  attribute ASYNC_REG of RS_REQ_S0   : signal is "true";
  attribute ASYNC_REG of RS_REQ_S1   : signal is "true";
  attribute ASYNC_REG of RM_ACK_S0   : signal is "true";
  attribute ASYNC_REG of RM_ACK_S1   : signal is "true";

begin

  proc_master: process (CLKM)
  begin
    if rising_edge(CLKM) then
      if RESET = '1' then
        RM_REQ <= '0';
      else
        if PIN = '1' then
          RM_REQ <= '1';
        elsif RM_ACK_S1 = '1' then
          RM_REQ <= '0';
        end if;
      end if;
      RM_ACK_S0 <= RS_REQ_S1;           -- synch 0: CLKS->CLKM
      RM_ACK_S1 <= RM_ACK_S0;           -- synch 1: CLKM
    end if;
  end process proc_master;

  proc_slave: process (CLKS)
  begin
    if rising_edge(CLKS) then
      RS_REQ_S0 <= RM_REQ;              -- synch 0: CLKM->CLKS
      RS_REQ_S1 <= RS_REQ_S0;           -- synch 1: CLKS
    end if;
  end process proc_slave;

  -- Note: no pulse at startup when  POUT_SINGLE=true, INIT=1 and PIN=1 initially
  SINGLE1: if POUT_SINGLE = true generate
    signal RS_ACK_1 : slbit := INIT;
    signal RS_POUT  : slbit := '0';
  begin
    proc_pout: process (CLKS)
    begin
      if rising_edge(CLKS) then
        RS_ACK_1 <= RS_REQ_S1;
        if RS_REQ_S1='1' and RS_ACK_1='0' then
          RS_POUT <= '1';
        else
          RS_POUT <= '0';
        end if;
      end if;
    end process proc_pout;
    POUT <= RS_POUT;
  end generate SINGLE1;

  SINGLE0: if POUT_SINGLE = false generate
  begin
    POUT <= RS_REQ_S1;
  end generate SINGLE0;
  
  BUSY1: if BUSY_WACK = true generate
  begin
    BUSY <= RM_REQ or RM_ACK_S1;
  end generate BUSY1;

  BUSY0: if BUSY_WACK = false generate
  begin
    BUSY <= RM_REQ;
  end generate BUSY0;
  
end syn;

