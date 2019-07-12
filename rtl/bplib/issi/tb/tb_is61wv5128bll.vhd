-- $Id: tb_is61wv5128bll.vhd 1181 2019-07-08 17:00:50Z mueller $
-- SPDX-License-Identifier: GPL-3.0-or-later
-- Copyright 2017- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
--
------------------------------------------------------------------------------
-- Module Name:    tb_is61wv5128bll - sim
-- Description:    Test bench for is61wv5128bll memory model
--
-- Dependencies:   is61wv5128bll [UUT]
--
-- To test:        is61wv5128bll
--
-- Verified (with tb_is61wv5128bll_stim.dat):
-- Date         Rev  Code  ghdl  ise          Target     Comment
-- 2017-06-04   906  -     0.34  -            -          c:ok
--
-- Revision History:
-- Date         Rev Version  Comment
-- 2017-06-04   906   1.0    Initial version   (derived from tb_is61lv25616al)
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;
use std.textio.all;

use work.slvtypes.all;
use work.simlib.all;

entity tb_is61wv5128bll is
end tb_is61wv5128bll;

architecture sim of tb_is61wv5128bll is
  
  signal CE_N : slbit := '1';
  signal OE_N : slbit := '1';
  signal WE_N : slbit := '1';
  signal ADDR : slv19 := (others=>'0');
  signal DATA : slv8  := (others=>'0');
  
begin

  UUT : entity work.is61wv5128bll
    port map (
      CE_N => CE_N,
      OE_N => OE_N,
      WE_N => WE_N,
      ADDR => ADDR,
      DATA => DATA
    );

  proc_stim: process
    file fstim : text open read_mode is "tb_is61wv5128bll_stim";
    variable iline : line;
    variable oline : line;
    variable ok : boolean;
    variable dname : string(1 to 6) := (others=>' ');
    variable idtime : Delay_length := 0 ns;
    variable imatch : boolean := false;
    variable ival   : slbit := '0';
    variable ival8  : slv8  := (others=>'0');
    variable ival19 : slv19 := (others=>'0');
    variable ice : slbit := '0';
    variable ioe : slbit := '0';
    variable iwe : slbit := '0';
    variable iaddr : slv19 := (others=>'0');
    variable idata : slv8  := (others=>'0');
    variable ide : slbit  := '0';
    variable idchk : slv8 := (others=>'0');

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
            readtagval_ea(iline, "a", imatch, ival19, 16);
            if imatch then iaddr := ival19; end if;
            readtagval_ea(iline, "de", imatch, ival);
            if imatch then ide := ival; end if;
            readtagval_ea(iline, "d", imatch, ival8, 16);
            if imatch then idata := ival8; end if;

            CE_N <= not ice;
            OE_N <= not ioe;
            WE_N <= not iwe;
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
