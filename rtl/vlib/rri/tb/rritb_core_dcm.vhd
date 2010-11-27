-- $Id: rritb_core_dcm.vhd 339 2010-11-22 21:20:51Z mueller $
--
-- Copyright 2010- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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
-- Module Name:    rritb_core_dcm - sim
-- Description:    DCM aware core for a rri and cext based test bench
--
-- Dependencies:   simlib/simclk
--                 simlib/simclkcnt
--
-- To test:        generic, any rri/cext based target
--
-- Target Devices: generic
-- Tool versions:  11.4-12.1; ghdl 0.26-0.29
--
-- Revision History: 
-- Date         Rev Version  Comment
-- 2010-11-13   338   1.1    First DCM aware version, cloned from rritb_core
-- 2010-06-05   301   1.1.2  renamed .rpmon -> .rbmon
-- 2010-05-02   287   1.1.1  rename config command .sdata -> .sinit;
--                           use sbcntl_sbf_(cp|rp)mon defs, use rritblib;
-- 2010-04-25   283   1.1    new clk handling in proc_stim, wait period-setup
-- 2010-04-24   282   1.0    Initial version (from vlib/s3board/tb/tb_s3board)
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_textio.all;
use std.textio.all;

use work.slvtypes.all;
use work.simlib.all;
use work.simbus.all;
use work.rritblib.all;
use work.vhpi_rriext.all;

entity rritb_core_dcm is                -- dcm aware core of rri/cext based tb's
  generic (
    CLKOSC_PERIOD : time :=  20 ns;     -- clock osc period
    CLKOSC_OFFSET : time := 200 ns;     -- clock osc offset (time to start clk)
    SETUP_TIME : time :=   5 ns;        -- setup time
    C2OUT_TIME : time :=  10 ns);       -- clock to output time
  port (
    CLKOSC : out slbit;                 -- clock osc
    CLKSYS : in slbit;                  -- DCM derived system clock
    RX_DATA : out slv8;                 -- read data         (data ext->tb)
    RX_VAL : out slbit;                 -- read data valid   (data ext->tb)
    RX_HOLD : in slbit;                 -- read data hold    (data ext->tb)
    TX_DATA : in slv8;                  -- write data        (data tb->ext)
    TX_ENA : in slbit                   -- write data enable (data tb->ext)
  );
end rritb_core_dcm;

architecture sim of rritb_core_dcm is

  signal CLK_STOP : slbit := '0';
  
