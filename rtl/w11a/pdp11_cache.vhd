-- $Id: pdp11_cache.vhd 1181 2019-07-08 17:00:50Z mueller $
-- SPDX-License-Identifier: GPL-3.0-or-later
-- Copyright 2008-2018 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
-- 
------------------------------------------------------------------------------
-- Module Name:    pdp11_cache - syn
-- Description:    pdp11: cache
--
-- Dependencies:   memlib/ram_2swsr_rfirst_gen
-- Test bench:     -
-- Target Devices: generic
-- Tool versions:  ise 8.2-14.7; viv 2014.4-2018.2; ghdl 0.18-0.34
--
-- Synthesis results
--   clw = cache line width (tag+data)
--   eff = efficiency (fraction of used BRAM colums)
-- - 2016-03-22 (r750) with viv 2015.4 for xc7a100t-1
--   TWIDTH  size  flop  lutl  lutm  RAMB36 RAMB18   bram   clw   eff
--        9    8k    43   106     0       0      5    2.5    45  100%
--        8   16k    43   109     0       5      0    5.0    44   97%
--        7   32k    43   107     0      10      4   12.0    43   89%
--        6   64k    43   106     0      19      4   21.0    42  100%
--        5  128k    58!  106     0      41      0   41.0    41  100%
--
-- Revision History: 
-- Date         Rev Version  Comment
-- 2018-10-06  1053   1.2    drop CHIT, use DM_STAT_CA, detailed monitoring
-- 2016-05-22   767   1.1.1  don't init N_REGS (vivado fix for fsm inference)
-- 2016-03-22   751   1.1    now configurable size (8,16,32,64,128 kB)
-- 2011-11-18   427   1.0.3  now numeric_std clean
-- 2008-02-23   118   1.0.2  ce cache in s_idle to avoid U's in sim
--                           factor invariants out of if's; fix tag rmiss logic
-- 2008-02-17   117   1.0.1  use em_(mreq|sres) interface; use req,we for mem
--                           recode, ghdl doesn't like partial vector port maps
-- 2008-02-16   116   1.0    Initial version 
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.slvtypes.all;
use work.memlib.all;
use work.pdp11.all;

entity pdp11_cache is                   -- cache
  generic (
    TWIDTH : positive := 9);            -- tag width (5 to 9)
  port (
    CLK : in slbit;                     -- clock
    GRESET : in slbit;                  -- general reset
    EM_MREQ : in em_mreq_type;          -- em request
    EM_SRES : out em_sres_type;         -- em response
    FMISS : in slbit;                   -- force miss
    MEM_REQ : out slbit;                -- memory: request
    MEM_WE : out slbit;                 -- memory: write enable
    MEM_BUSY : in slbit;                -- memory: controller busy
    MEM_ACK_R : in slbit;               -- memory: acknowledge read
    MEM_ADDR : out slv20;               -- memory: address
    MEM_BE : out slv4;                  -- memory: byte enable
    MEM_DI : out slv32;                 -- memory: data in  (memory view)
    MEM_DO : in slv32;                  -- memory: data out (memory view)
    DM_STAT_CA : out dm_stat_ca_type    -- debug and monitor status - cache
  );
end pdp11_cache;


