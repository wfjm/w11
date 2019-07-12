-- $Id: tb_is61lv25616al.vhd 1181 2019-07-08 17:00:50Z mueller $
-- SPDX-License-Identifier: GPL-3.0-or-later
-- Copyright 2007-2011 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
--
------------------------------------------------------------------------------
-- Module Name:    tb_is61lv25616al - sim
-- Description:    Test bench for is61lv25616al memory model
--
-- Dependencies:   is61lv25616al [UUT]
--
-- To test:        is61lv25616al
--
-- Verified (with tb_is61lv25616al_stim.dat):
-- Date         Rev  Code  ghdl  ise          Target     Comment
-- 2010-05-16   291  -     0.26  -            -          c:ok
-- 2007-12-15   101  -     0.26  -            -          c:ok
--
-- Revision History:
-- Date         Rev Version  Comment
-- 2011-11-21   432   1.1.1  now numeric_std clean
-- 2010-05-16   291   1.1    initial values for all act.low signals now '1'
-- 2007-12-14   101   1.0    Initial version 
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;
use std.textio.all;

use work.slvtypes.all;
use work.simlib.all;

entity tb_is61lv25616al is
end tb_is61lv25616al;

architecture sim of tb_is61lv25616al is
  
  signal CE_N : slbit := '1';
  signal OE_N : slbit := '1';
  signal WE_N : slbit := '1';
  signal UB_N : slbit := '1';
  signal LB_N : slbit := '1';
  signal ADDR : slv18 := (others=>'0');
  signal DATA : slv16 := (others=>'0');
  
begin

  UUT : entity work.is61lv25616al
    port map (
      CE_N => CE_N,
      OE_N => OE_N,
      WE_N => WE_N,
      UB_N => UB_N,
      LB_N => LB_N,
      ADDR => ADDR,
      DATA => DATA
    );

  proc_stim: process
    file fstim : text open read_mode is "tb_is61lv25616al_stim";
    variable iline : line;
    variable oline : line;
    variable ok : boolean;
    variable dname : string(1 to 6) := (others=>' ');
    variable idtime : Delay_length := 0 ns;
    variable imatch : boolean := false;
    variable ival   : slbit := '0';
    variable ival2  : slv2  := (others=>'0');
    variable ival16 : slv16 := (others=>'0');
    variable ival18 : slv18 := (others=>'0');
    variable ice : slbit := '0';
    variable ioe : slbit := '0';
    variable iwe : slbit := '0';
    variable ibe : slv2  := "00";
    variable iaddr : slv18 := (others=>'0');
    variable idata : slv16 := (others=>'0');
    variable ide : slbit := '0';
    variable idchk : slv16 := (others=>'0');

  begin

    file_loop: while not endfile(fstim) loop

      readline (fstim, iline);

      readcomment(iline, ok);
      next file_loop when ok;

      readword(iline, dname, ok);
      if ok then
        case dname is
          when "wdo   " =>              -- wdo
            read_ea(iline, idtime);
            wait for idtime;

            readtagval_ea(iline, "ce", imatch, ival);
            if imatch then ice := ival; end if;
            readtagval_ea(iline, "oe", imatch, ival);
            if imatch then ioe := ival; end if;
            readtagval_ea(iline, "we", imatch, ival);
            if imatch then iwe := ival; end if;
            readtagval_ea(iline, "be", imatch, ival2, 2);
            if imatch then ibe := ival2; end if;
            readtagval_ea(iline, "a", imatch, ival18, 16);
            if imatch then iaddr := ival18; end if;
            readtagval_ea(iline, "de", imatch, ival);
            if imatch then ide := ival; end if;
            readtagval_ea(iline, "d", imatch, ival16, 16);
            if imatch then idata := ival16; end if;

            CE_N <= not ice;
            OE_N <= not ioe;
            WE_N <= not iwe;
            LB_N <= not ibe(0);
            UB_N <= not ibe(1);
            ADDR <= iaddr;
            if ide = '1' then
              DATA <= idata;
            else
              DATA <= (others=>'Z');
            end if;

            write(oline, now, right, 12);
            write(oline, string'(": wdo  "));
            write(oline, string'(" ce="));
            write(oline, ice);
            write(oline, string'(" oe="));
            write(oline, ioe);
            write(oline, string'(" we="));
            write(oline, iwe);
            write(oline, string'(" be="));
            write(oline, ibe, right, 2);
            write(oline, string'(" a="));
            writegen(oline, iaddr, right, 5, 16);
            write(oline, string'(" de="));
            write(oline, ide);
            if ide = '1' then
              write(oline, string'(" d="));
              writegen(oline, idata, right, 4, 16);              
            end if;
            
            readtagval_ea(iline, "D", imatch, idchk, 16);
            if imatch then
              write(oline, string'(" D="));
              writegen(oline, DATA, right, 4, 16);              
              write(oline, string'("  CHECK"));
              if DATA = idchk then
                write(oline, string'("  OK"));
              else
                write(oline, string'("  FAIL exp="));
                writegen(oline, idchk, right, 4, 16);              
              end if;
            end if;

            writeline(output, oline);
            
          when others =>                -- unknown command
            write(oline, string'("?? unknown command: "));
            write(oline, dname);
            writeline(output, oline);
            report "aborting" severity failure;
        end case;

      else
        report "failed to find command" severity failure;
        
      end if;

      testempty_ea(iline);

    end loop;

    write(oline, now, right, 12);
    write(oline, string'(": DONE"));
    writeline(output, oline);

    wait;                               -- suspend proc_stim forever
                                        -- no clock, sim will end

  end process proc_stim;

  
end sim;
