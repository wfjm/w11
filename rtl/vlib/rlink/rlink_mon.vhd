-- $Id: rlink_mon.vhd 444 2011-12-25 10:04:58Z mueller $
--
-- Copyright 2007-2011 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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
-- Module Name:    rlink_mon - sim
-- Description:    rlink monitor (for tb's)
--
-- Dependencies:   -
-- Test bench:     -
-- Tool versions:  xst 8.2, 9.1, 9.2, 12.1, 13.1; ghdl 0.18-0.29
--
-- Revision History: 
-- Date         Rev Version  Comment
-- 2011-12-23   444   3.1    CLK_CYCLE now integer
-- 2011-11-19   427   3.0.2  now numeric_std clean
-- 2010-12-24   347   3.0.1  rename: CP_*->RL->*
-- 2010-12-22   346   3.0    renamed rritb_cpmon -> rlink_mon
-- 2010-06-11   303   2.5.1  fix data9 assignment, always proper width now
-- 2010-06-07   302   2.5    use sop/eop framing instead of soc+chaining
-- 2008-03-24   129   1.0.1  CLK_CYCLE now 31 bits
-- 2007-09-09    81   1.0    Initial version 
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;
use std.textio.all;

use work.slvtypes.all;
use work.simlib.all;
use work.rlinklib.all;

entity rlink_mon is                     -- rlink monitor
  generic (
    DWIDTH : positive :=  9);           -- data port width (8 or 9)
  port (
    CLK  : in slbit;                    -- clock
    CLK_CYCLE : in integer := 0;        -- clock cycle number
    ENA  : in slbit := '1';             -- enable monitor output
    RL_DI : in slv(DWIDTH-1 downto 0);  -- rlink: data in
    RL_ENA : in slbit;                  -- rlink: data enable
    RL_BUSY : in slbit;                 -- rlink: data busy
    RL_DO : in slv(DWIDTH-1 downto 0);  -- rlink: data out
    RL_VAL : in slbit;                  -- rlink: data valid
    RL_HOLD : in slbit                  -- rlink: data hold
  );
end rlink_mon;


architecture sim of rlink_mon is

begin

  assert DWIDTH=8 or DWIDTH=9
    report "assert(DWIDTH=8 or DWIDTH=9)" severity failure;
  
  proc_moni: process
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
          when c_rlink_dat_idle => write(L, string'(" idle"));
          when c_rlink_dat_sop  => write(L, string'(" sop"));
          when c_rlink_dat_eop  => write(L, string'(" eop"));
          when c_rlink_dat_nak  => write(L, string'(" nak"));
          when c_rlink_dat_attn => write(L, string'(" attn"));
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

      wait until rising_edge(CLK); -- check at end of clock cycle

      if RL_ENA = '1' then
        if RL_BUSY = '1' then
          nbusy := nbusy + 1;
        else
          write_val(oline, RL_DI, nbusy, ": rlrx  ", "  nbusy=");
          nbusy := 0;
        end if;
      else
        nbusy := 0;
      end if;
        
      if RL_VAL = '1' then
        if RL_HOLD = '1' then
          nhold := nhold + 1;
        else
          write_val(oline, RL_DO, nhold, ": rltx  ", "  nhold=");
          nhold := 0;
        end if;
      else
        nhold := 0;
      end if;
      
    end loop;
  end process proc_moni;
  
end sim;
