-- $Id: pdp11_dspmux.vhd 1181 2019-07-08 17:00:50Z mueller $
-- SPDX-License-Identifier: GPL-3.0-or-later
-- Copyright 2015-2018 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
--
------------------------------------------------------------------------------
-- Module Name:    pdp11_dspmux - syn
-- Description:    pdp11: hio dsp mux
--
-- Dependencies:   -
-- Test bench:     -
-- Target Devices: generic
-- Tool versions:  ise 14.7; viv 2018.2; ghdl 0.31-0.34
--
-- Revision History: 
-- Date         Rev Version  Comment
-- 2018-10-07  1054   1.1    use DM_STAT_EXP instead of DM_STAT_DP
-- 2015-02-22   650   1.0    Initial version 
-- 2015-02-21   649   0.1    First draft
------------------------------------------------------------------------------
-- selects display data
--   4 Digit Displays
--     SEL(1:0)  00  ABCLKDIV
--               01  DM_STAT_EXP.dp_pc
--               10  DISPREG 
--               11  DM_STAT_EXP.dp_dsrc
--
--  8 Digit Displays
--     SEL(1)   select DSP(7:4)
--                0  ABCLKDIV
--                1  DM_STAT_EXP.dp_pc
--     SEL(0)   select DSP(7:4)
--                0  DISPREG
--                1  DM_STAT_EXP.dp_dsrc
--                

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.slvtypes.all;
use work.pdp11.all;

-- ----------------------------------------------------------------------------

entity pdp11_dspmux is               -- hio dsp mux
  generic (
    DCWIDTH : positive := 2);           -- digit counter width (2 or 3)
  port (
    SEL : in slv2;                      -- select
    ABCLKDIV : in slv16;                -- serport clock divider
    DM_STAT_EXP : in dm_stat_exp_type;  -- debug and monitor - exports
    DISPREG : in slv16;                 -- display register
    DSP_DAT : out slv(4*(2**DCWIDTH)-1 downto 0)   -- display data
  );
end pdp11_dspmux;

architecture syn of pdp11_dspmux is

  subtype  dspdat_msb is integer range 4*(2**DCWIDTH)-1 downto 4*(2**DCWIDTH)-16;
  subtype  dspdat_lsb is integer range 15 downto 0;
  
begin

  assert DCWIDTH=2 or DCWIDTH=3 
    report "assert(DCWIDTH=2 or DCWIDTH=3): unsupported DCWIDTH"
    severity failure;

  proc_mux: process (SEL, ABCLKDIV, DM_STAT_EXP, DISPREG)
    variable idat : slv(4*(2**DCWIDTH)-1 downto 0) := (others=>'0');
  begin
    idat := (others=>'0');

    if DCWIDTH = 2 then

      case SEL is
        when "00" => 
          idat(dspdat_lsb) := ABCLKDIV;
        when "01" => 
          idat(dspdat_lsb) := DM_STAT_EXP.dp_pc;
        when "10" =>
          idat(dspdat_lsb) := DISPREG;
        when "11" => 
          idat(dspdat_lsb) := DM_STAT_EXP.dp_dsrc;
        when others => null;
      end case;

    else

      if SEL(1) = '0' then
        idat(dspdat_msb) := ABCLKDIV;
      else
        idat(dspdat_msb) := DM_STAT_EXP.dp_pc;
      end if;

      if SEL(0) = '0' then
        idat(dspdat_lsb) := DISPREG;
      else
        idat(dspdat_lsb) := DM_STAT_EXP.dp_dsrc;
      end if;
      
    end if;
    
    DSP_DAT <= idat;
    
  end process proc_mux;

end syn;
