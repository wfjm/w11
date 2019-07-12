-- $Id: cdc_value.vhd 1181 2019-07-08 17:00:50Z mueller $
-- SPDX-License-Identifier: GPL-3.0-or-later
-- Copyright 2016-2019 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
-- 
------------------------------------------------------------------------------
-- Module Name:    cdc_value - syn
-- Description:    clock domain crossing for a slowly changing value
--
-- Dependencies:   cdc_pulse
--                 cdc_vector_s0
-- Test bench:     -
-- Target Devices: generic
-- Tool versions:  viv 2017.2; ghdl 0.34
-- Revision History: 
-- Date         Rev Version    Comment
-- 2019-01-02  1101   2.0      reinplement using cdc_pulse and cdc_vector_s0
-- 2016-04-08   459   1.0      Initial version
-- 
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

use work.slvtypes.all;
use work.cdclib.all;

entity cdc_value is                      -- cdc for value (slow change)
  generic (
    DWIDTH : positive := 16);            -- data port width
  port (
    CLKI : in slbit;                     -- I|input clock
    CLKO : in slbit;                     -- O|output clock
    DI   : in slv(DWIDTH-1 downto 0);    -- I|input data
    DO   : out slv(DWIDTH-1 downto 0);   -- O|output data
    UPDT : out slbit                     -- O|output data updated
  );
end entity cdc_value;


architecture syn of cdc_value is

  subtype d_range   is integer range DWIDTH-1 downto  0;

  signal R_DI   : slv(d_range) := (others=>'0');
  signal R_UPDT : slbit := '0';
  
  signal PULSE_PIN  : slbit := '0';
  signal PULSE_BUSY : slbit := '0';
  signal PULSE_POUT : slbit := '0';

begin

  CDC_ENA: cdc_pulse
    generic map (
      POUT_SINGLE => true,
      BUSY_WACK   => true)
    port map (
      CLKM  => CLKI,
      RESET => '0',
      CLKS  => CLKO,
      PIN   => PULSE_PIN,
      BUSY  => PULSE_BUSY,
      POUT  => PULSE_POUT
      );
  
  CDC_DOUT : cdc_vector_s0
    generic map (
      DWIDTH => DWIDTH)
    port map (
      CLKO  => CLKO,
      ENA   => PULSE_POUT,
      DI    => R_DI,
      DO    => DO
    );

  PULSE_PIN <= not PULSE_BUSY;
  
  proc_clki: process (CLKI)
  begin
    if rising_edge(CLKI) then
      if PULSE_PIN = '1' then
        R_DI <= DI;
      end if;
    end if;
  end process proc_clki;

  proc_clko: process (CLKO)
  begin
    if rising_edge(CLKO) then
      R_UPDT <= PULSE_POUT;
    end if;
  end process proc_clko;

  UPDT <= R_UPDT;
  
end syn;
