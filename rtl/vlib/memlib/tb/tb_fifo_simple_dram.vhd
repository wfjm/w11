-- $Id: tb_fifo_simple_dram.vhd 1181 2019-07-08 17:00:50Z mueller $
-- SPDX-License-Identifier: GPL-3.0-or-later
-- Copyright 2019- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
--
------------------------------------------------------------------------------
-- Module Name:    tb_fifo_simple_dram - sim
-- Description:    Test bench for fifo_simple_dram
--
-- Dependencies:   simlib/simclk
--                 simlib/simclkcnt
--                 tbd_fifo_simple_dram [UUT]
--
-- To test:        fifo_simple_dram
--
-- Target Devices: generic
-- Tool versions:  xst 14.7; viv 2017.2 ghdl 0.35
-- Revision History: 
-- Date         Rev Version  Comment
-- 2019-02-09  1109   1.0    Initial version 
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;
use std.textio.all;

use work.slvtypes.all;
use work.simlib.all;

entity tb_fifo_simple_dram is
end tb_fifo_simple_dram;

architecture sim of tb_fifo_simple_dram is
  
  signal CLK :  slbit := '0';
  signal RESET :  slbit := '0';
  signal CE : slbit := '0';
  signal WE : slbit := '0';
  signal DI : slv16 := (others=>'0');
  signal DO : slv16 := (others=>'0');
  signal EMPTY : slbit := '0';
  signal FULL : slbit := '0';
  signal SIZE : slv4 := (others=>'0');

  signal N_EMPTY : slbit := '1';
  signal N_FULL  : slbit := '0';
  signal N_SIZE  : slv4 := (others=>'0');
  signal R_EMPTY : slbit := '1';
  signal R_FULL  : slbit := '0';
  signal R_SIZE  : slv4 := (others=>'0');
  
  signal CLK_STOP : slbit := '0';
  signal CLK_CYCLE : integer := 0;

  constant clock_period : Delay_length :=  20 ns;
  constant clock_offset : Delay_length := 200 ns;
  constant setup_time : Delay_length :=  5 ns;
  constant c2out_time : Delay_length := 10 ns;

begin

  CLKGEN : simclk
    generic map (
      PERIOD => clock_period,
      OFFSET => clock_offset)
    port map (
      CLK => CLK,
      CLK_STOP => CLK_STOP
    );

  CLKCNT : simclkcnt port map (CLK => CLK, CLK_CYCLE => CLK_CYCLE);
  
  UUT : entity work.tbd_fifo_simple_dram
    port map (
      CLK    => CLK,
      RESET  => RESET,
      CE     => CE,
      WE     => WE,
      DI     => DI,
      DO     => DO,
      EMPTY  => EMPTY,
      FULL   => FULL,
      SIZE   => SIZE
    );


  proc_stim: process
    file fstim : text open read_mode is "tb_fifo_simple_dram_stim";
    variable iline : line;
    variable oline : line;
    variable dname : string(1 to 6) := (others=>' ');
    variable ok : boolean;
    variable nwait : integer := 0;      -- 
    variable idi : slv16 := (others=>'0');
    variable ido : slv16 := (others=>'0');
    variable isize : slv4 := (others=>'0');
  begin
    
    wait for clock_offset;
    wait until rising_edge(CLK);

    file_loop: while not endfile(fstim) loop

      readline (fstim, iline);
      
      readcomment(iline, ok);
      next file_loop when ok;

      readword(iline, dname, ok);
      if ok then
        case dname is
          when ".wait " =>              -- .wait ncyc  
            read_ea(iline, nwait);
            for i in 1 to nwait loop
              wait until rising_edge(CLK);
            end loop;  -- i
            
          when "reset " =>              -- reset
            writetimestamp(oline, CLK_CYCLE, ": reset");
            writeline(output, oline);
            RESET <= '1';
            isize := "0000";
            N_EMPTY <= '1';
            N_FULL  <= '0';
            N_SIZE  <= isize;
            wait until rising_edge(CLK);
            RESET <= '0';
            wait for 0 ns;

          when "write " =>              -- write di
            readgen_ea(iline, idi, 16);
            writetimestamp(oline, CLK_CYCLE, ": write");
            write(oline, idi, right, 18);
            writeline(output, oline);
            CE <= '1';
            WE <= '1';
            DI <= idi;
            isize := slv(unsigned(isize) + 1);
            N_SIZE  <= isize;
            N_EMPTY <= '0';
            if isize = "1111" then
              N_FULL  <= '1';
            end if;
            
            wait until rising_edge(CLK);
            CE <= '0';
            WE <= '0';
            wait for 0 ns;
            
          when "read  " =>              -- read do
            readgen_ea(iline, ido, 16);
            CE <= '1';
            WE <= '0';
            isize := slv(unsigned(isize) - 1);
            N_SIZE <= isize;
            N_FULL <= '0';
            if isize = "0000" then
              N_EMPTY <= '1';
            end if;
            
            wait for c2out_time;        -- check same cycle read response
            writetimestamp(oline, CLK_CYCLE, ": read ");
            write(oline, DO, right, 18);
            if DO = ido then
              write(oline, string'(" OK"));
            else
              write(oline, string'(" FAIL, exp="));
              write(oline, ido, right, 18);
            end if;
            writeline(output, oline);            

            wait until rising_edge(CLK);
            CE <= '0';
            wait for 0 ns;
 
          when others =>                -- bad directive
            write(oline, string'("?? unknown command: "));
            write(oline, dname);
            writeline(output, oline);
            report "aborting" severity failure;
        end case;

      else
        report "failed to find command" severity failure;
      end if;
        
    end loop; -- file_loop:

    writetimestamp(oline, CLK_CYCLE, ": DONE ");
    writeline(output, oline);

    wait for 20*clock_period;

    CLK_STOP <= '1';

    wait;                               -- suspend proc_stim forever
                                        -- clock is stopped, sim will end

  end process proc_stim;

  
  proc_moni: process
    variable oline : line;
    variable iempty_1 : slbit := '1';
  begin

    loop
      
      wait until rising_edge(CLK);      -- at rising clock
      
      R_EMPTY <= N_EMPTY;               -- latch expected values
      R_FULL  <= N_FULL;
      R_SIZE  <= N_SIZE;
      
      wait for c2out_time;              -- after clock2output time check

      if EMPTY='0' or iempty_1 ='0' then
        writetimestamp(oline, CLK_CYCLE, ": moni ");
        write(oline, DO, right, 18);
        write(oline, EMPTY, right, 3);
        write(oline, FULL,  right, 2);
        write(oline, SIZE, right, 6);
        write(oline, string'("  ("));
        write(oline, to_integer(unsigned(SIZE)), right, 2);
        write(oline, string'(")"));
        if EMPTY /= R_EMPTY then
           write(oline, string'(" FAIL EMPTY exp="));
           write(oline, R_EMPTY);
        end if;
        if FULL /= R_FULL then
           write(oline, string'(" FAIL FULL exp="));
           write(oline, R_FULL);
        end if;
        if SIZE /= R_SIZE then
           write(oline, string'(" FAIL SIZE exp="));
           write(oline, R_SIZE);
        end if;
        writeline(output, oline);
      end if;

      iempty_1 := EMPTY;
      
    end loop;
    
  end process proc_moni;

end sim;
