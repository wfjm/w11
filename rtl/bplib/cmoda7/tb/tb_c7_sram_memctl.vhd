-- $Id: tb_c7_sram_memctl.vhd 1181 2019-07-08 17:00:50Z mueller $
-- SPDX-License-Identifier: GPL-3.0-or-later
-- Copyright 2017- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
--
------------------------------------------------------------------------------
-- Module Name:    tb_c7_sram_memctl - sim
-- Description:    Test bench for c7_sram_memctl
--
-- Dependencies:   vlib/simlib/simclk
--                 vlib/simlib/simclkcnt
--                 bplib/issi/is61wv5128bll
--                 c7_sram_memctl [UUT]
--
-- To test:        c7_sram_memctl
--                 
-- Verified (with tb_c7_sram_memctl_stim.dat):
-- Date         Rev  Code  ghdl  viv          Target     Comment
-- 2017-06-11   912  _ssim 0.34  2017.1       xx         xx  
--
-- Target Devices: generic
-- Tool versions:  viv 2017.1; ghdl 0.34
--
-- Revision History: 
-- Date         Rev Version  Comment
-- 2017-06-13   913   1.0    Initial version (derived from tb_s3_sram_memctl)
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;
use std.textio.all;

use work.slvtypes.all;
use work.cmoda7lib.all;
use work.simlib.all;

entity tb_c7_sram_memctl is
end tb_c7_sram_memctl;

