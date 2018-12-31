-- $Id: cdc_signal_s1_as.vhd 984 2018-01-02 20:56:27Z mueller $
--
-- Copyright 2016- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
--
-- This program is free software; you may redistribute and/or modify it under
-- the terms of the GNU General Public License as published by the Free
-- Software Foundation, either version 3, or (at your option) any later version.
--
-- This program is distributed in the hope that it will be useful, but
-- WITHOUT ANY WARRANTY, without even the implied warranty of MERCHANTABILITY
-- or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
-- for complete details.
-- 
------------------------------------------------------------------------------
-- Module Name:    cdc_signal_s1_as - syn
-- Description:    clock domain crossing for a signal, 2 stage, asyn input
--
-- Dependencies:   -
-- Test bench:     -
-- Target Devices: generic
-- Tool versions:  viv 2016.2; ghdl 0.33
-- Revision History: 
-- Date         Rev Version    Comment
-- 2016-06-10   774   1.0      Initial version (copy of cdc_signal_s1)
-- 
------------------------------------------------------------------------------
-- Logic is identical to cdc_signal_s1 !
-- but no scoped xdc with max_delay for input associated
--
library ieee;
use ieee.std_logic_1164.all;

use work.slvtypes.all;

entity cdc_signal_s1_as is               -- cdc for signal (2 stage), asyn input
  generic (
    INIT : slbit := '0');               -- initial state
  port (
    CLKO : in slbit;                     -- O|output clock
    DI   : in slbit;                     -- I|input data
    DO   : out slbit                     -- O|output data
  );
end entity cdc_signal_s1_as;


architecture syn of cdc_signal_s1_as is

  signal R_DO_S0 : slbit := INIT;
  signal R_DO_S1 : slbit := INIT;

  attribute ASYNC_REG: string;

  attribute ASYNC_REG of R_DO_S0   : signal is "true";
  attribute ASYNC_REG of R_DO_S1   : signal is "true";

begin

  proc_regs: process (CLKO)
  begin
    if rising_edge(CLKO) then
      R_DO_S0 <= DI;                -- synch 0: CLKI->CLKO
      R_DO_S1 <= R_DO_S0;           -- synch 1: CLKO
    end if;
  end process proc_regs;

  DO <= R_DO_S1;

end syn;
