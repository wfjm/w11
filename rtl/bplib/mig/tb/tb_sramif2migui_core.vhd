-- $Id: tb_sramif2migui_core.vhd 1181 2019-07-08 17:00:50Z mueller $
-- SPDX-License-Identifier: GPL-3.0-or-later
-- Copyright 2018- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
--
------------------------------------------------------------------------------
-- Module Name:    tb_sramif2migui_core - sim
-- Description:    Test bench for sramif2migui_core and migui_core_gsim
--
-- Dependencies:   vlib/simlib/simclk
--                 vlib/simlib/simclkcnt
--                 migui_core_gsim
--                 sramif2migui_core
--                 migui_core_gsim
--                 migui2bram
--
-- To test:        sramif2migui_core
--
-- Target Devices: generic
-- Tool versions:  viv 2017.2; ghdl 0.34
-- Revision History: 
-- Date         Rev Version  Comment
-- 2018-12-25  1093   1.0    Initial version
-- 2018-11-10  1067   0.1    First draft (derived fr tb_nx_cram_memctl.vhd)
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;
use std.textio.all;

use work.slvtypes.all;
use work.simlib.all;
use work.miglib.all;
use work.sys_conf.all;

entity tb_sramif2migui_core is
end tb_sramif2migui_core;

architecture sim of tb_sramif2migui_core is
 
  constant clkmui_mul : positive :=  6;
  constant clkmui_div : positive := 12;
  
  constant c_caco_wait : positive  := 50; -- UI_CLK cycles till CALIB_COMP = 1

  constant mwidth : positive  := 2**sys_conf_bawidth; -- mask width (8 or 16)
  constant dwidth : positive  := 8*mwidth;            -- data width (64 or 128)

  signal CLK     : slbit := '0';
  signal RESET   : slbit := '0';
  signal REQ     : slbit := '0';
  signal WE      : slbit := '0';
  signal BUSY    : slbit := '0';
  signal ACK_R   : slbit := '0';
  signal ACK_W   : slbit := '0';
  signal ACT_R   : slbit := '0';
  signal ACT_W   : slbit := '0';
  signal ADDR    : slv20 := (others=>'0');
  signal BE : slv4  := (others=>'0');
  signal DI : slv32 := (others=>'0');
  signal DO : slv32 := (others=>'0');
  signal MONI : sramif2migui_moni_type := sramif2migui_moni_init;

  signal SYS_CLK : slbit := '0';
  signal SYS_RST : slbit := '0';

  signal UI_CLK              : slbit := '0';
  signal UI_CLK_SYNC_RST     : slbit := '0';
  signal INIT_CALIB_COMPLETE : slbit := '0';
  signal APP_RDY             : slbit := '0';
  signal APP_EN              : slbit := '0';
  signal APP_CMD             : slv3:= (others=>'0');
  signal APP_ADDR            : slv(sys_conf_mawidth-1 downto 0):= (others=>'0');
  signal APP_WDF_RDY         : slbit := '0';
  signal APP_WDF_WREN        : slbit := '0';
  signal APP_WDF_DATA        : slv(dwidth-1 downto 0):= (others=>'0');
  signal APP_WDF_MASK        : slv(mwidth-1 downto 0):= (others=>'0');
  signal APP_WDF_END         : slbit := '0';
  signal APP_RD_DATA_VALID   : slbit := '0';
  signal APP_RD_DATA         : slv(dwidth-1 downto 0):= (others=>'0');
  signal APP_RD_DATA_END     : slbit := '0';

  signal R_MEMON : slbit    := '0';
  signal N_CHK_DATA : slbit := '0';
  signal N_REF_DATA : slv32 := (others=>'0');
  signal N_REF_ADDR : slv20 := (others=>'0');
  signal R_CHK_DATA_AL : slbit := '0';
  signal R_REF_DATA_AL : slv32 := (others=>'0');
  signal R_REF_ADDR_AL : slv20 := (others=>'0');
  signal R_CHK_DATA_DL : slbit := '0';
  signal R_REF_DATA_DL : slv32 := (others=>'0');
  signal R_REF_ADDR_DL : slv20 := (others=>'0');
  
  signal R_NRDRHIT   : integer := 0;
  signal R_NWRRHIT   : integer := 0;
  signal R_NWRFLUSH  : integer := 0;
  signal R_NMIGCBUSY : integer := 0;
  signal R_NMIGWBUSY : integer := 0;
  signal R_NMIGCACOW : integer := 0;

  signal CLK_STOP : slbit := '0';
  signal CLK_CYCLE : integer := 0;
  signal UI_CLK_CYCLE : integer := 0;

  constant clock_period : Delay_length :=  12.5 ns;
  constant clock_offset : Delay_length := 200 ns;
  constant setup_time : Delay_length :=  3 ns;
  constant c2out_time : Delay_length :=  5 ns;
  
  constant sysclock_period : Delay_length := 5.833 ns;
  constant sysclock_offset : Delay_length := 200 ns;

