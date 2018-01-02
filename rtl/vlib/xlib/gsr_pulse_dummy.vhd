-- $Id: gsr_pulse_dummy.vhd 984 2018-01-02 20:56:27Z mueller $
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
