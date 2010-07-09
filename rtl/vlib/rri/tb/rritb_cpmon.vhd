-- $Id: rritb_cpmon.vhd 314 2010-07-09 17:38:41Z mueller $
--
-- Copyright 2007-2010 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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
-- Module Name:    rritb_cpmon - sim
-- Description:    rritb: rri comm port monitor
--
-- Dependencies:   -
-- Test bench:     -
-- Tool versions:  xst 8.1, 8.2, 9.1, 9.2; ghdl 0.18-0.25
-- Revision History: 
-- Date         Rev Version  Comment
-- 2010-06-11   303   2.5.1  fix data9 assignment, always proper width now
-- 2010-06-07   302   2.5    use sop/eop framing instead of soc+chaining
-- 2008-03-24   129   1.0.1  CLK_CYCLE now 31 bits
-- 2007-09-09    81   1.0    Initial version 
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_textio.all;
use std.textio.all;

use work.slvtypes.all;
use work.simlib.all;
use work.rrilib.all;

entity rritb_cpmon is                   -- rritb, rri comm port monitor
  generic (
    DWIDTH : positive :=  9);           -- data port width (8 or 9)
  port (
    CLK  : in slbit;                    -- clock
    CLK_CYCLE : in slv31 := (others=>'0');  -- clock cycle number
    ENA  : in slbit := '1';             -- enable monitor output
    CP_DI : in slv(DWIDTH-1 downto 0);  -- comm port: data in
    CP_ENA : in slbit;                  -- comm port: data enable
    CP_BUSY : in slbit;                 -- comm port: data busy
    CP_DO : in slv(DWIDTH-1 downto 0);  -- comm port: data out
    CP_VAL : in slbit;                  -- comm port: data valid
    CP_HOLD : in slbit                  -- comm port: data hold
  );
end rritb_cpmon;


architecture sim of rritb_cpmon is

begin

  assert DWIDTH=8 or DWIDTH=9
    report "assert(DWIDTH=8 or DWIDTH=9)" severity failure;
  
  proc_cpmoni: process
    variable oline : line;
    variable nbusy : integer := 0;
    variable nhold : integer := 0;

    procedure write_val(L: inout line;
                        data: in slv(DWIDTH-1 downto 0);
                        nwait: in integer;
                        txt1: in string;
                        txt2: in string) is
      variable data9 : slv9 := (others=>'0');
    begin

      writetimestamp(L, CLK_CYCLE, txt1);

      if DWIDTH = 9 then
        write(L, data(data'left), right, 1);
      else
        write(L, string'(" "));
      end if;

      write(L, data(7 downto 0), right, 9);
      if nwait > 0 then
        write(L, txt2);
        write(L, nwait);
      end if;

      if DWIDTH=9 and data(data'left)='1' then
        -- a copy to data9 needed to allow following case construct
        -- using data directly gives a 'subtype is not locally static' error
        data9 := (others=>'0');
        data9(data'range) := data;
        write(L, string'("  comma"));
        case data9 is
          when c_rri_dat_idle => write(L, string'(" idle"));
          when c_rri_dat_sop  => write(L, string'(" sop"));
          when c_rri_dat_eop  => write(L, string'(" eop"));
          when c_rri_dat_nak  => write(L, string'(" nak"));
          when c_rri_dat_attn => write(L, string'(" attn"));
          when others => null;
        end case;
      end if;

      writeline(output, L);
    end procedure write_val;

  begin
    
    loop

      if ENA='0' then                   -- if disabled
        wait until ENA='1';             -- stall process till enabled
      end if;

      wait until CLK'event and CLK='1'; -- check at end of clock cycle

      if CP_ENA = '1' then
        if CP_BUSY = '1' then
          nbusy := nbusy + 1;
        else
          write_val(oline, CP_DI, nbusy, ": cprx  ", "  nbusy=");
          nbusy := 0;
        end if;
      else
        nbusy := 0;
      end if;
        
      if CP_VAL = '1' then
        if CP_HOLD = '1' then
          nhold := nhold + 1;
        else
          write_val(oline, CP_DO, nhold, ": cptx  ", "  nhold=");
          nhold := 0;
        end if;
      else
        nhold := 0;
      end if;
      
    end loop;
  end process proc_cpmoni;
  
end sim;
