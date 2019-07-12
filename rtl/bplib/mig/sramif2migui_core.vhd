-- $Id: sramif2migui_core.vhd 1181 2019-07-08 17:00:50Z mueller $
-- SPDX-License-Identifier: GPL-3.0-or-later
-- Copyright 2018- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
-- 
------------------------------------------------------------------------------
-- Module Name:    sramif2migui_core - syn
-- Description:    SRAM to MIG interface core
--
-- Dependencies:   memlib/fifo_2c_dram2
--                 cdclib/cdc_signal_s1
-- Test bench:     tb/tb_sramif2migui_core
-- Target Devices: generic
-- Tool versions:  viv 2017.2; ghdl 0.34
--
-- Revision History: 
-- Date         Rev Version  Comment
-- 2018-12-28  1096   1.0    Initial version
-- 2018-11-04  1066   0.1    First draft 
-- 
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.slvtypes.all;
use work.memlib.all;
use work.cdclib.all;
use work.miglib.all;

entity sramif2migui_core is             -- SRAM to MIG interface core
  generic (
    BAWIDTH : positive :=  4;           -- byte address width
    MAWIDTH : positive := 28);          -- memory address width
  port (
    CLK   : in slbit;                   -- clock
    RESET : in slbit;                   -- reset
    REQ   : in slbit;                   -- request
    WE    : in slbit;                   -- write enable
    BUSY  : out slbit;                  -- controller busy
    ACK_R : out slbit;                  -- acknowledge read
    ACK_W : out slbit;                  -- acknowledge write
    ACT_R : out slbit;                  -- signal active read
    ACT_W : out slbit;                  -- signal active write
    ADDR  : in slv20;                   -- address  (32 bit word address)
    BE    : in slv4;                    -- byte enable
    DI    : in slv32;                   -- data in  (memory view)
    DO    : out slv32;                  -- data out (memory view)
    MONI  : out sramif2migui_moni_type; -- monitor signals
    UI_CLK              : in  slbit;    -- MIGUI clock
    UI_CLK_SYNC_RST     : in  slbit;    -- MIGUI reset
    INIT_CALIB_COMPLETE : in slbit;     -- MIGUI calibration done
    APP_RDY             : in  slbit;    -- MIGUI ready for cmd
    APP_EN              : out slbit;    -- MIGUI command enable
    APP_CMD             : out slv3;     -- MIGUI command
    APP_ADDR            : out slv(MAWIDTH-1 downto 0); -- MIGUI address
    APP_WDF_RDY         : in  slbit;    -- MIGUI ready for data write
    APP_WDF_WREN        : out slbit;    -- MIGUI data write enable
    APP_WDF_DATA        : out slv(8*(2**BAWIDTH)-1 downto 0);-- MIGUI write data
    APP_WDF_MASK        : out slv((2**BAWIDTH)-1 downto 0);  -- MIGUI write mask
    APP_WDF_END         : out slbit;                         -- MIGUI write end
    APP_RD_DATA_VALID   : in  slbit;                         -- MIGUI read valid
    APP_RD_DATA         : in  slv(8*(2**BAWIDTH)-1 downto 0);-- MIGUI read data
    APP_RD_DATA_END     : in  slbit                          -- MIGUI read end
  );
end sramif2migui_core;


