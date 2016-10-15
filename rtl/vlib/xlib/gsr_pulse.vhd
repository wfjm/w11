-- $Id: gsr_pulse.vhd 809 2016-09-18 19:49:14Z mueller $
--
-- Copyright 2016- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
--
-- This program is free software; you may redistribute and/or modify it under
-- the terms of the GNU General Public License as published by the Free
-- Software Foundation, either version 2, or at your option any later version.
--
-- This program is distributed in the hope that it will be useful, but
-- WITHOUT ANY WARRANTY, without even the implied warranty of MERCHANTABILITY
-- or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
-- for complete details.
--
------------------------------------------------------------------------------
-- Module Name:    gsr_pulse - sim
-- Description:    pulse GSR at startup
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

library unisim;
use unisim.vcomponents.ALL;

entity gsr_pulse is                     -- pulse GSR at startup
  generic (
    GSR_WIDTH : Delay_length:= 100 ns); -- GSR pulse length
end gsr_pulse;


architecture sim of gsr_pulse is

begin

  process
  begin

    -- Uses weak driver to prevent a driver clash when glbl.v is loaded too
    -- In case glbl.v is present it will overwrite (to be tested...)
    UNISIM.VCOMPONENTS.GSR <= 'H';
    wait for GSR_WIDTH;
    UNISIM.VCOMPONENTS.GSR <= 'L';
    wait;
    
  end process;

end sim;
