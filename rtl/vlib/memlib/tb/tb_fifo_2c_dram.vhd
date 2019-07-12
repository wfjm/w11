-- $Id: tb_fifo_2c_dram.vhd 1181 2019-07-08 17:00:50Z mueller $
-- SPDX-License-Identifier: GPL-3.0-or-later
-- Copyright 2007-2011 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
--
------------------------------------------------------------------------------
-- Module Name:    tb_fifo_2c_dram - sim
-- Description:    Test bench for fifo_2c_dram
--
-- Dependencies:   simlib/simclkv
--                 simlib/simclkvcnt
--                 tbd_fifo_2c_dram [UUT]
--
-- To test:        fifo_2c_dram
--
-- Target Devices: generic
-- Tool versions:  xst 8.2, 9.1, 9.2, 11.3, 13.1; ghdl 0.18-0.29
-- Revision History: 
-- Date         Rev Version  Comment
-- 2011-12-23   444   1.1    use new simclk/simclkcnt
-- 2011-11-07   421   1.0.5  now numeric_std clean
-- 2010-06-03   299   1.0.4  use sv_ prefix for shared variables
-- 2010-04-17   277   1.0.3  use direct instantiation of tbd_
-- 2009-11-22   252   1.0.2  CLK*_CYCLE now 31 bits
-- 2007-12-28   107   1.0.1  add reset and check handling
-- 2007-12-28   106   1.0    Initial version 
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;
use std.textio.all;

use work.slvtypes.all;
use work.simlib.all;

entity tb_fifo_2c_dram is
end tb_fifo_2c_dram;

architecture sim of tb_fifo_2c_dram is
  
  signal CLKW :  slbit := '0';
  signal CLKR :  slbit := '0';
  signal RESETW :  slbit := '0';
  signal RESETR :  slbit := '0';
  signal DI :  slv16 := (others=>'0');
  signal ENA : slbit := '0';
  signal BUSY : slbit := '0';
  signal DO :  slv16 := (others=>'0');
  signal VAL : slbit := '0';
  signal SIZEW :  slv4 := (others=>'0');
  signal SIZER :  slv4 := (others=>'0');
  
  signal N_HOLD : slbit := '0';
  signal R_HOLD : slbit := '0';

  signal CLKW_PERIOD : Delay_length := 20 ns;
  signal CLKR_PERIOD : Delay_length := 20 ns;
  signal CLK_HOLD : slbit := '1';
  signal CLK_STOP : slbit := '0';
  signal CLKW_CYCLE : integer := 0;
  signal CLKR_CYCLE : integer := 0;

  signal CLKR_C2OUT : Delay_length := 10 ns;

  shared variable sv_nrstr  : integer := 0;
  shared variable sv_ndatar : integer := 0;  -- data counter (fifo data output)