architecture sim of tb_c7_sram_memctl is
  
  signal CLK   : slbit := '0';
  signal RESET : slbit := '0';
  signal REQ   : slbit := '0';
  signal WE    : slbit := '0';
  signal BUSY  : slbit := '0';
  signal ACK_R : slbit := '0';
  signal ACK_W : slbit := '0';
  signal ACT_R : slbit := '0';
  signal ACT_W : slbit := '0';
  signal ADDR : slv17 := (others=>'0');
  signal BE : slv4  := (others=>'0');
  signal DI : slv32 := (others=>'0');
  signal DO : slv32 := (others=>'0');
  signal O_MEM_CE_N : slbit  := '0';
  signal O_MEM_WE_N : slbit  := '0';
  signal O_MEM_OE_N : slbit  := '0';
  signal O_MEM_ADDR  : slv19 := (others=>'0');
  signal IO_MEM_DATA : slv8  := (others=>'0');

  signal R_MEMON : slbit  := '0';
  signal N_CHK_DATA : slbit  := '0';
  signal N_REF_DATA : slv32 := (others=>'0');
  signal N_REF_ADDR : slv17 := (others=>'0');
  signal R_CHK_DATA_AL : slbit  := '0';
  signal R_REF_DATA_AL : slv32 := (others=>'0');
  signal R_REF_ADDR_AL : slv17 := (others=>'0');
  signal R_CHK_DATA_DL : slbit  := '0';
  signal R_REF_DATA_DL : slv32 := (others=>'0');
  signal R_REF_ADDR_DL : slv17 := (others=>'0');
  
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

  MEM : entity work.is61wv5128bll
    port map (
      CE_N => O_MEM_CE_N,
      OE_N => O_MEM_OE_N,
      WE_N => O_MEM_WE_N,
      ADDR => O_MEM_ADDR,
      DATA => IO_MEM_DATA
    );

  UUT : c7_sram_memctl
    port map (
      CLK     => CLK,
      RESET   => RESET,
      REQ     => REQ,
      WE      => WE,
      BUSY    => BUSY,
      ACK_R   => ACK_R,
      ACK_W   => ACK_W,
      ACT_R   => ACT_R,
      ACT_W   => ACT_W,
      ADDR    => ADDR,
      BE      => BE,
      DI      => DI,
      DO      => DO,
      O_MEM_CE_N  => O_MEM_CE_N,
      O_MEM_WE_N  => O_MEM_WE_N,
      O_MEM_OE_N  => O_MEM_OE_N,
      O_MEM_ADDR  => O_MEM_ADDR,
      IO_MEM_DATA => IO_MEM_DATA
    );

  proc_stim: process
    file fstim : text open read_mode is "tb_c7_sram_memctl_stim";
    variable iline : line;
    variable oline : line;
    variable ok : boolean;
    variable dname : string(1 to 6) := (others=>' ');
    variable idelta : integer := 0;
    variable iaddr : slv17 := (others=>'0');
    variable idata : slv32 := (others=>'0');
    variable ibe   : slv4 := (others=>'0');
    variable ival  : slbit := '0';
    variable nbusy : integer := 0;

  begin
    
    wait for clock_offset - setup_time;

    file_loop: while not endfile(fstim) loop

      readline (fstim, iline);
      
      readcomment(iline, ok);
      next file_loop when ok;

      readword(iline, dname, ok);
      if ok then
        case dname is
          when ".memon" =>              -- .memon
            read_ea(iline, ival);
            R_MEMON <= ival;
            wait for 2*clock_period;
            
          when ".reset" =>              -- .reset 
            write(oline, string'(".reset"));
            writeline(output, oline);
            RESET <= '1';
            wait for clock_period;
            RESET <= '0';
            wait for 9*clock_period;

          when ".wait " =>              -- .wait
            read_ea(iline, idelta);
            wait for idelta*clock_period;
            
          when "read  " =>              -- read
            readgen_ea(iline, iaddr, 16);
            readgen_ea(iline, idata, 16);
            ADDR <= iaddr;
            REQ <= '1';
            WE  <= '0';

            writetimestamp(oline, CLK_CYCLE, ": stim read ");
            writegen(oline, iaddr, right, 6, 16);
            write(oline, string'("     "));
            writegen(oline, idata, right, 9, 16);

            wait for clock_period;
            REQ <= '0';            

            N_CHK_DATA <= '1', '0' after clock_period;
            N_REF_DATA <= idata;
            N_REF_ADDR <= iaddr;
 
            nbusy := 0;
            while BUSY = '1' loop
              nbusy := nbusy + 1;
              wait for clock_period;
            end loop;

            write(oline, string'("  nbusy="));
            write(oline, nbusy, right, 2);
            writeline(output, oline);

          when "write " =>              -- write
            readgen_ea(iline, iaddr, 16);
            read_ea(iline, ibe);
            readgen_ea(iline, idata, 16);
            ADDR <= iaddr;
            BE   <= ibe;
            DI   <= idata;
            REQ  <= '1';
            WE   <= '1';
            
            writetimestamp(oline, CLK_CYCLE, ": stim write");
            writegen(oline, iaddr, right, 6, 16);
            writegen(oline, ibe  , right, 5,  2);
            writegen(oline, idata, right, 9, 16);

            wait for clock_period;
            REQ <= '0';            
            WE  <= '0';

            nbusy := 0;
            while BUSY = '1' loop
              nbusy := nbusy + 1;
              wait for clock_period;
            end loop;

            write(oline, string'("  nbusy="));
            write(oline, nbusy, right, 2);
            writeline(output, oline);


          when others =>                -- bad directive
            write(oline, string'("?? unknown directive: "));
            write(oline, dname);
            writeline(output, oline);
            report "aborting" severity failure;
        end case;
      else
        report "failed to find command" severity failure;
        
      end if;

      testempty_ea(iline);

    end loop; -- file fstim

    wait for 10*clock_period;

    writetimestamp(oline, CLK_CYCLE, ": DONE ");
    writeline(output, oline);

    CLK_STOP <= '1';

    wait;                               -- suspend proc_stim forever
                                        -- clock is stopped, sim will end

  end process proc_stim;

  
  proc_moni: process
    variable oline : line;
  begin

    loop 
      wait until rising_edge(CLK);

      if ACK_R = '1' then
        writetimestamp(oline, CLK_CYCLE, ": moni ");
        writegen(oline, DO, right, 9, 16);
        if R_CHK_DATA_DL = '1' then
          write(oline, string'("  CHECK"));
          if R_REF_DATA_DL = DO then
            write(oline, string'(" OK"));
          else
            write(oline, string'(" FAIL, exp="));
            writegen(oline, R_REF_DATA_DL, right, 9, 16);
            write(oline, string'(" for a="));
            writegen(oline, R_REF_ADDR_DL, right, 5, 16);
          end if;
          R_CHK_DATA_DL <= '0';
        end if;
        writeline(output, oline);
      end if;

      if R_CHK_DATA_AL = '1' then
        R_CHK_DATA_DL <= R_CHK_DATA_AL;
        R_REF_DATA_DL <= R_REF_DATA_AL;
        R_REF_ADDR_DL <= R_REF_ADDR_AL;
        R_CHK_DATA_AL <= '0';
      end if;
      if N_CHK_DATA = '1' then
        R_CHK_DATA_AL <= N_CHK_DATA;
        R_REF_DATA_AL <= N_REF_DATA;
        R_REF_ADDR_AL <= N_REF_ADDR;
      end if;
      
    end loop;
    
  end process proc_moni;


  proc_memon: process
    variable oline : line;
  begin

    loop 
      wait until rising_edge(CLK);

      if R_MEMON = '1' then
        writetimestamp(oline, CLK_CYCLE, ": mem  ");
        write(oline, string'(" ce="));
        write(oline, not O_MEM_CE_N, right, 2);
        write(oline, string'(" we="));
        write(oline, not O_MEM_WE_N, right);
        write(oline, string'(" oe="));
        write(oline, not O_MEM_OE_N, right);
        write(oline, string'(" a="));
        writegen(oline, O_MEM_ADDR, right, 5, 16);
        write(oline, string'(" d="));
        writegen(oline, IO_MEM_DATA, right, 8, 16);
        writeline(output, oline);
      end if;
      
    end loop;
    
  end process proc_memon;


end sim;
