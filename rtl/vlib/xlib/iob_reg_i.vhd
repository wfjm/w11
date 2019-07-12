-- $Id: iob_reg_i.vhd 1181 2019-07-08 17:00:50Z mueller $
-- SPDX-License-Identifier: GPL-3.0-or-later
-- Copyright 2007- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
--
------------------------------------------------------------------------------
-- Module Name:    iob_reg_i - syn
-- Description:    Registered IOB, input only
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

entity iob_reg_i is                     -- registered IOB, input
  generic (
    INIT : slbit := '0');               -- initial state
  port (
    CLK  : in slbit;                    -- clock
    CE   : in slbit := '1';             -- clock enable
    DI   : out slbit;                   -- input data
    PAD  : in slbit                     -- i/o pad
  );
end iob_reg_i;


architecture syn of iob_reg_i is

begin

  IOB : iob_reg_i_gen
    generic map (
      DWIDTH => 1,
      INIT   => INIT)
    port map (
      CLK    => CLK,
      CE     => CE,
      DI(0)  => DI,
      PAD(0) => PAD
    );

end syn;