begin

  CLKGEN : simclk
    generic map (
      PERIOD => CLKOSC_PERIOD,
      OFFSET => CLKOSC_OFFSET)
    port map (
      CLK       => CLKOSC,
      CLK_CYCLE => open,
      CLK_STOP  => CLK_STOP
    );

  CLKCNT : simclkcnt
    port map (
      CLK       => CLKSYS,
      CLK_CYCLE => SB_CLKCYCLE
    );
  
  proc_conf: process
    file fconf : text open read_mode is "tb_rriext_conf";
    variable iline : line;
    variable oline : line;
    variable ok : boolean;
    variable dname : string(1 to 6) := (others=>' ');
    variable ien : slbit := '0';
    variable ibit : integer := 0;
    variable iaddr : slv8 := (others=>'0');
    variable idata : slv16 := (others=>'0');
  begin
    
    SB_CNTL <= (others=>'L');
    SB_VAL  <= 'L';
    SB_ADDR <= (others=>'L');
    SB_DATA <= (others=>'L');
  
    file_loop: while not endfile(fconf) loop
      
      readline (fconf, iline);
      readcomment(iline, ok);
      next file_loop when ok;
      readword(iline, dname, ok);
      
      if ok then
        case dname is

          when ".scntl" =>              -- .scntl
            read_ea(iline, ibit);
            read_ea(iline, ien);
            assert (ibit>=SB_CNTL'low and ibit<=SB_CNTL'high)
              report "assert bit number in range of SB_CNTL"
              severity failure;
            if ien = '1' then
              SB_CNTL(ibit) <= 'H';
            else
              SB_CNTL(ibit) <= 'L';
            end if;

          when ".cpmon" =>              -- .cpmon
            read_ea(iline, ien);
            if ien = '1' then
              SB_CNTL(sbcntl_sbf_cpmon) <= 'H';
            else
              SB_CNTL(sbcntl_sbf_cpmon) <= 'L';
            end if;

          when ".rbmon" =>              -- .rbmon
            read_ea(iline, ien);
            if ien = '1' then
              SB_CNTL(sbcntl_sbf_rbmon) <= 'H';
            else
              SB_CNTL(sbcntl_sbf_rbmon) <= 'L';
            end if;

          when ".sinit" =>              -- .sinit
            readgen_ea(iline, iaddr, 8);
            readgen_ea(iline, idata, 8);
            SB_ADDR <= iaddr;
            SB_DATA <= idata;
            SB_VAL  <= 'H';
            wait for 0 ns;
            SB_VAL  <= 'L';
            SB_ADDR <= (others=>'L');
            SB_DATA <= (others=>'L');
            wait for 0 ns;

          when others =>                -- bad command
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

    wait;     -- halt process here 
    
  end process proc_conf;
    
  proc_stim: process
    variable t_lastclksys : time := 0 ns;
    variable clksys_period : time := 0 ns;
    variable icycle : integer := 0;
    variable irxint : integer := 0;
    variable irxslv : slv24 := (others=>'0');
    variable ibit : integer := 0;
    variable oline : line;
    variable r_sb_cntl : slv16 := (others=>'Z');
    variable iaddr : slv8 := (others=>'0');
    variable idata : slv16 := (others=>'0');
  begin

    -- just wait for 10 CLKSYS cycles
    for i in 1 to 10 loop
      wait until CLKSYS'event and CLKSYS='1';
      clksys_period := now - t_lastclksys;
      t_lastclksys  := now;
    end loop;  -- i
    
    stim_loop: loop
      
      wait until CLKSYS'event and CLKSYS='1';
      clksys_period := now - t_lastclksys;
      t_lastclksys  := now;
      
      wait for clksys_period-SETUP_TIME;

      SB_ADDR <= (others=>'Z');
      SB_DATA <= (others=>'Z');

      icycle := conv_integer(unsigned(SB_CLKCYCLE));
      RX_VAL <= '0';

      if RX_HOLD = '0'  then
        irxint := cext_getbyte(icycle);
        if irxint >= 0 then
          if irxint <= 16#ff# then      -- normal data byte
            RX_DATA <= conv_std_logic_vector(irxint, 8);
            RX_VAL  <= '1';
          elsif irxint >= 16#1000000# then  -- out-of-band message
            irxslv := conv_std_logic_vector(irxint, 24);
            iaddr := irxslv(23 downto 16);
            idata := irxslv(15 downto  0);
            writetimestamp(oline, SB_CLKCYCLE, ": OOB-MSG");
            write(oline, irxslv(23 downto 16), right, 9);
            write(oline, irxslv(15 downto  8), right, 9);
            write(oline, irxslv( 7 downto  0), right, 9);
            write(oline, string'(" : "));
            writeoct(oline, iaddr, right, 3);
            writeoct(oline, idata, right, 7);
            writeline(output, oline);
            if unsigned(iaddr) = 0 then
              ibit := conv_integer(unsigned(idata(15 downto 8)));
              r_sb_cntl(ibit) := idata(0);
            else
              SB_ADDR <= iaddr;
              SB_DATA <= idata;
              SB_VAL  <= '1';
              wait for 0 ns;
              SB_VAL  <= 'Z';
              wait for 0 ns;
            end if;
          end if;
        elsif irxint = -1 then           -- end-of-file seen
          exit stim_loop;
        else
          report "cext_getbyte error: " & integer'image(-irxint)
            severity failure;
        end if;
      end if;
      
      SB_CNTL <= r_sb_cntl;
      
    end loop;
    
    -- just wait for 50 CLKSYS cycles
    for i in 1 to 50 loop
      wait until CLKSYS'event and CLKSYS='1';
    end loop;  -- i    
    CLK_STOP <= '1';
    
    writetimestamp(oline, SB_CLKCYCLE, ": DONE ");
    writeline(output, oline);

    wait;                               -- suspend proc_stim forever
                                        -- clock is stopped, sim will end

  end process proc_stim;

  proc_moni: process
    variable itxdata : integer := 0;
    variable itxrc : integer := 0;
    variable oline : line;
  begin
    
    loop
      wait until CLKSYS'event and CLKSYS='1';
      wait for C2OUT_TIME;
      if TX_ENA = '1' then
        itxdata := conv_integer(unsigned(TX_DATA));
        itxrc := cext_putbyte(itxdata);
        assert itxrc=0
          report "cext_putbyte error: "  & integer'image(itxrc)
          severity failure;
      end if;

    end loop;
    
  end process proc_moni;

end sim;