begin

  USRCLKGEN : simclk
    generic map (
      PERIOD => clock_period,
      OFFSET => clock_offset)
    port map (
      CLK      => CLK,
      CLK_STOP => CLK_STOP
    );

  SYSCLKGEN : simclk
    generic map (
      PERIOD => sysclock_period,
      OFFSET => sysclock_offset)
    port map (
      CLK      => SYS_CLK,
      CLK_STOP => CLK_STOP
    );

  CLKCNT   : simclkcnt port map (CLK => CLK,    CLK_CYCLE => CLK_CYCLE);
  UICLKCNT : simclkcnt port map (CLK => UI_CLK, CLK_CYCLE => UI_CLK_CYCLE);

  SR2MU : sramif2migui_core
    generic map (
      BAWIDTH => sys_conf_bawidth,
      MAWIDTH => sys_conf_mawidth)
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
      MONI    => MONI,
      UI_CLK              => UI_CLK,
      UI_CLK_SYNC_RST     => UI_CLK_SYNC_RST,
      INIT_CALIB_COMPLETE => INIT_CALIB_COMPLETE,
      APP_RDY             => APP_RDY,
      APP_EN              => APP_EN,
      APP_CMD             => APP_CMD,
      APP_ADDR            => APP_ADDR,
      APP_WDF_RDY         => APP_WDF_RDY,
      APP_WDF_WREN        => APP_WDF_WREN,
      APP_WDF_DATA        => APP_WDF_DATA,
      APP_WDF_MASK        => APP_WDF_MASK,
      APP_WDF_END         => APP_WDF_END,
      APP_RD_DATA_VALID   => APP_RD_DATA_VALID,
      APP_RD_DATA         => APP_RD_DATA,
      APP_RD_DATA_END     => APP_RD_DATA_END
     );

  BTYP_MSIM : if sys_conf_btyp = c_btyp_msim generate
    I0 : migui_core_gsim
      generic map (
        BAWIDTH    => sys_conf_bawidth,
        MAWIDTH    => sys_conf_mawidth,
        SAWIDTH    => sys_conf_sawidth,
        CLKMUI_MUL => clkmui_mul,
        CLKMUI_DIV => clkmui_div)
      port map (
        SYS_CLK             => SYS_CLK,
        SYS_RST             => SYS_RST,
        UI_CLK              => UI_CLK,
        UI_CLK_SYNC_RST     => UI_CLK_SYNC_RST,
        INIT_CALIB_COMPLETE => INIT_CALIB_COMPLETE,
        APP_RDY             => APP_RDY,
        APP_EN              => APP_EN,
        APP_CMD             => APP_CMD,
        APP_ADDR            => APP_ADDR,
        APP_WDF_RDY         => APP_WDF_RDY,
        APP_WDF_WREN        => APP_WDF_WREN,
        APP_WDF_DATA        => APP_WDF_DATA,
        APP_WDF_MASK        => APP_WDF_MASK,
        APP_WDF_END         => APP_WDF_END,
        APP_RD_DATA_VALID   => APP_RD_DATA_VALID,
        APP_RD_DATA         => APP_RD_DATA,
        APP_RD_DATA_END     => APP_RD_DATA_END,
        APP_REF_REQ         => '0',
        APP_ZQ_REQ          => '0',
        APP_REF_ACK         => open,
        APP_ZQ_ACK          => open
      );
  end generate BTYP_MSIM;

  BTYP_BRAM : if sys_conf_btyp = c_btyp_bram generate
    I0 : migui2bram
      generic map (
        BAWIDTH    => sys_conf_bawidth,
        MAWIDTH    => sys_conf_mawidth,
        RAWIDTH    => sys_conf_rawidth,
        RDELAY     => sys_conf_rdelay,
        CLKMUI_MUL => clkmui_mul,
        CLKMUI_DIV => clkmui_div,
        CLKMSYS_PERIOD => 6.000)
      port map (
        SYS_CLK             => SYS_CLK,
        SYS_RST             => SYS_RST,
        UI_CLK              => UI_CLK,
        UI_CLK_SYNC_RST     => UI_CLK_SYNC_RST,
        INIT_CALIB_COMPLETE => INIT_CALIB_COMPLETE,
        APP_RDY             => APP_RDY,
        APP_EN              => APP_EN,
        APP_CMD             => APP_CMD,
        APP_ADDR            => APP_ADDR,
        APP_WDF_RDY         => APP_WDF_RDY,
        APP_WDF_WREN        => APP_WDF_WREN,
        APP_WDF_DATA        => APP_WDF_DATA,
        APP_WDF_MASK        => APP_WDF_MASK,
        APP_WDF_END         => APP_WDF_END,
        APP_RD_DATA_VALID   => APP_RD_DATA_VALID,
        APP_RD_DATA         => APP_RD_DATA,
        APP_RD_DATA_END     => APP_RD_DATA_END
      );
  end generate BTYP_BRAM;  
  
  proc_stim: process
    file fstim : text open read_mode is "tb_sramif2migui_core_stim";
    variable iline : line;
    variable oline : line;
    variable ok : boolean;
    variable dname : string(1 to 6) := (others=>' ');
    variable idelta : integer := 0;
    variable iaddr : slv20 := (others=>'0');
    variable idata : slv32 := (others=>'0');
    variable ibe   : slv4 := (others=>'0');
    variable ival  : slbit := '0';
    variable nbusy : integer := 0;
    variable nwreq : natural := 0;
    variable nrdrhit   : integer := 0;
    variable nwrrhit   : integer := 0;
    variable nwrflush  : integer := 0;
    variable nmigcbusy : integer := 0;
    variable nmigwbusy : integer := 0;
    variable nmigcacow : integer := 0;

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

          when ".wreq " =>              -- .wreq
            read_ea(iline, nwreq);
            
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

            nbusy := 0;
            while BUSY = '1' loop
              nbusy := nbusy + 1;
              wait for clock_period;
            end loop;

            write(oline, string'("  nb="));
            write(oline, nbusy, right, 2);
            write(oline, string'(" mo="));
            write(oline, R_NRDRHIT-nrdrhit, right, 2);
            write(oline, R_NWRRHIT-nwrrhit, right, 2);
            write(oline, R_NWRFLUSH-nwrflush, right, 2);
            write(oline, R_NMIGCBUSY-nmigcbusy, right, 2);
            write(oline, R_NMIGWBUSY-nmigwbusy, right, 2);
            write(oline, string'(" "));
            write(oline, R_NMIGCACOW-nmigcacow, right, 1);
            writeline(output, oline);
            nrdrhit   := R_NRDRHIT;
            nwrrhit   := R_NWRRHIT;
            nwrflush  := R_NWRFLUSH;
            nmigcbusy := R_NMIGCBUSY;
            nmigwbusy := R_NMIGWBUSY;
            nmigcacow := R_NMIGCACOW;
            
            N_CHK_DATA <= '1', '0' after clock_period;
            N_REF_DATA <= idata;
            N_REF_ADDR <= iaddr;

            wait for clock_period;
            REQ <= '0';
            if nwreq > 0 then wait for nwreq*clock_period; end if;
            
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

            nbusy := 0;
            while BUSY = '1' loop
              nbusy := nbusy + 1;
              wait for clock_period;
            end loop;

            write(oline, string'("  nb="));
            write(oline, nbusy, right, 2);
            write(oline, string'(" mo="));
            write(oline, R_NRDRHIT-nrdrhit, right, 2);
            write(oline, R_NWRRHIT-nwrrhit, right, 2);
            write(oline, R_NWRFLUSH-nwrflush, right, 2);
            write(oline, R_NMIGCBUSY-nmigcbusy, right, 2);
            write(oline, R_NMIGWBUSY-nmigwbusy, right, 2);
            write(oline, string'(" "));
            write(oline, R_NMIGCACOW-nmigcacow, right, 1);
            writeline(output, oline);
            nrdrhit   := R_NRDRHIT;
            nwrrhit   := R_NWRRHIT;
            nwrflush  := R_NWRFLUSH;
            nmigcbusy := R_NMIGCBUSY;
            nmigwbusy := R_NMIGWBUSY;
            nmigcacow := R_NMIGCACOW;

            wait for clock_period;
            REQ <= '0';            
            if nwreq > 0 then wait for nwreq*clock_period; end if;
            
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

    writetimestamp(oline, CLK_CYCLE, ": stat moni-cnt= ");
    write(oline, R_NRDRHIT, right, 5);
    write(oline, string'(","));
    write(oline, R_NWRRHIT, right, 5);
    write(oline, string'(","));
    write(oline, R_NWRFLUSH, right, 5);
    write(oline, string'(","));
    write(oline, R_NMIGCBUSY, right, 5);
    write(oline, string'(","));
    write(oline, R_NMIGWBUSY, right, 5);
    write(oline, string'(","));
    write(oline, R_NMIGCACOW, right, 5);
    writeline(output, oline);
    
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

      -- performance counter
      if MONI.rdrhit = '1' then
        R_NRDRHIT <= R_NRDRHIT + 1;
      end if;
      if MONI.wrrhit = '1' then
        R_NWRRHIT <= R_NWRRHIT + 1;
      end if;
      if MONI.wrflush = '1' then
        R_NWRFLUSH <= R_NWRFLUSH + 1;
      end if;
      if MONI.migcbusy = '1' then
        R_NMIGCBUSY <= R_NMIGCBUSY + 1;
      end if;
      if MONI.migwbusy = '1' then
        R_NMIGWBUSY <= R_NMIGWBUSY + 1;
      end if;
      if MONI.migcacow = '1' then
        R_NMIGCACOW <= R_NMIGCACOW + 1;
      end if;
      
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
      wait until rising_edge(UI_CLK);

      if R_MEMON = '1' then
        if APP_EN = '1' then
          writetimestamp(oline, UI_CLK_CYCLE, ": mreq ");
          write(oline, APP_CMD, right, 3);
          write(oline, string'(","));
          write(oline, APP_RDY, right);
          write(oline, string'(","));
          write(oline, APP_WDF_RDY, right);
          writegen(oline,
                   APP_ADDR(sys_conf_sawidth-sys_conf_bawidth-1 downto 0),
                   right, 7, 16);
          write(oline, APP_WDF_WREN, right, 2);
          write(oline, APP_WDF_END, right, 2);
          if APP_WDF_WREN = '1' then
            writegen(oline, APP_WDF_MASK, right, (mwidth/4)+1, 16);
            writegen(oline, APP_WDF_DATA, right, (dwidth/4)+1, 16);
          end if;
          writeline(output, oline);
        end if;

        if APP_RD_DATA_VALID = '1' then
          writetimestamp(oline, UI_CLK_CYCLE, ": mres ");
          write(oline, APP_RD_DATA_END, right);
          writegen(oline, APP_RD_DATA, right, (dwidth/4)+1, 16);
          writeline(output, oline);
        end if;

      end if;
      
    end loop;
    
  end process proc_memon;


end sim;