begin

  CLKWGEN : simclkv
    port map (
      CLK => CLKW,
      CLK_PERIOD => CLKW_PERIOD,
      CLK_HOLD => CLK_HOLD,
      CLK_STOP => CLK_STOP
    );

  CLKWCNT : simclkcnt port map (CLK => CLKW, CLK_CYCLE => CLKW_CYCLE);

  CLKRGEN : simclkv
    port map (
      CLK => CLKR,
      CLK_PERIOD => CLKR_PERIOD,
      CLK_HOLD => CLK_HOLD,
      CLK_STOP => CLK_STOP
    );
  
  CLKRCNT : simclkcnt port map (CLK => CLKR, CLK_CYCLE => CLKR_CYCLE);

  UUT : entity work.tbd_fifo_2c_dram
    port map (
      CLKW   => CLKW,
      CLKR   => CLKR,
      RESETW => RESETW,
      RESETR => RESETR,
      DI     => DI,
      ENA    => ENA,
      BUSY   => BUSY,
      DO     => DO,
      VAL    => VAL,
      HOLD   => R_HOLD,
      SIZEW  => SIZEW,
      SIZER  => SIZER
    );


  proc_stim: process
    file fstim : text open read_mode is "tb_fifo_2c_dram_stim";
    variable iline : line;
    variable oline : line;
    variable dname : string(1 to 6) := (others=>' ');
    variable ok : boolean;
    variable dtime : Delay_length := 0 ns;
    variable nwait : integer := 0;      -- 
    variable nword : integer := 0;      -- 
    variable nbusy : integer := 0;      -- number of busy before accept
    variable idi : slv16 := (others=>'0');
    
    variable ndataw : integer := 0;      -- data counter (fifo data input)

    variable iclkw_period : Delay_length := 20 ns;
    variable iclkw_setup : Delay_length  :=  5 ns;
    variable iclkr_period : Delay_length := 20 ns;
    variable iclkr_c2out : Delay_length  := 10 ns;

  begin
    
    file_loop: while not endfile(fstim) loop

      readline (fstim, iline);
      
      readcomment(iline, ok);
      next file_loop when ok;

      readword(iline, dname, ok);

      if ok then
        case dname is
          when ".chold" =>              -- .chold time
            write(oline, string'(".chold"));
            writeline(output, oline);
            read_ea(iline, dtime);
            CLK_HOLD <= '1';
            wait for dtime;
            CLK_HOLD <= '0';
            wait until rising_edge(CLKW);
            wait for iclkw_period-iclkw_setup;

          when ".cdef " =>              -- .cdef wper wset rper rout
            write(oline, string'(".cdef "));
            writeline(output, oline);
            read_ea(iline, iclkw_period);
            read_ea(iline, iclkw_setup);
            read_ea(iline, iclkr_period);
            read_ea(iline, iclkr_c2out);
            CLKW_PERIOD <= iclkw_period;
            CLKR_PERIOD <= iclkr_period;
            CLKR_C2OUT  <= iclkr_c2out;
            if CLK_HOLD = '0' then
              wait until rising_edge(CLKW);
              wait for iclkw_period-iclkw_setup;
            end if;

          when ".ndata" =>              -- .ndata num
            read_ea(iline, ndataw);
            sv_ndatar := ndataw;

          when ".hold " =>              -- .hold time
            read_ea(iline, dtime);
            if dtime > 0 ns then          
              N_HOLD <= '1', '0' after dtime;
            else                          -- allow hold abort with 0ns
              N_HOLD <= '0';
            end if;

          when ".wait " =>              -- .wait ncyc  
            read_ea(iline, nwait);
            wait for nwait*iclkw_period;

          when "resetw" =>              -- resetw ncyc 
            read_ea(iline, nwait);
            RESETW <= '1';
            wait for nwait*iclkw_period;
            RESETW <= '0';

          when "resetr" =>              -- resetr ncyc 
            read_ea(iline, nwait);
            sv_nrstr := nwait;

          when "send  " =>              -- send nw nd
            read_ea(iline, nwait);
            read_ea(iline, nword);
            for i in 1 to nword loop
              wait for nwait*iclkw_period;

              idi := slv(to_unsigned(ndataw, 16));
              ndataw := ndataw + 1;
              DI  <= idi;
              ENA <= '1';
              nbusy := 0;

              while BUSY='1' loop
                nbusy := nbusy + 1;
                wait for iclkw_period;
              end loop;

              writetimestamp(oline, CLKW_CYCLE, ": stim ");
              write(oline, idi, right, 18);
              write(oline, SIZEW, right, 7);
              write(oline, string'("  ("));
              write(oline, to_integer(unsigned(idi)), right, 5);
              write(oline, string'(","));
              write(oline, to_integer(unsigned(SIZEW)), right, 2);
              write(oline, string'(")"));
              if nbusy > 0 then
                write(oline, string'("  nbusy="));
                write(oline, nbusy, right, 2);
              end if;
              writeline(output, oline);

              wait for iclkw_period;
              ENA <= '0';

            end loop;  -- i

          when others =>                -- bad directive
            write(oline, string'("?? unknown command: "));
            write(oline, dname);
            writeline(output, oline);
            report "aborting" severity failure;
        end case;
        
      else
        report "failed to find command" severity failure;
      end if;

      testempty_ea(iline);
      
    end loop; -- file_loop:

    if N_HOLD = '1' then
      wait until N_HOLD='0';
    end if;
    wait for 20*(iclkw_period+iclkr_period);
    CLK_STOP <= '1';

    writetimestamp(oline, CLKW_CYCLE, ": DONE-w ");
    writeline(output, oline);
    writetimestamp(oline, CLKR_CYCLE, ": DONE-r ");
    writeline(output, oline);

    wait;                               -- suspend proc_stim forever
                                        -- clock is stopped, sim will end
  end process proc_stim;
    
  
  proc_moni: process
    variable oline : line;
    variable nhold : integer := 0;      -- number of hold cycles before accept
    variable isizer_last : slv4 := (others=>'0');
    variable ido : slv16 := (others=>'0');
  begin

    loop 
      wait until rising_edge(CLKR);
      wait for CLKR_C2OUT;

      if VAL = '1' then
        if R_HOLD = '1' then
          nhold := nhold + 1;
        else
          ido := slv(to_unsigned(sv_ndatar, 16));
          sv_ndatar := sv_ndatar + 1;

          writetimestamp(oline, CLKR_CYCLE, ": moni ");
          write(oline, DO, right, 18);
          write(oline, SIZER, right, 7);
          write(oline, string'("  ("));
          write(oline, to_integer(unsigned(DO)), right, 5);
          write(oline, string'(","));
          write(oline, to_integer(unsigned(SIZER)), right, 2);
          write(oline, string'(")"));
          if nhold > 0 then
            write(oline, string'("  nhold="));
            write(oline, nhold, right, 2);
          end if;
          
          if DO = ido then
            write(oline, string'(" OK"));
          else
            write(oline, string'(" FAIL, exp="));
            write(oline, ido, right, 18);
          end if;
          
          writeline(output, oline);
          nhold := 0;
        end if;
      else
        if SIZER /= isizer_last then
          writetimestamp(oline, CLKR_CYCLE, ": moni ");
          write(oline, string'("                  "));
          write(oline, SIZER, right, 7);
          write(oline, string'("        ("));
          write(oline, to_integer(unsigned(SIZER)), right, 2);
          write(oline, string'(")"));
          writeline(output, oline);          
        end if;
      end if;

      isizer_last := SIZER;
      
    end loop;
    
  end process proc_moni;
  
  proc_clkr: process (CLKR)
  begin
    if rising_edge(CLKR) then
      R_HOLD <= N_HOLD;
      
      if sv_nrstr > 0 then
        RESETR <= '1';
        sv_nrstr := sv_nrstr - 1;
      else
        RESETR <= '0';
      end if;
    end if;
  end process proc_clkr;

end sim;
