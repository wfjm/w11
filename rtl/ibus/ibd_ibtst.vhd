-- $Id: ibd_ibtst.vhd 1181 2019-07-08 17:00:50Z mueller $
-- SPDX-License-Identifier: GPL-3.0-or-later
-- Copyright 2019- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
--
------------------------------------------------------------------------------
-- Module Name:    ibd_ibtst - syn
-- Description:    ibus dev(rem): ibus tester
--
-- Dependencies:   memlib/fifo_simple_dram
-- Test bench:     -
-- Target Devices: generic
-- Tool versions:  ise 14.7; viv 2017.2; ghdl 0.35
--
-- Revision History: 
-- Date         Rev Version  Comment
-- 2019-03-01  1116   1.0.1  rnam dly[rw]->bsy[rw]; datto for write; add datab
-- 2019-02-16  1112   1.0    Initial version
-- 2019-02-09  1110   0.1    First draft
------------------------------------------------------------------------------
--
-- ibus registers:
--
-- Addr   Bits IB RB IR  Name          Function
--   00                  cntl          Control register
--          15 -- 0W 00    fclr          fifo clear
--           8 -- RW 00    datab         ibus ack while busy for data nak
--           7 -- RW 00    datto         ibus timeout for data nak
--           6 -- RW 00    nobyt         disallow byte writes to data (loc+rem)
--           5 -- RW 00    bsyw          enable loc write busy for fifo/data
--           4 -- RW 00    bsyr          enable loc read  busy for fifo/data
--           3 -- RW 11    remw          enable rem write for fifo/data
--           2 -- RW 11    remr          enable rem read  for fifo/data
--           1 -- RW 00    locw          enable loc write for fifo/data
--           0 -- RW 00    locr          enable loc read  for fifo/data
--   01        -- R-     stat          Status register (moni last data/fifo)
--       15:12 -- R-       fsize         fifo size
--           6 -- R-       racc          remote access seen
--           5 -- R-       cacc          console access seen
--           4 -- R-       be1           byte enable high seen
--           3 -- R-       be0           byte enable low seen
--           2 -- R-       rmw           read-modify-write seen
--           1 -- R-       we            write enable seen
--           0 -- R-       re            read enable seen
--   10        rw rw 00  data          data register (byte/word writable)
--   11        rw rw     fifo          fifo interface register
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.slvtypes.all;
use work.memlib.all;
use work.iblib.all;

