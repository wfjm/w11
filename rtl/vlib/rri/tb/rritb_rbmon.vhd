-- $Id: rritb_rbmon.vhd 314 2010-07-09 17:38:41Z mueller $
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
-- Module Name:    rritb_rbmon - sim
-- Description:    rritb: rri rbus monitor
--
-- Dependencies:   -
-- Test bench:     -
-- Tool versions:  xst 8.1, 8.2, 9.1, 9.2; ghdl 0.18-0.25
-- Revision History: 
-- Date         Rev Version  Comment
-- 2010-06-05   301   2.1.1  renamed _rpmon -> _rbmon
-- 2010-06-03   299   2.1    new init encoding (WE=0/1 int/ext)
-- 2010-05-02   287   2.0.1  rename RP_STAT->RB_STAT,AP_LAM->RB_LAM
--                           drop RP_IINT signal from interfaces
-- 2008-08-24   162   2.0    with new rb_mreq/rb_sres interface
-- 2008-03-24   129   1.2.1  CLK_CYCLE now 31 bits
-- 2007-12-23   105   1.2    added AP_LAM display
-- 2007-11-24    98   1.1    added RP_IINT support
-- 2007-08-27    76   1.0    Initial version 
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_textio.all;
use std.textio.all;

use work.slvtypes.all;
use work.simlib.all;
use work.rrilib.all;

entity rritb_rbmon is                   -- rritb, rri rbus monitor
  generic (
    DBASE : positive :=  2);            -- base for writing data values
  port (
    CLK  : in slbit;                    -- clock
    CLK_CYCLE : in slv31 := (others=>'0');  -- clock cycle number
    ENA  : in slbit := '1';             -- enable monitor output
    RB_MREQ : in rb_mreq_type;          -- rbus: request
    RB_SRES : in rb_sres_type;          -- rbus: response
    RB_LAM : in slv16 := (others=>'0'); -- rbus: look at me
    RB_STAT : in slv3                   -- rbus: status flags
  );
end rritb_rbmon;


architecture sim of rritb_rbmon is
  
begin

  proc_rbmoni: process
    variable oline : line;
    variable nhold : integer := 0;
    variable data : slv16 := (others=>'0');
    variable tag : string(1 to 8) := (others=>' ');
    variable err : slbit := '0';

    procedure write_data(L: inout line;
                         tag: in string;
                         data: in slv16;
                         nhold: in integer := 0;
                         cond: in boolean := false;
                         ctxt: in string := " ") is
    begin
      writetimestamp(L, CLK_CYCLE, tag);
      write(L, RB_MREQ.addr, right, 10);
      write(L, string'(" "));
      writegen(L, data, right, 0, DBASE);
      write(L, RB_STAT, right, 4);
      if nhold > 0 then
        write(L, string'("  nhold="));
        write(L, nhold);
      end if;
      if cond then
        write(L, ctxt);
      end if;
      writeline(output, L);
    end procedure write_data;

  begin
    
    loop 

      if ENA = '0' then                 -- if disabled
        wait until ENA='1';             -- stall process till enabled
      end if;

      wait until CLK'event and CLK='1'; -- check at end of clock cycle

      if RB_MREQ.req = '1' then
        if RB_SRES.err = '1' then
          err := '1';
        end if;
        if RB_SRES.busy = '1' then
          nhold := nhold + 1;
        else
          if RB_MREQ.req = '1' then
            if RB_MREQ.we = '0' then
              data := RB_SRES.dout;
              tag  :=  ": rbre  ";
            else
              data := RB_MREQ.din;
              tag  :=  ": rbwe  ";
            end if;
          end if;

          write_data(oline, tag, data, nhold, err='1', "  ERR='1'");
          nhold := 0;
        end if;
        
      else
        if nhold > 0 then
          write_data(oline, tag, data, nhold, true, "  TIMEOUT");
        end if;
        nhold := 0;
        err := '0';
      end if;

      if RB_MREQ.init = '1' then                     -- init
        if RB_MREQ.we = '1' then
          write_data(oline, ": rbini ", RB_MREQ.din);  -- external
        else
          write_data(oline, ": rbint ", RB_MREQ.din);  -- internal
        end if;
      end if;

      if unsigned(RB_LAM) /= 0 then
        write_data(oline, ": rblam ", RB_LAM, 0, true, "  RB_LAM active");
      end if;
                  
    end loop;
  end process proc_rbmoni;
  
end sim;