architecture syn of pdp11_cache is

  constant lwidth: positive := 22-2-TWIDTH; -- line address width

  subtype t_range   is integer range TWIDTH-1 downto  0;      -- tag value regs
  subtype l_range   is integer range lwidth-1 downto  0;      -- line addr regs

  subtype af_tag    is integer range 22-1 downto 22-TWIDTH;   -- tag  address
  subtype af_line   is integer range 22-TWIDTH-1 downto 2;    -- line address
  
  subtype df_byte3  is integer range 31 downto 24;
  subtype df_byte2  is integer range 23 downto 16;
  subtype df_byte1  is integer range 15 downto  8;
  subtype df_byte0  is integer range  7 downto  0;

  subtype df_word1  is integer range 31 downto 16;
  subtype df_word0  is integer range 15 downto  0;
  
  type state_type is (
    s_idle,                             -- s_idle: wait for req
    s_read,                             -- s_read: read cycle
    s_rmiss,                            -- s_rmiss: read miss
    s_write                             -- s_write: write cycle
  );
  
  type regs_type is record
    state : state_type;                 -- state
    addr_w : slbit;                     -- address - word select
    addr_l : slv(l_range);              -- address - cache line address
    addr_t : slv(t_range);              -- address - cache tag part
    be : slv4;                          -- byte enables (at 4 byte level)
    di : slv16;                         -- data
  end record regs_type;

  constant regs_init : regs_type := (
    s_idle,                             -- state
    '0',                                -- addr_w
    slv(to_unsigned(0,lwidth)),         -- addr_l
    slv(to_unsigned(0,TWIDTH)),         -- addr_t
    (others=>'0'),                      -- be
    (others=>'0')                       -- di
  );
    
  signal R_REGS : regs_type := regs_init;
  signal N_REGS : regs_type;            -- don't init (vivado fix for fsm infer)
  
  signal CMEM_TAG_CEA  : slbit := '0';
  signal CMEM_TAG_CEB  : slbit := '0';
  signal CMEM_TAG_WEA  : slbit := '0';
  signal CMEM_TAG_WEB  : slbit := '0';
  signal CMEM_TAG_DIB  : slv(t_range)  := (others=>'0');
  signal CMEM_TAG_DOA  : slv(t_range)  := (others=>'0');
  signal CMEM_DAT_CEA  : slbit := '0';
  signal CMEM_DAT_CEB  : slbit := '0';
  signal CMEM_DAT_WEA  : slv4 := "0000";
  signal CMEM_DAT_WEB  : slv4 := "0000";
  signal CMEM_DIA_0    : slv9 := (others=>'0');
  signal CMEM_DIA_1    : slv9 := (others=>'0');
  signal CMEM_DIA_2    : slv9 := (others=>'0');
  signal CMEM_DIA_3    : slv9 := (others=>'0');
  signal CMEM_DIB_0    : slv9 := (others=>'0');
  signal CMEM_DIB_1    : slv9 := (others=>'0');
  signal CMEM_DIB_2    : slv9 := (others=>'0');
  signal CMEM_DIB_3    : slv9 := (others=>'0');
  signal CMEM_DOA_0    : slv9 := (others=>'0');
  signal CMEM_DOA_1    : slv9 := (others=>'0');
  signal CMEM_DOA_2    : slv9 := (others=>'0');
  signal CMEM_DOA_3    : slv9 := (others=>'0');

