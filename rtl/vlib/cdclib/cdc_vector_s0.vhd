-- $Id: cdc_vector_s0.vhd 1181 2019-07-08 17:00:50Z mueller $
-- SPDX-License-Identifier: GPL-3.0-or-later
-- Copyright 2016-2019 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
-- 
------------------------------------------------------------------------------
-- Module Name:    cdc_vector_s0 - syn
-- Description:    clock domain crossing for a vector, 1 stage
--
-- Dependencies:   -
-- Test bench:     -
-- Target Devices: generic
-- Tool versions:  viv 2015.4-2017.2; ghdl 0.33-0.34
-- Revision History: 
-- Date         Rev Version    Comment
-- 2019-01-02  1101   1.1      add ENA port
-- 2016-04-08   459   1.0      Initial version
-- 
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

use work.slvtypes.all;

entity cdc_vector_s0 is                  -- cdc for vector (1 stage)
  generic (
    DWIDTH : positive := 16);            -- data port width
  port (
    CLKO : in slbit;                     -- O|output clock
    ENA  : in slbit := '1';              -- O|capture enable
    DI   : in slv(DWIDTH-1 downto 0);    -- I|input data
    DO   : out slv(DWIDTH-1 downto 0)    -- O|output data
  );
end entity cdc_vector_s0;


architecture syn of cdc_vector_s0 is

  subtype d_range   is integer range DWIDTH-1 downto  0;

  signal R_DO_S0 : slv(d_range) := (others=>'0');

  attribute ASYNC_REG: string;

  attribute ASYNC_REG of R_DO_S0   : signal is "true";

begin

  proc_regs: process (CLKO)
  begin
    if rising_edge(CLKO) then
      if ENA = '1' then
        R_DO_S0 <= DI;              -- synch 0: CLKI->CLKO
      end if;
    end if;
  end process proc_regs;

  DO <= R_DO_S0;
  
end syn;

