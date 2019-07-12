-- $Id: iob_reg_o.vhd 1181 2019-07-08 17:00:50Z mueller $
-- SPDX-License-Identifier: GPL-3.0-or-later
-- Copyright 2007- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
--
------------------------------------------------------------------------------
-- Module Name:    iob_reg_i - syn
-- Description:    Registered IOB, output only
--
-- Dependencies:   -
-- Test bench:     -
-- Target Devices: generic Spartan, Virtex
-- Tool versions:  ise 8.1-14.7; viv 2014.4; ghdl 0.18-0.31
-- Revision History: 
-- Date         Rev Version  Comment
-- 2007-12-16   101   1.0.1  add INIT generic port
-- 2007-12-08   100   1.0    Initial version 
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

use work.slvtypes.all;
use work.xlib.all;

entity iob_reg_o is                     -- registered IOB, output
  generic (
    INIT : slbit := '0');               -- initial state
  port (
    CLK  : in slbit;                    -- clock
    CE   : in slbit := '1';             -- clock enable
    DO   : in slbit;                    -- output data
    PAD  : out slbit                    -- i/o pad
  );
end iob_reg_o;


architecture syn of iob_reg_o is

begin

  IOB : iob_reg_o_gen
    generic map (
      DWIDTH => 1,
      INIT   => INIT)
    port map (
      CLK    => CLK,
      CE     => CE,
      DO(0)  => DO,
      PAD(0) => PAD
    );
  
end syn;