begin

  assert TWIDTH>=5 and TWIDTH<=9
  report "assert(TWIDTH>=5 and TWIDTH<=9): unsupported TWIDTH"
  severity failure;

  CMEM_TAG : ram_2swsr_rfirst_gen
    generic map (
      AWIDTH => lwidth,
      DWIDTH => twidth)
    port map (
      CLKA  => CLK,
      CLKB  => CLK,
      ENA   => CMEM_TAG_CEA,
      ENB   => CMEM_TAG_CEB,
      WEA   => CMEM_TAG_WEA,
      WEB   => CMEM_TAG_WEB,
      ADDRA => EM_MREQ.addr(af_line),
      ADDRB => R_REGS.addr_l,
      DIA   => EM_MREQ.addr(af_tag),
      DIB   => CMEM_TAG_DIB,
      DOA   => CMEM_TAG_DOA,
      DOB   => open
      );

  CMEM_DAT0 : ram_2swsr_rfirst_gen
    generic map (
      AWIDTH => lwidth,
      DWIDTH =>  9)
    port map (
      CLKA  => CLK,
      CLKB  => CLK,
      ENA   => CMEM_DAT_CEA,
      ENB   => CMEM_DAT_CEB,
      WEA   => CMEM_DAT_WEA(0),
      WEB   => CMEM_DAT_WEB(0),
      ADDRA => EM_MREQ.addr(af_line),
      ADDRB => R_REGS.addr_l,
      DIA   => CMEM_DIA_0,
      DIB   => CMEM_DIB_0,
      DOA   => CMEM_DOA_0,
      DOB   => open
      );

  CMEM_DAT1 : ram_2swsr_rfirst_gen
    generic map (
      AWIDTH => lwidth,
      DWIDTH =>  9)
    port map (
      CLKA  => CLK,
      CLKB  => CLK,
      ENA   => CMEM_DAT_CEA,
      ENB   => CMEM_DAT_CEB,
      WEA   => CMEM_DAT_WEA(1),
      WEB   => CMEM_DAT_WEB(1),
      ADDRA => EM_MREQ.addr(af_line),
      ADDRB => R_REGS.addr_l,
      DIA   => CMEM_DIA_1,
      DIB   => CMEM_DIB_1,
      DOA   => CMEM_DOA_1,
      DOB   => open
      );

  CMEM_DAT2 : ram_2swsr_rfirst_gen
    generic map (
      AWIDTH => lwidth,
      DWIDTH =>  9)
    port map (
      CLKA  => CLK,
      CLKB  => CLK,
      ENA   => CMEM_DAT_CEA,
      ENB   => CMEM_DAT_CEB,
      WEA   => CMEM_DAT_WEA(2),
      WEB   => CMEM_DAT_WEB(2),
      ADDRA => EM_MREQ.addr(af_line),
      ADDRB => R_REGS.addr_l,
      DIA   => CMEM_DIA_2,
      DIB   => CMEM_DIB_2,
      DOA   => CMEM_DOA_2,
      DOB   => open
      );

  CMEM_DAT3 : ram_2swsr_rfirst_gen
    generic map (
      AWIDTH => lwidth,
      DWIDTH =>  9)
    port map (
      CLKA  => CLK,
      CLKB  => CLK,
      ENA   => CMEM_DAT_CEA,
      ENB   => CMEM_DAT_CEB,
      WEA   => CMEM_DAT_WEA(3),
      WEB   => CMEM_DAT_WEB(3),
      ADDRA => EM_MREQ.addr(af_line),
      ADDRB => R_REGS.addr_l,
      DIA   => CMEM_DIA_3,
      DIB   => CMEM_DIB_3,
      DOA   => CMEM_DOA_3,
      DOB   => open
      );

  proc_regs: process (CLK)
  begin

    if rising_edge(CLK) then
      if GRESET = '1' then
        R_REGS <= regs_init;
      else
        R_REGS <= N_REGS;
      end if;
    end if;

  end process proc_regs;

  proc_next: process (R_REGS, EM_MREQ, FMISS,
                      CMEM_TAG_DOA,
                      CMEM_DOA_0, CMEM_DOA_1, CMEM_DOA_2, CMEM_DOA_3, 
                      MEM_BUSY, MEM_ACK_R, MEM_DO)

    variable r : regs_type := regs_init;
    variable n : regs_type := regs_init;

    variable iaddr_w : slbit := '0';
    variable iaddr_l : slv(l_range) := (others=>'0');
    variable iaddr_t : slv(t_range)  := (others=>'0');

    variable itagok : slbit := '0';
    variable ivalok : slbit := '0';

    variable icmem_tag_cea : slbit := '0';
    variable icmem_tag_ceb : slbit := '0';
    variable icmem_tag_wea : slbit := '0';
    variable icmem_tag_web : slbit := '0';
    variable icmem_tag_dib : slv(t_range)  := (others=>'0');
    variable icmem_dat_cea : slbit := '0';
    variable icmem_dat_ceb : slbit := '0';
    variable icmem_dat_wea : slv4  := "0000";
    variable icmem_dat_web : slv4  := "0000";
    variable icmem_val_doa : slv4  := "0000";
    variable icmem_dat_doa : slv32 := (others=>'0');
    variable icmem_val_dib : slv4  := "0000";
    variable icmem_dat_dib : slv32 := (others=>'0');

    variable iackr : slbit := '0';
    variable iackw : slbit := '0';
    variable iosel : slv2  := "11";
    variable istat : dm_stat_ca_type := dm_stat_ca_init;

    variable imem_reqr : slbit := '0';
    variable imem_reqw : slbit := '0';
    variable imem_be   : slv4  := "0000";

  begin

    r := R_REGS;
    n := R_REGS;

    iaddr_w := EM_MREQ.addr(1);                -- get word select
    iaddr_l := EM_MREQ.addr(af_line);          -- get cache line addr
    iaddr_t := EM_MREQ.addr(af_tag);           -- get cache tag part
    
    icmem_tag_cea := '0';
    icmem_tag_ceb := '0';
    icmem_tag_wea := '0';
    icmem_tag_web := '0';
    icmem_tag_dib := r.addr_t;          -- default, local define whenver used
    icmem_dat_cea := '0';
    icmem_dat_ceb := '0';
    icmem_dat_wea := "0000";
    icmem_dat_web := "0000";
    icmem_val_dib := "0000";
    icmem_dat_dib := MEM_DO;            -- default, local define whenver used

    icmem_val_doa(0)        := CMEM_DOA_0(8);
    icmem_dat_doa(df_byte0) := CMEM_DOA_0(df_byte0);
    icmem_val_doa(1)        := CMEM_DOA_1(8);
    icmem_dat_doa(df_byte1) := CMEM_DOA_1(df_byte0);
    icmem_val_doa(2)        := CMEM_DOA_2(8);
    icmem_dat_doa(df_byte2) := CMEM_DOA_2(df_byte0);
    icmem_val_doa(3)        := CMEM_DOA_3(8);
    icmem_dat_doa(df_byte3) := CMEM_DOA_3(df_byte0);

    itagok := '0';
    if CMEM_TAG_DOA = r.addr_t then  -- cache tag hit
      itagok := '1';
    end if;
    ivalok := '0';
    if (icmem_val_doa and r.be) = r.be then
      ivalok := '1';
    end if;

    iackr := '0';
    iackw := '0';
    iosel := "11";                      -- default to ext. mem data
                                        -- this prevents U's from cache bram's
                                        -- to propagate to dout in beginning...

    istat := dm_stat_ca_init;

    imem_reqr := '0';
    imem_reqw := '0';
    imem_be   := r.be;
    
    case r.state is
      when s_idle =>                    -- s_idle: wait for req
        n.addr_w := iaddr_w;              -- capture address: word select
        n.addr_l := iaddr_l;              -- capture address: cache line addr
        n.addr_t := iaddr_t;              -- capture address: cache tag part
        n.be     := "0000";
        icmem_tag_cea := '1';             -- access cache tag port A
        icmem_dat_cea := '1';             -- access cache data port A
        if iaddr_w = '0' then             -- capture byte enables at 4 byte lvl
          n.be(1 downto 0) := EM_MREQ.be;
        else
          n.be(3 downto 2) := EM_MREQ.be;
        end if;
        n.di     := EM_MREQ.din;          -- capture data

        if EM_MREQ.req = '1' then         -- if access requested
          if EM_MREQ.we = '0' then          -- if READ requested
            n.state := s_read;                -- next: read

          else                              -- if WRITE requested
            icmem_tag_wea := '1';             -- write tag
            icmem_dat_wea := n.be;            -- write cache data
            n.state := s_write;               -- next: write
          end if;
        end if;
          
      when s_read =>                    -- s_read: read cycle
        iosel := '0' & r.addr_w;          -- output select: cache
        imem_be := "1111";                -- mem read: all 4 bytes
        if EM_MREQ.cancel = '0' then
          if FMISS='0' and itagok='1' and ivalok='1' then -- read tag&val hit
            istat.rd := '1';                -- moni read request (hit)
            iackr := '1';                   -- signal read acknowledge
            istat.rdhit := '1';             -- moni read hit
            n.state := s_idle;              -- next: back to idle 
          else                            -- read miss
            if MEM_BUSY = '0' then          -- if mem not busy
              istat.rd := '1';                -- moni read request (!hit & !wait)
              imem_reqr :='1';                -- request mem read
              istat.rdmem := '1';             -- moni mem read
              n.state := s_rmiss;             -- next: rmiss, wait for mem data
            else                            -- else mem busy
              istat.wrwait := '1';            -- moni mem busy
            end if;
          end if;
        else
          n.state := s_idle;              -- next: back to idle 
        end if;

      when s_rmiss =>                   -- s_rmiss: read cycle
        iosel := '1' & r.addr_w;          -- output select: memory
        icmem_tag_web := '1';             -- cache update: write tag
        icmem_tag_dib := r.addr_t;        -- cache update: new tag
        icmem_val_dib := "1111";          -- cache update: all valid
        icmem_dat_dib := MEM_DO;          -- cache update: data from mem
        icmem_dat_web := "1111";          -- cache update: write all 4 bytes
        istat.rdwait := '1';              -- moni read wait
        if MEM_ACK_R = '1' then           -- mem data valid
          iackr := '1';                     -- signal read acknowledge
          icmem_tag_ceb := '1';             -- access cache tag  port B
          icmem_dat_ceb := '1';             -- access cache data port B
          n.state := s_idle;                -- next: back to idle
        end if;

      when s_write =>                   -- s_write: write cycle
        icmem_tag_dib := CMEM_TAG_DOA;    -- cache restore: last state 
        icmem_dat_dib := icmem_dat_doa;   -- cache restore: last state 
        if EM_MREQ.cancel = '0' then      -- request ok
          if MEM_BUSY = '0' then            -- if mem not busy
            istat.wr := '1';                -- moni write request
            if itagok = '0' then              -- if write tag miss
              icmem_dat_ceb := '1';             -- access cache (invalidate)
              icmem_dat_web := not r.be;        -- write missed bytes
              icmem_val_dib := "0000";          -- invalidate missed bytes
            else
              istat.wrhit := '1';               -- moni write hit
            end if;
            imem_reqw := '1';                 -- write back to main memory
            istat.wrmem := '1';               -- moni mem write
            iackw := '1';                     -- and done
            n.state := s_idle;                -- next: back to idle
          else                              -- else mem busy
            istat.wrwait := '1';              -- moni mem busy
          end if;
          
        else                              -- request canceled -> restore
          icmem_tag_ceb := '1';             -- access cache line
          icmem_tag_web := '1';             -- write tag
          icmem_dat_ceb := '1';             -- access cache line
          icmem_dat_web := "1111";          -- restore cache line
          icmem_val_dib := icmem_val_doa;   -- cache restore: last state 
          n.state := s_idle;                -- next: back to idle          
        end if;  

      when others => null;
    end case;
    
    N_REGS <= n;

    CMEM_TAG_CEA <= icmem_tag_cea;
    CMEM_TAG_CEB <= icmem_tag_ceb;
    CMEM_TAG_WEA <= icmem_tag_wea;
    CMEM_TAG_WEB <= icmem_tag_web;
    CMEM_TAG_DIB <= icmem_tag_dib;
    CMEM_DAT_CEA <= icmem_dat_cea;
    CMEM_DAT_CEB <= icmem_dat_ceb;
    CMEM_DAT_WEA <= icmem_dat_wea;
    CMEM_DAT_WEB <= icmem_dat_web;
    
    CMEM_DIA_0(8)        <= '1';
    CMEM_DIA_0(df_byte0) <= EM_MREQ.din(df_byte0);
    CMEM_DIA_1(8)        <= '1';
    CMEM_DIA_1(df_byte0) <= EM_MREQ.din(df_byte1);
    CMEM_DIA_2(8)        <= '1';
    CMEM_DIA_2(df_byte0) <= EM_MREQ.din(df_byte0);
    CMEM_DIA_3(8)        <= '1';
    CMEM_DIA_3(df_byte0) <= EM_MREQ.din(df_byte1);

    CMEM_DIB_0(8)        <= icmem_val_dib(0);
    CMEM_DIB_0(df_byte0) <= icmem_dat_dib(df_byte0);
    CMEM_DIB_1(8)        <= icmem_val_dib(1);
    CMEM_DIB_1(df_byte0) <= icmem_dat_dib(df_byte1);
    CMEM_DIB_2(8)        <= icmem_val_dib(2);
    CMEM_DIB_2(df_byte0) <= icmem_dat_dib(df_byte2);
    CMEM_DIB_3(8)        <= icmem_val_dib(3);
    CMEM_DIB_3(df_byte0) <= icmem_dat_dib(df_byte3);

    EM_SRES <= em_sres_init;
    EM_SRES.ack_r <= iackr;
    EM_SRES.ack_w <= iackw;
    case iosel is
      when "00" => EM_SRES.dout <= icmem_dat_doa(df_word0);
      when "01" => EM_SRES.dout <= icmem_dat_doa(df_word1);
      when "10" => EM_SRES.dout <= MEM_DO(df_word0);
      when "11" => EM_SRES.dout <= MEM_DO(df_word1);
      when others => null;
    end case;
    
    DM_STAT_CA <= istat;

    MEM_REQ  <= imem_reqr or imem_reqw;
    MEM_WE   <= imem_reqw;
    MEM_ADDR <= r.addr_t & r.addr_l;
    MEM_BE   <= imem_be;
    MEM_DI   <= r.di & r.di;
    
  end process proc_next;
  
end syn;
