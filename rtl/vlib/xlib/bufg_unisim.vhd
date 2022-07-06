-- $Id: bufg_unisim.vhd 1247 2022-07-06 07:04:33Z mueller $
-- SPDX-License-Identifier: GPL-3.0-or-later
-- Copyright 2022- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
--
------------------------------------------------------------------------------
-- Module Name:    bufg_unisim - syn
-- Description:    Wrapper for BUFG entity
--
-- Dependencies:   -
-- Test bench:     -
-- Target Devices: generic Series-7
-- Tool versions:  viv 2022.1; ghdl 2.0.0
--
-- Revision History: 
-- Date         Rev Version  Comment
-- 2022-07-05  1247   1.0    Initial version 
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

library unisim;
use unisim.vcomponents.ALL;

entity bufg_unisim is                   -- wrapper for BUFG
  port (
    O : out std_ulogic;                 -- input
    I : in std_ulogic                   -- output
  );
end bufg_unisim;


architecture syn of bufg_unisim is
begin    

  BUF : BUFG
    port map (
      O  => O,
      I  => I
    );

end syn;