architecture syn of sramif2migui_core is

  constant mwidth  : positive := 2**BAWIDTH;     -- mask width (8 or 16)
  constant dwidth  : positive := 8*mwidth;       -- data width (64 or 128)
  constant tawidth : positive := 20-(BAWIDTH-2); -- tag address width
  constant rfwidth : positive := dwidth+mwidth+tawidth+1; -- req fifo width
  
  -- sram address fields
  subtype  sa_f_ta  is integer range 20-1 downto BAWIDTH-2; -- tag   addr
  subtype  sa_f_ga  is integer range BAWIDTH-3 downto 0;    -- group addr
  -- mig address fields
  subtype  ma_f_ta  is integer range 22-1 downto BAWIDTH;   -- tag   addr

  -- request fifo data fields
  subtype  rf_f_data     is integer range dwidth+mwidth+tawidth
                                    downto MWIDTH+tawidth+1;
  subtype  rf_f_mask     is integer range mwidth+tawidth downto tawidth+1;
  subtype  rf_f_addr     is integer range tawidth downto 1;
  constant rf_f_we        : integer :=     0;

  constant ngrp : positive := 2**(BAWIDTH-2);   -- # of 32bit groups (2 or 4)
  
  type regs_type is record
    actr     : slbit;                   -- active read flag
    actw     : slbit;                   -- active write flag
    ackr     : slbit;                   -- read acknowledge
    req_addr : slv20;                   -- request address
    req_be   : slv4;                    -- request be
    req_di   : slv32;                   -- request di
    res_do   : slv32;                   -- response do
    rdbuf    : slv(dwidth-1  downto 0); -- read buffer
    rdtag    : slv(tawidth-1 downto 0); -- read tag address
    rdval    : slbit;                   -- read buffer valid
    rdnew    : slbit;                   -- read buffer new
    rdpend   : slbit;                   -- read request pending
    wrbuf    : slv(dwidth-1  downto 0); -- write buffer
    wrtag    : slv(tawidth-1 downto 0); -- write tag address
    wrpend   : slv(mwidth-1 downto 0);  -- write buffer pending flags
  end record regs_type;

  constant bufzero  : slv(dwidth-1  downto 0) := (others=>'0');
  constant tagzero  : slv(tawidth-1 downto 0) := (others=>'0');
  constant pendzero : slv(mwidth-1 downto 0)  := (others=>'0');

  constant regs_init : regs_type := (
    '0','0','0',                        -- actr,actw,ackr
    (others=>'0'),                      -- req_addr
    (others=>'0'),                      -- req_be
    (others=>'0'),                      -- req_di
    (others=>'0'),                      -- res_do
    bufzero,                            -- rdbuf
    tagzero,                            -- rdtag
    '0','0','0',                        -- rdval,rdnew,rdpend
    bufzero,                            -- wrbuf
    tagzero,                            -- wrtag
    pendzero                            -- wrpend
  );

  signal R_REGS : regs_type := regs_init;
  signal N_REGS : regs_type;            -- don't init (vivado fix for fsm infer)
  
  signal REQ_DI   : slv(rfwidth-1 downto 0) := (others=>'0');
  signal REQ_DO   : slv(rfwidth-1 downto 0) := (others=>'0');
  signal REQ_ENA  : slbit := '0';
  signal REQ_VAL  : slbit := '0';
  signal REQ_HOLD : slbit := '0';
  signal REQ_SIZE : slv4  := (others=>'0');
  
  signal RES_DI   : slv(dwidth-1 downto 0) := (others=>'0');
  signal RES_DO   : slv(dwidth-1 downto 0) := (others=>'0');
  signal RES_ENA  : slbit := '0';
  signal RES_VAL  : slbit := '0';
  
  signal APP_RDY_CLK     : slbit := '0';  -- APP_RDY sync'ed to CLK
  signal APP_WDF_RDY_CLK : slbit := '0';  -- APP_WDF_RDY_CLK sync'ed to CLK
  signal MIGUIRST_CLK    : slbit := '0';  -- UI_CLK_SYNC_RST sync'ed to CLK
  signal MIGCACO_CLK     : slbit := '0';  -- INIT_CALIB_COMPLETE sync'ed to CLK

