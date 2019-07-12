-- $Id: gsr_pulse_dummy.vhd 1181 2019-07-08 17:00:50Z mueller $
-- SPDX-License-Identifier: GPL-3.0-or-later
-- Copyright 2016- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
--
------------------------------------------------------------------------------
-- Module Name:    gsr_pulse - sim
-- Description:    pulse GSR at startup (no action dummy for behavioral sims)
--
-- Dependencies:   -
-- Test bench:     -
-- Target Devices: generic
-- Tool versions:  viv 2016.2; ghdl 0.33
-- Revision History: 
-- 2016-09-17   808   1.0    Initial version 
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity gsr_pulse is                     -- pulse GSR at startup
  generic (
    GSR_WIDTH : Delay_length:= 100 ns); -- GSR pulse length
end gsr_pulse;


architecture sim of gsr_pulse is

begin

  -- dummy, for behavioral simulations without VCOMPONENTS

end sim;
