-- $Id: tbcore_rlink.vhd 1181 2019-07-08 17:00:50Z mueller $
-- SPDX-License-Identifier: GPL-3.0-or-later
-- Copyright 2010-2018 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
-- 
------------------------------------------------------------------------------
-- Module Name:    tbcore_rlink - sim
-- Description:    Core for a rlink_cext based test bench
--
-- Dependencies:   simlib/simclkcnt
--                 rlink_cext_iface
--
-- To test:        generic, any rlink_cext based target
--
-- Target Devices: generic
-- Tool versions:  ghdl 0.26-0.34
-- Revision History: 
-- Date         Rev Version  Comment
-- 2018-11-25  1074   3.3    wait 40 cycles after CONF_DONE
-- 2016-09-17   807   3.2.2  conf: .sinit -> .sdata; finite length SB_VAL pulse
-- 2016-09-02   805   3.2.1  conf: add .wait and CONF_DONE; drop CLK_STOP
-- 2016-02-07   729   3.2    use rlink_cext_iface (allow VHPI and DPI backend)
-- 2015-11-01   712   3.1.3  proc_stim: drive SB_CNTL from start to avoid 'U'
-- 2013-01-04   469   3.1.2  use 1ns wait for .sinit to allow simbus debugging
-- 2011-12-25   445   3.1.1  add SB_ init drivers to avoid SB_VAL='U' at start
-- 2011-12-23   444   3.1    redo clock handling, remove simclk, CLK now input
-- 2011-11-19   427   3.0.1  now numeric_std clean
-- 2010-12-29   351   3.0    rename rritb_core->tbcore_rlink; use rbv3 naming
-- 2010-06-05   301   1.1.2  rename .rpmon -> .rbmon
-- 2010-05-02   287   1.1.1  rename config command .sdata -> .sinit;
--                           use sbcntl_sbf_(cp|rp)mon defs, use rritblib;
-- 2010-04-25   283   1.1    new clk handling in proc_stim, wait period-setup
-- 2010-04-24   282   1.0    Initial version (from vlib/s3board/tb/tb_s3board)
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;
use std.textio.all;

use work.slvtypes.all;
use work.simlib.all;
use work.simbus.all;
use work.rblib.all;
use work.rlinklib.all;

entity tbcore_rlink is                  -- core of rlink_cext based test bench
  port (
    CLK : in slbit;                     -- control interface clock
    RX_DATA : out slv8;                 -- read data         (data ext->tb)
    RX_VAL : out slbit;                 -- read data valid   (data ext->tb)
    RX_HOLD : in slbit;                 -- read data hold    (data ext->tb)
    TX_DATA : in slv8;                  -- write data        (data tb->ext)
    TX_ENA : in slbit                   -- write data enable (data tb->ext)
  );
end tbcore_rlink;

architecture sim of tbcore_rlink is
  
  signal CLK_CYCLE   : integer := 0;
  signal CEXT_CYCLE  : slv32   := (others=>'0');
  signal CEXT_RXDATA : slv32   := (others=>'0');
  signal CEXT_RXVAL  : slbit   := '0';
  signal CEXT_RXHOLD : slbit   := '1';
  signal CONF_DONE   : slbit   := '0';

