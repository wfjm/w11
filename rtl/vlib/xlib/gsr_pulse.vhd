-- $Id: gsr_pulse.vhd 1181 2019-07-08 17:00:50Z mueller $
-- SPDX-License-Identifier: GPL-3.0-or-later
-- Copyright 2016- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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