-- ----------------------------------------------------------------------------
entity ibd_ibtst is                     -- ibus dev(rem): ibus tester
  generic (
    IB_ADDR : slv16 := slv(to_unsigned(8#170000#,16)));  -- base address
  port (
    CLK : in slbit;                     -- clock
    RESET : in slbit;                   -- reset
    IB_MREQ : in ib_mreq_type;          -- ibus request
    IB_SRES : out ib_sres_type          -- ibus response
  );
end ibd_ibtst;

architecture syn of ibd_ibtst is

  constant ibaddr_cntl : slv2 := "00";  -- cntl address offset
  constant ibaddr_stat : slv2 := "01";  -- stat address offset
  constant ibaddr_data : slv2 := "10";  -- bdat address offset
  constant ibaddr_fifo : slv2 := "11";  -- wdat address offset
  
  constant cntl_ibf_fclr   : integer := 15;
  constant cntl_ibf_datab  : integer :=  8;
  constant cntl_ibf_datto  : integer :=  7;
  constant cntl_ibf_nobyt  : integer :=  6;
  constant cntl_ibf_bsyw   : integer :=  5;
  constant cntl_ibf_bsyr   : integer :=  4;
  constant cntl_ibf_remw   : integer :=  3;
  constant cntl_ibf_remr   : integer :=  2;
  constant cntl_ibf_locw   : integer :=  1;
  constant cntl_ibf_locr   : integer :=  0;

  subtype  stat_ibf_fsize is integer range 15 downto 12;
  constant stat_ibf_racc   : integer :=  6;
  constant stat_ibf_cacc   : integer :=  5;
  constant stat_ibf_be1    : integer :=  4;
  constant stat_ibf_be0    : integer :=  3;
  constant stat_ibf_rmw    : integer :=  2;
  constant stat_ibf_we     : integer :=  1;
  constant stat_ibf_re     : integer :=  0;

  type regs_type is record              -- state registers
    ibsel : slbit;                      -- ibus select
    datab : slbit;                      -- cntl: ibus busy for bad loc data
    datto : slbit;                      -- cntl: ibus timeout for bad loc data
    nobyt : slbit;                      -- cntl: disallow byte writes to data
    bsyw  : slbit;                      -- cntl: enable loc write busy
    bsyr  : slbit;                      -- cntl: enable loc read  busy
    remw  : slbit;                      -- cntl: enable rem write
    remr  : slbit;                      -- cntl: enable rem read
    locw  : slbit;                      -- cntl: enable loc write
    locr  : slbit;                      -- cntl: enable loc read
    racc  : slbit;                      -- stat: racc seen
    cacc  : slbit;                      -- stat: cacc seen
    be1   : slbit;                      -- stat: be1  seen
    be0   : slbit;                      -- stat: be0  seen
    rmw   : slbit;                      -- stat: rmw  seen
    we    : slbit;                      -- stat: we   seen
    re    : slbit;                      -- stat: re   seen
    data  : slv16;                      -- data register
    dcnt  : slv3;                       -- delay counter
    req_1 : slbit;                      -- (re or we) of last cycle
    rwm_1 : slbit;                      -- (re or we or rmw) of last cycle
  end record regs_type;

  constant regs_init : regs_type := (
    '0',                                -- ibsel
    '0','0','0','0','0',                -- datab,datto,nobyt,bsyw,bsyr
    '1','1','0','0',                    -- remw,remr,locw,locr
    '0','0','0','0',                    -- racc,cacc,be1,be0
    '0','0','0',                        -- rmw,we,re
    (others=>'0'),                      -- data
    (others=>'0'),                      -- dcnt
    '0','0'                             -- req_1,rwm_1
  );

  signal R_REGS : regs_type := regs_init;
  signal N_REGS : regs_type := regs_init;
  
  signal FIFO_CE : slbit := '0';
  signal FIFO_WE : slbit := '0';
  signal FIFO_RESET : slbit := '0';
  signal FIFO_EMPTY : slbit := '0';
  signal FIFO_FULL  : slbit := '0';
  signal FIFO_SIZE  : slv4  := (others=>'0');
  signal FIFO_DO    : slv16 := (others=>'0');

begin
  
  FIFO : fifo_simple_dram
    generic map (
      AWIDTH =>  4,
      DWIDTH => 16)
    port map (
      CLK   => CLK,
      RESET => FIFO_RESET,
      CE    => FIFO_CE,
      WE    => FIFO_WE,
      DI    => IB_MREQ.din,
      DO    => FIFO_DO,
      EMPTY => FIFO_EMPTY,
      FULL  => FIFO_FULL,
      SIZE  => FIFO_SIZE
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

  proc_next : process (R_REGS, IB_MREQ, RESET, FIFO_DO, FIFO_EMPTY,
                       FIFO_FULL, FIFO_SIZE)
    variable r : regs_type := regs_init;
    variable n : regs_type := regs_init;
    variable ibreq : slbit := '0';
    variable ibbusy : slbit := '0';
    variable iback : slbit := '0';
    variable idout : slv16 := (others=>'0');
    variable ififo_rst : slbit := '0';
    variable ififo_ce  : slbit := '0';
    variable ififo_we  : slbit := '0';
    variable bsyok : slbit := '0';      -- fifo/data busy ok
    variable dobsy : slbit := '0';      -- fifo/data do busy
    variable wrok  : slbit := '0';      -- fifo/data write ok
    variable rdok  : slbit := '0';      -- fifo/data read ok
  begin

    r := R_REGS;
    n := R_REGS;

    idout  := (others=>'0');
    ibreq  := IB_MREQ.re or IB_MREQ.we;
    ibbusy := '0';
    iback  := r.ibsel and ibreq;
    ififo_rst := RESET;
    ififo_ce  := '0';
    ififo_we  := '0';

    bsyok := '0';
    if IB_MREQ.racc = '0' then          -- loc
      bsyok := (r.bsyr and IB_MREQ.re) or (r.bsyw and IB_MREQ.we);
    end if;
    dobsy := '0';
    
    if IB_MREQ.racc = '1' then          -- rem
      wrok := r.remw;
      rdok := r.remr;
    else                                -- loc
      wrok := r.locw;
      rdok := r.locr;      
    end if;
        
    -- ibus address decoder
    n.ibsel := '0';
    if IB_MREQ.aval='1' and IB_MREQ.addr(12 downto 3)=IB_ADDR(12 downto 3) then
      n.ibsel := '1';
    end if;

    -- re,we,rmw edge detectors
    n.req_1 := r.ibsel and (ibreq);
    n.rwm_1 := r.ibsel and (ibreq or IB_MREQ.rmw);

    -- ibus mreq monitor
    if r.ibsel = '1' then
      if (ibreq or IB_MREQ.rmw) = '1' and  -- re or we or rmw
         IB_MREQ.addr(2) = '1' then        --   and addr = (data or fifo)
        if r.rwm_1 = '0' then                -- leading edge
          n.racc := IB_MREQ.racc;
          n.cacc := IB_MREQ.cacc;
          n.be1  := IB_MREQ.be1;
          n.be0  := IB_MREQ.be0;
          n.rmw  := IB_MREQ.rmw;
          n.we   := IB_MREQ.we;
          n.re   := IB_MREQ.re;
        else                                 -- later
          n.we   := r.we or IB_MREQ.we;
          n.re   := r.re or IB_MREQ.re;
        end if;
      end if;
    end if;

    -- delay counter
    if r.ibsel='1' and ibreq='1' and bsyok='1' then -- selected,active,busy
      if r.req_1 = '0' then                           -- leading edge
        n.dcnt := "111";
        dobsy  := '1';
      else                                            -- later
        if r.dcnt /= "000" then
          n.dcnt := slv(unsigned(r.dcnt) - 1);
          dobsy  := '1';
        end if;
      end if;
    end if;
    
    -- ibus transactions
    if r.ibsel = '1' then
      case IB_MREQ.addr(2 downto 1) is
        when ibaddr_cntl =>           -- CNTL
          if IB_MREQ.racc = '1' then    -- rem
            if IB_MREQ.we = '1' then      -- write
              ififo_rst := IB_MREQ.din(cntl_ibf_fclr);
              n.datab := IB_MREQ.din(cntl_ibf_datab);
              n.datto := IB_MREQ.din(cntl_ibf_datto);
              n.nobyt := IB_MREQ.din(cntl_ibf_nobyt);
              n.bsyw  := IB_MREQ.din(cntl_ibf_bsyw);
              n.bsyr  := IB_MREQ.din(cntl_ibf_bsyr);
              n.remw  := IB_MREQ.din(cntl_ibf_remw);
              n.remr  := IB_MREQ.din(cntl_ibf_remr);
              n.locw  := IB_MREQ.din(cntl_ibf_locw);
              n.locr  := IB_MREQ.din(cntl_ibf_locr);
            end if;
          else                          -- loc
            iback := '0';                 -- reject loc access to CNTL
          end if;
          
        when ibaddr_stat =>           -- STAT
          if IB_MREQ.racc = '0' then    -- loc
            iback := '0';                 -- reject loc access to STAT
          end if;
          
        when ibaddr_data =>           -- DATA
          if IB_MREQ.we = '1' then      -- write
            if wrok = '1' then            -- write enabled
              if r.nobyt = '1' and          -- byte write allowed check
                (IB_MREQ.be1='0' or IB_MREQ.be0='0') then
                iback := '0';                 -- send nak
              else                          -- byte check ok
                if dobsy = '1' then           -- busy active 
                  iback  := '0';
                  ibbusy := '1';
                else                          -- no busy active
                  if IB_MREQ.be1 = '1' then
                    n.data(ibf_byte1) := IB_MREQ.din(ibf_byte1);
                  end if;
                  if IB_MREQ.be0 = '1' then
                    n.data(ibf_byte0) := IB_MREQ.din(ibf_byte0);
                  end if;
                end if; --  dobsy = '1'
              end if; -- byte check
            else                          -- write disabled
              if dobsy = '1' then           -- busy active
                iback  := r.datab;            -- send ack when busy for nak
                ibbusy := '1';
              else                          -- no busy active
                if r.datto = '1' then         -- data time out enabled
                  iback  := '0';
                  ibbusy := '1';                -- will cause timeout !
                else
                  iback := '0';                 -- send nak
                end if;
              end if; -- dobsy = '1'
            end if; -- wrok = '1'
          end if; -- IB_MREQ.we = '1'
          
          if IB_MREQ.re = '1' then      -- read
            if rdok = '1' then            -- read enabled
              if dobsy = '1' then           -- busy active 
                iback  := '0';
                ibbusy := '1';
              end if;
            else                          -- read disabled
              if dobsy = '1' then           -- busy active
                iback  := r.datab;            -- send ack when busy for nak
                ibbusy := '1';
              else                          -- no busy active
                if r.datto = '1' then         -- data time out enabled
                  iback  := '0';
                  ibbusy := '1';                -- will cause timeout !
                else
                  iback := '0';                 -- send nak
                end if;
              end if; -- dobsy = '1'
            end if; -- rdok = '0'
          end if; -- IB_MREQ.re = '1'
 
        when ibaddr_fifo =>           -- FIFO
          if IB_MREQ.we = '1' then      -- write
            if wrok = '1' then            -- write enabled
              if dobsy = '1' then           -- busy active 
                iback  := '0';
                ibbusy := '1';
              else                          -- busy not active
                if FIFO_FULL = '0' then       -- fifo not full
                  ififo_ce := '1';
                  ififo_we := '1';
                else                          -- fifo full
                  iback := '0';                 -- send nak
                end if; -- FIFO_FULL = '0'
              end if; -- dobsy = '1'
            else                          -- write disabled
              iback := '0';                 -- send nak
            end if; -- wrok = '1'
          end if; -- IB_MREQ.we = '1'
          
          if IB_MREQ.re = '1' then      -- read
            if rdok = '1' then            -- read enabled
              if dobsy = '1' then           -- busy active 
                iback  := '0';
                ibbusy := '1';
              else                          -- busy not active
                if FIFO_EMPTY = '0' then      -- fifo not empty
                  ififo_ce := '1';
                else                          -- fifo empty
                  iback := '0';                 -- send nak
                end if; -- FIFO_EMPTY = '0'
              end if; -- dobsy = '1'
            else                          -- read disabled
              iback := '0';                 -- send nak
            end if; -- rdok = '1'
          end if; -- IB_MREQ.re = '1'
                                       
        when others => null;
      end case; --
    end if; --r.ibsel = '1'

    -- ibus output driver
    if r.ibsel = '1' then
      case IB_MREQ.addr(2 downto 1) is
        when ibaddr_cntl =>           -- CNTL
          idout(cntl_ibf_datab) := r.datab;
          idout(cntl_ibf_datto) := r.datto;
          idout(cntl_ibf_nobyt) := r.nobyt;
          idout(cntl_ibf_bsyw)  := r.bsyw;
          idout(cntl_ibf_bsyr)  := r.bsyr;
          idout(cntl_ibf_remw)  := r.remw;
          idout(cntl_ibf_remr)  := r.remr;
          idout(cntl_ibf_locw)  := r.locw;
          idout(cntl_ibf_locr)  := r.locr;
        when ibaddr_stat =>           -- STAT
          idout(stat_ibf_fsize) := FIFO_SIZE;
          idout(stat_ibf_racc)  := r.racc;
          idout(stat_ibf_cacc)  := r.cacc;
          idout(stat_ibf_be1)   := r.be1;
          idout(stat_ibf_be0)   := r.be0;
          idout(stat_ibf_rmw)   := r.rmw;
          idout(stat_ibf_we)    := r.we;
          idout(stat_ibf_re)    := r.re;
        when ibaddr_data =>           -- DATA
          idout                 := r.data;
        when ibaddr_fifo =>           -- FIFO
          idout                 := FIFO_DO;
        when others => null;
      end case;
    end if;

    N_REGS <= n;
    
    FIFO_RESET <= ififo_rst;
    FIFO_CE    <= ififo_ce;
    FIFO_WE    <= ififo_we;

    IB_SRES.dout <= idout;
    IB_SRES.ack  <= iback;
    IB_SRES.busy <= ibbusy;
    
  end process proc_next;

    
end syn;
