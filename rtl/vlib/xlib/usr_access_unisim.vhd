-- $Id: usr_access_unisim.vhd 1181 2019-07-08 17:00:50Z mueller $
-- SPDX-License-Identifier: GPL-3.0-or-later
-- Copyright 2016- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
--
------------------------------------------------------------------------------
-- Module Name:    usr_access_unisim - syn
-- Description:    Wrapper for USR_ACCESS* entities
--
-- Dependencies:   -
-- Test bench:     -
-- Target Devices: generic Series-7
-- Tool versions:  viv 2015.4; ghdl 0.33
--
-- Revision History: 
-- Date         Rev Version  Comment
-- 2016-04-02   758   1.0    Initial version 
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

library unisim;
use unisim.vcomponents.ALL;

use work.slvtypes.all;

entity usr_access_unisim is             -- wrapper for USR_ACCESS family
  port (
    DATA : out slv32                    -- usr_access register value
  );
end usr_access_unisim;


architecture syn of usr_access_unisim is

  signal DATA_RAW : slv32 := (others=>'0');

begin    

  UA : USR_ACCESSE2
    port map (
      CFGCLK    => open,
      DATA      => DATA_RAW,
      DATAVALID => open
    );

  -- the USR_ACCESSE2 simulation model unfortunately returns always 'UUUU'
  -- no way to configure it for reasonable simulation behavior
  -- there this sanitiser
  proc_data: process (DATA_RAW)
    variable idata : slv32 := (others=>'0');
  begin
    idata := to_x01(DATA_RAW);
    if is_x(idata) then
      idata := (others=>'0');
    end if;
    DATA <= idata;
  end process proc_data;

end syn;
