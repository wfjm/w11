-- $Id: sys_conf_ba4_bram.vhd 1181 2019-07-08 17:00:50Z mueller $
-- SPDX-License-Identifier: GPL-3.0-or-later
-- Copyright 2018- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
--
------------------------------------------------------------------------------
-- Package Name:   sys_conf_ba4_msim
-- Description:    Definitions for tb_sramif2migui_core (bawidth=4;btyp=bram)
--
-- Dependencies:   -
-- Tool versions:  viv 2017.2; ghdl 0.34
-- Revision History: 
-- Date         Rev Version  Comment
-- 2018-11-16  1069   1.0    Initial version
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

package sys_conf is

  -- define constants --------------------------------------------------------
  constant c_btyp_msim : string := "MSIM";
  constant c_btyp_bram : string := "BRAM";
  
  -- configure ---------------------------------------------------------------
  constant sys_conf_mawidth : positive  := 28;
  constant sys_conf_bawidth : positive  :=  4;    -- 128 bit data path 
  constant sys_conf_sawidth : positive  := 19;    -- msim memory size 
  constant sys_conf_rawidth : positive  := 19;    -- bram memory size
  constant sys_conf_rdelay  : positive  :=  1;    -- bram read delay
  constant sys_conf_btyp    : string    := c_btyp_bram;
 
end package sys_conf;