begin
  
  assert BAWIDTH = 3 or BAWIDTH = 4
    report "assert( BAWIDTH = 3 or 4 )"
    severity failure;

  REQFIFO : fifo_2c_dram2               -- request fifo
    generic map (
      AWIDTH => 4,
      DWIDTH => rfwidth)
    port map (
      CLKW   => CLK,
      CLKR   => UI_CLK,
      RESETW => '0',
      RESETR => '0',
      DI     => REQ_DI,
      ENA    => REQ_ENA,
      BUSY   => open,
      DO     => REQ_DO,
      VAL    => REQ_VAL,
      HOLD   => REQ_HOLD,
      SIZEW  => REQ_SIZE,
      SIZER  => open
    );
  
  RESFIFO : fifo_2c_dram2               -- response fifo
    generic map (
      AWIDTH => 4,
      DWIDTH => dwidth)
    port map (
      CLKW   => UI_CLK,
      CLKR   => CLK,
      RESETW => '0',
      RESETR => '0',
      DI     => RES_DI,
      ENA    => RES_ENA,
      BUSY   => open,
      DO     => RES_DO,
      VAL    => RES_VAL,
      HOLD   => '0',
      SIZEW  => open,
      SIZER  => open
    );

  -- cdc for monitoring sigals from UI_CLK to CLK
  CDC_CRDY : cdc_signal_s1
    port map (
      CLKO  => CLK,
      DI    => APP_RDY,
      DO    => APP_RDY_CLK
    );
  CDC_WRDY : cdc_signal_s1
    port map (
      CLKO  => CLK,
      DI    => APP_WDF_RDY,
      DO    => APP_WDF_RDY_CLK
    );
  CDC_UIRST : cdc_signal_s1
    port map (
      CLKO  => CLK,
      DI    => UI_CLK_SYNC_RST,
      DO    => MIGUIRST_CLK
    );
  CDC_CACO : cdc_signal_s1
    port map (
      CLKO  => CLK,
      DI    => INIT_CALIB_COMPLETE,
      DO    => MIGCACO_CLK
    );
  
  proc_regs: process (CLK)
  begin

    if rising_edge(CLK) then
      if RESET = '1' then
        R_REGS <= regs_init;
      else
        R_REGS <= N_REGS;
      end if;
    end if;

  end process proc_regs;

  proc_next: process (R_REGS, REQ, ADDR, BE, DI, WE,
                      REQ_SIZE, RES_VAL, RES_DO,
                      APP_RDY_CLK, APP_WDF_RDY_CLK, MIGUIRST_CLK, MIGCACO_CLK)

    variable r : regs_type := regs_init;
    variable n : regs_type := regs_init;

    variable iga     : integer := 0;    
    variable ireqena : slbit := '0';
    variable iackw   : slbit := '0';
    variable imoni   : sramif2migui_moni_type := sramif2migui_moni_init;

    variable iwrbuf  : slv(dwidth-1 downto 0)  := (others=>'0');
    variable ireqdi  : slv(rfwidth-1 downto 0) := (others=>'0');

  begin

    r := R_REGS;
    n := R_REGS;

    iga     := 0;
    ireqena := '0';
    iackw   := '0';
    imoni   := sramif2migui_moni_init;

    imoni.migcbusy := not APP_RDY_CLK;
    imoni.migwbusy := not APP_WDF_RDY_CLK;
    imoni.miguirst := MIGUIRST_CLK;
    imoni.migcacow := not MIGCACO_CLK;
    
    -- setup request fifo data for write (the default)    
    ireqdi(rf_f_data) := r.wrbuf;
    ireqdi(rf_f_mask) := not r.wrpend;  -- -- MASK = not WE !!
    ireqdi(rf_f_addr) := r.wrtag;
    ireqdi(rf_f_we)   := '1';

    n.ackr := '0';                      -- ensure one-shot
    
    -- handle idle state, capture input, and activate read or write
    if r.actr='0' and r.actw='0' then
      if REQ = '1' then
        n.req_addr := ADDR;
        n.req_be   := BE;
        n.req_di   := DI;
        if WE = '1' then                -- write request
          n.actw := '1';
          if r.wrtag = ADDR(sa_f_ta)  then  -- row hit
            imoni.wrrhit := '1';
          else                            -- row miss
            if r.wrpend /= pendzero then    -- if write buffer pending
              ireqena  := '1';                  -- queue write request
              n.wrpend := pendzero;             -- clear pending flags
              imoni.wrflush := '1';
            end if;
          end if;
          
        else                            -- read request
          n.actr := '1';
        end if; -- WE='1' 
        
      end if; -- REQ='1' 
    end if;

    iga := to_integer(unsigned(r.req_addr(sa_f_ga))); -- current group index
    
    -- handle write request
    if r.actw = '1' then
      -- write into wrbuf and wrpend, no pending data left when here
      if r.req_be(0) = '1' then
        n.wrbuf(32*iga+ 7 downto 32*iga   ) := r.req_di( 7 downto  0);
      end if;
      if r.req_be(1) = '1' then
        n.wrbuf(32*iga+15 downto 32*iga+ 8) := r.req_di(15 downto  8);
      end if;
      if r.req_be(2) = '1' then
        n.wrbuf(32*iga+23 downto 32*iga+16) := r.req_di(23 downto 16);
      end if;
      if r.req_be(3) ='1' then
        n.wrbuf(32*iga+31 downto 32*iga+24) := r.req_di(31 downto 24);
      end if;

      n.wrtag  := r.req_addr(sa_f_ta);    -- set new tag address
      n.wrpend(4*iga+3 downto 4*iga) :=   -- and update pending flags
        n.wrpend(4*iga+3 downto 4*iga) or r.req_be;

      if r.rdtag = r.req_addr(sa_f_ta) then -- invalidate rdbuf if same tag
        n.rdval := '0';
      end if;
      
      -- ensure that at most 4 pending writes in queue
      --   REQ_SIZE gives # of available slots, empty FIFO has REQ_SIZE=15
      --   REQ_SIZE is 11 when 4 requests are on flight
      if unsigned(REQ_SIZE) >= 11 then
        n.actw := '0';                  -- mark request done
        iackw  := '1';                  -- send ack signal
      end if;
    end if;
    
    -- handle read request
    if r.actr = '1' then
      if r.rdtag=r.req_addr(sa_f_ta) and r.rdval='1' then --
        n.res_do := r.rdbuf(32*iga+31 downto 32*iga);
        n.actr  := '0';                 -- mark request done
        n.ackr  := '1';                 -- send ack signal
        n.rdnew := '0';                 -- mark used
        imoni.rdrhit := not r.rdnew;
      else
        if r.wrpend /= pendzero then      -- if write buffer pending
          ireqena  :=    '1';               -- queue write request
          n.wrpend := pendzero;             -- clear pending flags
          imoni.wrflush := '1';
        elsif r.rdpend = '0' then          
          ireqdi(rf_f_addr) := r.req_addr(sa_f_ta);
          ireqdi(rf_f_we)   := '0';
          n.rdtag  := r.req_addr(sa_f_ta); -- new tag
          n.rdval  := '0';                 -- mark rdbuf invalid
          n.rdpend := '1';                 -- assert read pending
          ireqena  := '1';                 -- queue read request
        end if;
      end if;
    end if;

    -- handle read response
    if RES_VAL = '1' then
      n.rdbuf  := RES_DO;               -- capture data
      n.rdval  := '1';                  -- mark valid
      n.rdnew  := '1';                  -- mark new
      n.rdpend := '0';                  -- deassert read pending
    end if;
    
    N_REGS <= n;

    REQ_DI  <= ireqdi;
    REQ_ENA <= ireqena;
    MONI    <= imoni;

    -- block input if busy or UI clock in RESET
    BUSY    <= r.actr or r.actw or MIGUIRST_CLK;
    
    ACK_R   <= r.ackr;
    ACK_W   <= iackw;
    ACT_R   <= r.actr;
    ACT_W   <= r.actw;
    DO      <= r.res_do;
    
  end process proc_next;
  
  proc_req2app: process (APP_RDY, APP_WDF_RDY, REQ_VAL, REQ_DO,
                         INIT_CALIB_COMPLETE)
  begin
    
    REQ_HOLD <= '0';

    APP_ADDR          <= (others=>'0');
    APP_ADDR(ma_f_ta) <= REQ_DO(rf_f_addr);
    APP_WDF_DATA <= REQ_DO(rf_f_data);
    APP_WDF_MASK <= REQ_DO(rf_f_mask);
    
    APP_EN       <= '0';
    APP_CMD      <= c_migui_cmd_read;
    APP_WDF_WREN <= '0';
    APP_WDF_END  <= '0';
    
    if APP_RDY='1' and APP_WDF_RDY='1' and INIT_CALIB_COMPLETE='1' then
      if REQ_VAL = '1' then
        APP_EN <= '1';
        if REQ_DO(rf_f_we) = '1' then
          APP_CMD      <= c_migui_cmd_write;
          APP_WDF_WREN <= '1';
          APP_WDF_END  <= '1';
        end if; -- REQ_DO(rf_f_we) = '1'
      end if; -- REQ_VAL = '1'
    else
      REQ_HOLD <= '1';
    end if; -- APP_RDY='1' and APP_WDF_RDY='1

  end process proc_req2app;

  proc_app2res: process (APP_RD_DATA_VALID, APP_RD_DATA)
  begin
    RES_ENA <= APP_RD_DATA_VALID;
    RES_DI  <= APP_RD_DATA;
  end process proc_app2res;

end syn;
