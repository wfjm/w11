-- $Id: tb_mt45w8mw16b.vhd 1181 2019-07-08 17:00:50Z mueller $
-- SPDX-License-Identifier: GPL-3.0-or-later
-- Copyright 2010-2016 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
--
------------------------------------------------------------------------------
-- Module Name:    tb_mt45w8mw16b - sim
-- Description:    Test bench for mt45w8mw16b memory model
--
-- Dependencies:   mt45w8mw16b [UUT]
--                 simlib/simbididly
--
-- To test:        mt45w8mw16b
--
-- Verified (with tb_mt45w8mw16b_stim.dat):
-- Date         Rev  Code  ghdl  ise          Target     Comment
-- 2016-07-16   787  -     0.33  -            -          c:ok
-- 2010-05-16   291  -     0.26  -            -          c:ok
--
-- Revision History:
-- Date         Rev Version  Comment
-- 2016-07-16   787   1.2    test also CRE; use simbididly;
-- 2011-11-21   432   1.1.1  now numeric_std clean
-- 2010-05-16   291   1.0    Initial version (cloned from  tb_is61lv25616al)
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;
use std.textio.all;

use work.slvtypes.all;
use work.simlib.all;

entity tb_mt45w8mw16b is
end tb_mt45w8mw16b;

architecture sim of tb_mt45w8mw16b is

  constant pcb_delay : Delay_length := 1 ns;
  
  signal MM_CE_N  : slbit := '1';
  signal MM_OE_N  : slbit := '1';
  signal MM_WE_N  : slbit := '1';
  signal MM_UB_N  : slbit := '1';
  signal MM_LB_N  : slbit := '1';
  signal MM_CRE   : slbit := '0';
  signal MM_MWAIT : slbit := '0';
  signal MM_ADDR  : slv23 := (others=>'0');
  signal MM_DATA  : slv16 := (others=>'Z');
  
  signal TB_CE_N  : slbit := '1';
  signal TB_OE_N  : slbit := '1';
  signal TB_WE_N  : slbit := '1';
  signal TB_UB_N  : slbit := '1';
  signal TB_LB_N  : slbit := '1';
  signal TB_CRE   : slbit := '0';
  signal TB_MWAIT : slbit := '0';
  signal TB_ADDR  : slv23 := (others=>'0');
  signal TB_DATA  : slv16 := (others=>'Z');

begin

  UUT : entity work.mt45w8mw16b
    port map (
      CLK   => '0',
      CE_N  => MM_CE_N,
      OE_N  => MM_OE_N,
      WE_N  => MM_WE_N,
      UB_N  => MM_UB_N,
      LB_N  => MM_LB_N,
      ADV_N => '0',
      CRE   => MM_CRE,
      MWAIT => MM_MWAIT,
      ADDR  => MM_ADDR,
      DATA  => MM_DATA
    );

  MM_CE_N  <= TB_CE_N  after pcb_delay;
  MM_OE_N  <= TB_OE_N  after pcb_delay;
  MM_WE_N  <= TB_WE_N  after pcb_delay;
  MM_UB_N  <= TB_UB_N  after pcb_delay;
  MM_LB_N  <= TB_LB_N  after pcb_delay;
  MM_CRE   <= TB_CRE   after pcb_delay;
  MM_ADDR  <= TB_ADDR  after pcb_delay;
  TB_MWAIT <= MM_MWAIT after pcb_delay;

  BUSDLY: simbididly
    generic map (
      DELAY  => pcb_delay,
      DWIDTH => 16)
    port map (
      A => TB_DATA,
      B => MM_DATA);
  
  proc_stim: process
    file fstim : text open read_mode is "tb_mt45w8mw16b_stim";
    variable iline : line;
    variable oline : line;
    variable ok : boolean;
    variable dname : string(1 to 6) := (others=>' ');
    variable idtime : Delay_length := 0 ns;
    variable imatch : boolean := false;
    variable ival   : slbit := '0';
    variable ival2  : slv2  := (others=>'0');
    variable ival16 : slv16 := (others=>'0');
    variable ival23 : slv23 := (others=>'0');
    variable ice   : slbit := '0';
    variable ioe   : slbit := '0';
    variable iwe   : slbit := '0';
    variable ibe   : slv2  := "00";
    variable icre  : slbit := '0';
    variable iaddr : slv23 := (others=>'0');
    variable idata : slv16 := (others=>'0');
    variable ide   : slbit := '0';
    variable idchk : slv16 := (others=>'0');

  begin

    -- initial signal driver settings
    TB_CE_N  <= '1';
    TB_OE_N  <= '1';
    TB_WE_N  <= '1';
    TB_UB_N  <= '1';
    TB_LB_N  <= '1';
    TB_CRE   <= '0';
    TB_ADDR  <= (others=>'0');
    TB_DATA  <= (others=>'Z');    
    
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
            readtagval_ea(iline, "cre", imatch, ival);
            if imatch then icre := ival; end if;
            readtagval_ea(iline, "oe", imatch, ival);
            if imatch then ioe := ival; end if;
            readtagval_ea(iline, "we", imatch, ival);
            if imatch then iwe := ival; end if;
            readtagval_ea(iline, "be", imatch, ival2, 2);
            if imatch then ibe := ival2; end if;
            readtagval_ea(iline, "a", imatch, ival23, 16);
            if imatch then iaddr := ival23; end if;
            readtagval_ea(iline, "de", imatch, ival);
            if imatch then ide := ival; end if;
            readtagval_ea(iline, "d", imatch, ival16, 16);
            if imatch then idata := ival16; end if;

            TB_CE_N <= not ice;
            TB_OE_N <= not ioe;
            TB_WE_N <= not iwe;
            TB_LB_N <= not ibe(0);
            TB_UB_N <= not ibe(1);
            TB_CRE  <=     icre;
            TB_ADDR <= iaddr;
            if ide = '1' then
              TB_DATA <= idata;
            else
              TB_DATA <= (others=>'Z');
            end if;

            write(oline, now, right, 12);
            write(oline, string'(": wdo  "));
            write(oline, string'(" ce="));
            write(oline, ice);
            write(oline, string'(" oe="));
            write(oline, ioe);
            write(oline, string'(" we="));
            write(oline, iwe);
            if icre = '0' then
              write(oline, string'(" be="));
              write(oline, ibe, right, 2);
            else
              write(oline, string'(" cre=1"));
            end if;
            write(oline, string'(" a="));
            writegen(oline, iaddr, right, 6, 16);
            write(oline, string'(" de="));
            write(oline, ide);
            if ide = '1' then
              write(oline, string'(" d="));
              writegen(oline, idata, right, 4, 16);              
            end if;
            
            readtagval_ea(iline, "D", imatch, idchk, 16);
            if imatch then
              write(oline, string'(" D="));
              writegen(oline, TB_DATA, right, 4, 16);              
              write(oline, string'("  CHECK"));
              if TB_DATA = idchk then
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