begin
  
  CLKCNT : simclkcnt port map (CLK => CLK, CLK_CYCLE => CLK_CYCLE);

  CEXT_IFACE : entity work.rlink_cext_iface
  port map (
    CLK       => CLK,
    CLK_CYCLE => CEXT_CYCLE,
    RX_DATA   => CEXT_RXDATA,
    RX_VAL    => CEXT_RXVAL,
    RX_HOLD   => CEXT_RXHOLD,
    TX_DATA   => TX_DATA,
    TX_ENA    => TX_ENA
  );
  
  CEXT_CYCLE <= slv(to_signed(CLK_CYCLE,32));

  proc_conf: process
    file fconf : text open read_mode is "rlink_cext_conf";
    variable iline : line;
    variable oline : line;
    variable ok : boolean;
    variable dname : string(1 to 6) := (others=>' ');
    variable ien : slbit := '0';
    variable ibit : integer := 0;
    variable twait : Delay_length := 0 ns;
    variable iaddr : slv8 := (others=>'0');
    variable idata : slv16 := (others=>'0');
  begin

    CONF_DONE  <= '0';
    SB_SIMSTOP <= 'L';
    
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
            wait for 1 ns;
            if ien = '1' then
              SB_CNTL(ibit) <= 'H';
            else
              SB_CNTL(ibit) <= 'L';
            end if;

          when ".rlmon" =>              -- .rlmon
            read_ea(iline, ien);
            wait for 1 ns;
            if ien = '1' then
              SB_CNTL(sbcntl_sbf_rlmon) <= 'H';
            else
              SB_CNTL(sbcntl_sbf_rlmon) <= 'L';
            end if;

          when ".rbmon" =>              -- .rbmon
            read_ea(iline, ien);
            wait for 1 ns;
            if ien = '1' then
              SB_CNTL(sbcntl_sbf_rbmon) <= 'H';
            else
              SB_CNTL(sbcntl_sbf_rbmon) <= 'L';
            end if;

          when ".sdata" =>              -- .sdata
            readgen_ea(iline, iaddr, 16);
            readgen_ea(iline, idata, 16);
            wait for 1 ns;
            SB_ADDR <= iaddr;
            SB_DATA <= idata;
            SB_VAL  <= 'H';
            wait for 1 ns;
            SB_VAL  <= 'L';
            SB_ADDR <= (others=>'L');
            SB_DATA <= (others=>'L');

          when ".wait " =>              -- .wait
            read_ea(iline, twait);
            wait for twait;
            
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

    SB_VAL  <= 'L';
    SB_ADDR <= (others=>'L');
    SB_DATA <= (others=>'L');

    CONF_DONE  <= '1';

    wait;     -- halt process here 
    
  end process proc_conf;
    
  proc_stim: process
    variable irxint : integer := 0;
    variable irxslv : slv24 := (others=>'0');
    variable ibit : integer := 0;
    variable oline : line;
    variable r_sb_cntl : slv16 := (others=>'Z');
    variable iaddr : slv8 := (others=>'0');
    variable idata : slv16 := (others=>'0');
  begin

    -- setup init values for all output ports
    RX_DATA  <= (others=>'0');
    RX_VAL   <= '0';

    SB_VAL  <= 'Z';
    SB_ADDR <= (others=>'Z');
    SB_DATA <= (others=>'Z');
    SB_CNTL <= (others=>'Z');

    CEXT_RXHOLD <= '1';
      
    -- wait for CONF_DONE, plus addional 40 clock cycles (conf+design run up)
    while CONF_DONE = '0' loop
      wait until rising_edge(CLK);      
    end loop;
    for i in 0 to 39 loop
      wait until rising_edge(CLK);
    end loop;  -- i
    
    writetimestamp(oline, CLK_CYCLE, ": START");
    writeline(output, oline);

    stim_loop: loop

      wait until falling_edge(CLK);

      SB_ADDR <= (others=>'Z');
      SB_DATA <= (others=>'Z');

      RX_VAL <= '0';

      CEXT_RXHOLD <= RX_HOLD;

      if RX_HOLD = '0'  then
        irxint := to_integer(signed(CEXT_RXDATA));
        if CEXT_RXVAL = '1' then
          if irxint <= 16#ff# then      -- normal data byte
            RX_DATA <= slv(to_unsigned(irxint, 8));
            RX_VAL  <= '1';
          elsif irxint >= 16#1000000# then  -- out-of-band message
            irxslv := slv(to_unsigned(irxint mod 16#1000000#, 24));
            iaddr := irxslv(23 downto 16);
            idata := irxslv(15 downto  0);
            writetimestamp(oline, CLK_CYCLE, ": OOB-MSG");
            write(oline, irxslv(23 downto 16), right, 9);
            write(oline, irxslv(15 downto  8), right, 9);
            write(oline, irxslv( 7 downto  0), right, 9);
            write(oline, string'(" : "));
            writeoct(oline, iaddr, right, 3);
            writeoct(oline, idata, right, 7);
            writeline(output, oline);
            if unsigned(iaddr) = 0 then
              ibit := to_integer(unsigned(idata(15 downto 8)));
              r_sb_cntl(ibit) := idata(0);
            else
              SB_ADDR <= iaddr;
              SB_DATA <= idata;
              -- In principle a delta cycle long pulse is enough to make the
              -- simbus transfer. A 500 ps long pulse is generated to ensure
              -- that SB_VAL is visible in a viewer. That works up to 1 GHz
              SB_VAL  <= '1';
              wait for 500 ps;
              SB_VAL  <= 'Z';
              wait for 0 ps;
            end if;
          end if;
        elsif irxint = -1 then           -- end-of-file seen
          exit stim_loop;
        else
          report "rlink_cext_getbyte error: " & integer'image(-irxint)
            severity failure;
        end if; -- CEXT_RXVAL = '1'
        
      end if; -- RX_HOLD = '0'
      
      SB_CNTL <= r_sb_cntl;
      
    end loop;
    
    -- wait for 50 clock cycles (design run down)
    for i in 0 to 49 loop
      wait until rising_edge(CLK);
    end loop;  -- i

    writetimestamp(oline, CLK_CYCLE, ": DONE ");
    writeline(output, oline);

    SB_SIMSTOP <= '1';                  -- signal simulation stop
    wait for 100 ns;                    -- monitor grace time
    report "Simulation Finished" severity failure; -- end simulation

  end process proc_stim;

end sim;
