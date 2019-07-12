-- $Id: ibd_ibmon.vhd 1181 2019-07-08 17:00:50Z mueller $
-- SPDX-License-Identifier: GPL-3.0-or-later
-- Copyright 2015-2019 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
--
------------------------------------------------------------------------------
-- Module Name:    ibd_ibmon - syn
-- Description:    ibus dev: ibus monitor
--
-- Dependencies:   memlib/ram_1swsr_wfirst_gen
--
-- Test bench:     -
--
-- Target Devices: generic
-- Tool versions:  xst 14.7; viv 2014.4-2018.3; ghdl 0.31-0.35
--
-- Synthesized (xst):
-- Date         Rev  ise         Target      flop lutl lutm slic t peri
-- 2017-04-14   873 14.7  131013 xc6slx16-2   121  205    0   77 s  5.5
-- 2015-04-24   668 14.7  131013 xc6slx16-2   112  235    0   83 s  5.6
--
-- Revision History: 
-- Date         Rev Version  Comment
-- 2019-03-01  1116   2.1.1  track ack properly
-- 2019-02-23  1115   2.1    revised iface, busy 10->8, delay 14->16 bits
-- 2017-04-16   879   2.0    revised interface, add suspend and repeat collapse
-- 2017-03-04   858   1.0.2  BUGFIX: wrap set when go=0 due to wena=0
-- 2015-05-02   672   1.0.1  use natural for AWIDTH to work around a ghdl issue
-- 2015-04-24   668   1.0    Initial version (derived from rbd_rbmon)
------------------------------------------------------------------------------
--
-- Addr   Bits  Name        r/w/f  Function
--  000         cntl        r/w/f  Control register
--          08    rcolw     r/w/-    repeat collapse writes
--          07    rcolr     r/w/-    repeat collapse reads
--          06    wstop     r/w/-    stop on wrap
--          05    conena    r/w/-    con enable
--          04    remena    r/w/-    rem enable
--          03    locena    r/w/-    loc enable
--       02:00    func      0/-/f    change run status if != noop
--                                     0xx  noop
--                                     100  sto  stop
--                                     101  sta  start and latch all options
--                                     110  sus  suspend  (noop if not started)
--                                     111  res  resume   (noop if not started)
--  001         stat        r/w/-  Status register
--       15:13    bsize     r/-/-    buffer size (AWIDTH-9)
--          02    wrap      r/-/-    line address wrapped (cleared on start)
--          01    susp      r/-/-    suspended
--          00    run       r/-/-    running (can be suspended)
--  010  12:01  hilim       r/w/-  upper address limit, inclusive (def: 177776)
--  011  12:01  lolim       r/w/-  lower address limit, inclusive (def: 160000)
--  100         addr        r/w/-  Address register
--        *:02    laddr     r/w/-    line address
--       01:00    waddr     r/w/-    word address
--  101         data        r/w/-  Data register
--
--     data format:
--     word 3     15 : burst      (2nd re/we in a aval sequence)
--                14 : tout       (busy in last re-we cycle)
--                13 : nak        (no ack in last non-busy cycle)
--                12 : ack        (ack  seen)
--                11 : busy       (busy seen)
--                10 : --         (reserved)
--                09 : we         (write cycle)
--                08 : rmw        (read-modify-write)
--             07:00 : nbusy      (number of busy cycles)
--     word 2        : ndly       (delay to previous request)
--     word 1        : data
--     word 0     15 : be1        (byte enable low)
--                14 : be0        (byte enable high)
--                13 : racc       (remote access)
--             12:01 : addr       (word address)
--                 0 : cacc       (console access)
-- 


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.slvtypes.all;
use work.memlib.all;
use work.iblib.all;

-- Note: AWIDTH has type natural to allow AWIDTH=0 can be used in if generates
--       to control the instantiation. ghdl checks even for not instantiated
--       entities the validity of generics, that's why natural needed here ....

entity ibd_ibmon is                     -- ibus dev: ibus monitor
  generic (
    IB_ADDR : slv16 := slv(to_unsigned(8#160000#,16));  -- base address
    AWIDTH : natural := 9);                             -- buffer size
  port (
    CLK  : in slbit;                    -- clock
    RESET : in slbit;                   -- reset
    IB_MREQ : in ib_mreq_type;          -- ibus: request
    IB_SRES : out ib_sres_type;         -- ibus: response
    IB_SRES_SUM : in ib_sres_type       -- ibus: response (sum for monitor)
  );
end entity ibd_ibmon;


architecture syn of ibd_ibmon is

  constant ibaddr_cntl  : slv3 := "000";   -- cntl  address offset
  constant ibaddr_stat  : slv3 := "001";   -- stat  address offset
  constant ibaddr_hilim : slv3 := "010";   -- hilim address offset
  constant ibaddr_lolim : slv3 := "011";   -- lolim address offset
  constant ibaddr_addr  : slv3 := "100";   -- addr  address offset
  constant ibaddr_data  : slv3 := "101";   -- data  address offset

  constant cntl_ibf_rcolw    : integer :=     8;
  constant cntl_ibf_rcolr    : integer :=     7;
  constant cntl_ibf_wstop    : integer :=     6;
  constant cntl_ibf_conena   : integer :=     5;
  constant cntl_ibf_remena   : integer :=     4;
  constant cntl_ibf_locena   : integer :=     3;
  subtype  cntl_ibf_func    is integer range  2 downto  0;
  
  subtype  stat_ibf_bsize   is integer range 15 downto 13;
  constant stat_ibf_wrap     : integer :=     2;
  constant stat_ibf_susp     : integer :=     1;
  constant stat_ibf_run      : integer :=     0;
  
  subtype  addr_ibf_laddr   is integer range 2+AWIDTH-1 downto  2;
  subtype  addr_ibf_waddr   is integer range  1 downto  0;

  subtype  iba_ibf_pref     is integer range 15 downto 13;
  subtype  iba_ibf_addr     is integer range 12 downto  1;

  constant dat3_ibf_burst    : integer :=    15;
  constant dat3_ibf_tout     : integer :=    14;
  constant dat3_ibf_nak      : integer :=    13;
  constant dat3_ibf_ack      : integer :=    12;
  constant dat3_ibf_busy     : integer :=    11;
  constant dat3_ibf_we       : integer :=     9;
  constant dat3_ibf_rmw      : integer :=     8;
  subtype  dat3_ibf_nbusy   is integer range  7 downto  0;
  constant dat0_ibf_be1      : integer :=    15;
  constant dat0_ibf_be0      : integer :=    14;
  constant dat0_ibf_racc     : integer :=    13;
  subtype  dat0_ibf_addr    is integer range 12 downto  1;
  constant dat0_ibf_cacc     : integer :=     0;

  constant func_sto : slv3 := "100";    -- func: stop
  constant func_sta : slv3 := "101";    -- func: start
  constant func_sus : slv3 := "110";    -- func: suspend
  constant func_res : slv3 := "111";    -- func: resume

  type regs_type is record              -- state registers
    ibsel  : slbit;                     -- ibus select
    rcolw  : slbit;                     -- rcolw flag (repeat collect writes)
    rcolr  : slbit;                     -- rcolr flag (repeat collect reads)
    wstop  : slbit;                     -- wstop flag (stop on wrap)
    conena : slbit;                     -- conena flag (record console access)
    remena : slbit;                     -- remena flag (record remote access)
    locena : slbit;                     -- locena flag (record local access)
    susp   : slbit;                     -- suspended flag
    go     : slbit;                     -- go flag (actively running)
    hilim  : slv13_1;                   -- upper address limit
    lolim  : slv13_1;                   -- lower address limit
    wrap   : slbit;                     -- laddr wrap flag
    laddr  : slv(AWIDTH-1 downto 0);    -- line address
    waddr  : slv2;                      -- word address
    addrsame: slbit;                    -- curr ib addr equal last ib addr
    addrwind: slbit;                    -- curr ib addr in [lolim,hilim] window
    aval_1  : slbit;                    -- last cycle aval
    arm1r   : slbit;                    -- 1st level arm for read
    arm2r   : slbit;                    -- 2nd level arm for read
    arm1w   : slbit;                    -- 1st level arm for write
    arm2w   : slbit;                    -- 2nd level arm for write
    rcol    : slbit;                    -- repeat collaps
    ibtake_1: slbit;                    -- ib capture active in last cycle
    ibaddr  : slv13_1;                  -- ibus trace: addr
    ibwe    : slbit;                    -- ibus trace: we
    ibrmw   : slbit;                    -- ibus trace: rmw
    ibbe0   : slbit;                    -- ibus trace: be0
    ibbe1   : slbit;                    -- ibus trace: be1
    ibcacc  : slbit;                    -- ibus trace: cacc
    ibracc  : slbit;                    -- ibus trace: racc
    iback   : slbit;                    -- ibus trace: ack  seen
    ibbusy  : slbit;                    -- ibus trace: busy seen
    ibnak   : slbit;                    -- ibus trace: nak  detected
    ibtout  : slbit;                    -- ibus trace: tout detected
    ibburst : slbit;                    -- ibus trace: burst detected
    ibdata  : slv16;                    -- ibus trace: data
    ibnbusy : slv8;                     -- ibus number of busy cycles
    ibndly  : slv16;                    -- ibus delay to prev. access
  end record regs_type;

  constant laddrzero : slv(AWIDTH-1 downto 0) := (others=>'0');
  constant laddrlast : slv(AWIDTH-1 downto 0) := (others=>'1');
  
  constant regs_init : regs_type := (
    '0',                                -- ibsel
    '0','0','0',                        -- rcolw,rcolr,wstop
    '1','1','1',                        -- conena,remena,locena
    '0','1',                            -- susp,go
    (others=>'1'),                      -- hilim (def: 177776)
    (others=>'0'),                      -- lolim (def: 160000)
    '0',                                -- wrap
    laddrzero,                          -- laddr
    "00",                               -- waddr
    '0','0','0',                        -- addrsame,addrwind,aval_1
    '0','0','0','0','0',                -- arm1r,arm2r,arm1w,arm2w,rcol
    '0',                                -- ibtake_1
    (others=>'0'),                      -- ibaddr (startup: 160000)
    '0','0','0','0','0','0',            -- ibwe,ibrmw,ibbe0,ibbe1,ibcacc,ibracc
    '0','0',                            -- iback,ibbusy
    '0','0','0',                        -- ibnak,ibtout,ibburst
    (others=>'0'),                      -- ibdata
    (others=>'0'),                      -- ibnbusy
    (others=>'0')                       -- ibndly
  );

  constant ibnbusylast : slv8  := (others=>'1');
  constant ibndlylast  : slv16 := (others=>'1');

  signal R_REGS : regs_type := regs_init;
  signal N_REGS : regs_type := regs_init;

  signal BRAM_EN : slbit := '0';
  signal BRAM_WE : slbit := '0';
  signal BRAM0_DI : slv32 := (others=>'0');
  signal BRAM1_DI : slv32 := (others=>'0');
  signal BRAM0_DO : slv32 := (others=>'0');
  signal BRAM1_DO : slv32 := (others=>'0');
  signal BRAM_ADDR : slv(AWIDTH-1 downto 0) := (others=>'0');
  
begin

  assert AWIDTH>=9 and AWIDTH<=14 
    report "assert(AWIDTH>=9 and AWIDTH<=14): unsupported AWIDTH"
    severity failure;

  BRAM1 : ram_1swsr_wfirst_gen
    generic map (
      AWIDTH => AWIDTH,
      DWIDTH => 32)
    port map (
      CLK   => CLK,
      EN    => BRAM_EN,
      WE    => BRAM_WE,
      ADDR  => BRAM_ADDR,
      DI    => BRAM1_DI,
      DO    => BRAM1_DO
    );

  BRAM0 : ram_1swsr_wfirst_gen
    generic map (
      AWIDTH => AWIDTH,
      DWIDTH => 32)
    port map (
      CLK   => CLK,
      EN    => BRAM_EN,
      WE    => BRAM_WE,
      ADDR  => BRAM_ADDR,
      DI    => BRAM0_DI,
      DO    => BRAM0_DO
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

  proc_next : process (R_REGS, IB_MREQ, IB_SRES_SUM, BRAM0_DO, BRAM1_DO)
    variable r : regs_type := regs_init;
    variable n : regs_type := regs_init;
    variable iib_ack  : slbit := '0';
    variable iib_busy : slbit := '0';
    variable iib_dout  : slv16 := (others=>'0');
    variable iibena  : slbit := '0';
    variable ibramen : slbit := '0';    -- BRAM enable
    variable ibramwe : slbit := '0';    -- BRAN we
    variable ibtake : slbit := '0';
    variable laddr_inc : slbit := '0';
    variable idat0 : slv16 := (others=>'0');
    variable idat1 : slv16 := (others=>'0');
    variable idat2 : slv16 := (others=>'0');
    variable idat3 : slv16 := (others=>'0');
    variable iaddrinc : slv(AWIDTH-1 downto 0) := (others=>'0');
    variable iaddroff : slv(AWIDTH-1 downto 0) := (others=>'0');
  begin

    r := R_REGS;
    n := R_REGS;

    iib_ack  := '0';
    iib_busy := '0';
    iib_dout := (others=>'0');

    iibena  := IB_MREQ.re or IB_MREQ.we;
        
    ibramen := '0';
    ibramwe := '0';

    laddr_inc := '0';
    
    -- ibus address decoder
    n.ibsel := '0';
    if IB_MREQ.aval='1' and IB_MREQ.addr(12 downto 4)=IB_ADDR(12 downto 4) then
      n.ibsel := '1';
      ibramen := '1';                   -- ensures bram read before ibus read
    end if;

    -- ibus transactions (react only on rem access; invisible on loc side)
    if r.ibsel = '1' and IB_MREQ.racc='1' then

      iib_ack := iibena;                -- ack all accesses

      case IB_MREQ.addr(3 downto 1) is

        when ibaddr_cntl =>                 -- cntl ------------------
          if IB_MREQ.we = '1' then
            case IB_MREQ.din(cntl_ibf_func) is
              when func_sto =>                -- func: stop ------------
                n.go    := '0';
                n.susp  := '0';
              when func_sta =>                -- func: start -----------
                n.rcolw  := IB_MREQ.din(cntl_ibf_rcolw);
                n.rcolr  := IB_MREQ.din(cntl_ibf_rcolr);
                n.wstop  := IB_MREQ.din(cntl_ibf_wstop);
                n.conena := IB_MREQ.din(cntl_ibf_conena);
                n.remena := IB_MREQ.din(cntl_ibf_remena);
                n.locena := IB_MREQ.din(cntl_ibf_locena);
                n.go     := '1';
                n.susp   := '0';
                n.wrap   := '0';
                n.laddr  := laddrzero;
                n.waddr  := "00";
              when func_sus =>                -- func: susp ------------
                if r.go = '1' then              -- noop unless running
                  n.go     := '0';
                  n.susp   := r.go;
                end if;
              when func_res =>                -- func: resu ------------
                n.go     := r.susp;
                n.susp   := '0';
              when others => null;            -- <> --------------------
            end case;
          end if;
          
        when ibaddr_stat => null;           -- stat ------------------

        when ibaddr_hilim =>                -- hilim -----------------
          if IB_MREQ.we = '1' then
            n.hilim := IB_MREQ.din(iba_ibf_addr);
          end if;
          
        when ibaddr_lolim =>                -- lolim -----------------
          if IB_MREQ.we = '1' then
            n.lolim := IB_MREQ.din(iba_ibf_addr);
          end if;
          
        when ibaddr_addr =>                 -- addr ------------------
          if IB_MREQ.we = '1' then
            if r.go = '0' then                -- if not active OK
              n.laddr := IB_MREQ.din(addr_ibf_laddr);
              n.waddr := IB_MREQ.din(addr_ibf_waddr);
            else
              iib_ack := '0';                 -- otherwise error, do nak
            end if;
          end if;

        when ibaddr_data =>                 -- data ------------------
          -- write to data is an error, do nak
          if IB_MREQ.we='1' then
            iib_ack := '0';
          end if;
          -- read to data always allowed, addr only incremented when not active
          if IB_MREQ.re = '1' and r.go = '0' then
            n.waddr := slv(unsigned(r.waddr) + 1);
            if r.waddr = "11" then
              laddr_inc := '1';
            end if;
          end if;

        when others =>                      -- <> --------------------
          iib_ack := '0';                     -- error, do nak
          
      end case;
    end if;

    -- ibus output driver
    if r.ibsel = '1' then
      case IB_MREQ.addr(3 downto 1) is
        when ibaddr_cntl =>                 -- cntl ------------------
          iib_dout(cntl_ibf_rcolw)  := r.rcolw;
          iib_dout(cntl_ibf_rcolr)  := r.rcolr;
          iib_dout(cntl_ibf_wstop)  := r.wstop;
          iib_dout(cntl_ibf_conena) := r.conena;
          iib_dout(cntl_ibf_remena) := r.remena;
          iib_dout(cntl_ibf_locena) := r.locena;
        when ibaddr_stat =>                 -- stat ------------------
          iib_dout(stat_ibf_bsize) := slv(to_unsigned(AWIDTH-9,3));
          iib_dout(stat_ibf_wrap)  := r.wrap;
          iib_dout(stat_ibf_susp)  := r.susp;         -- started and suspended
          iib_dout(stat_ibf_run)   := r.go or r.susp; -- started
        when ibaddr_hilim =>                -- hilim -----------------
          iib_dout(iba_ibf_pref)   := (others=>'1');
          iib_dout(iba_ibf_addr)   := r.hilim;
        when ibaddr_lolim =>                -- lolim -----------------
          iib_dout(iba_ibf_pref)   := (others=>'1');
          iib_dout(iba_ibf_addr)   := r.lolim;
        when ibaddr_addr =>                 -- addr ------------------
          iib_dout(addr_ibf_laddr) := r.laddr;
          iib_dout(addr_ibf_waddr) := r.waddr;
        when ibaddr_data =>                 -- data ------------------
          case r.waddr is
            when "11" => iib_dout := BRAM1_DO(31 downto 16);
            when "10" => iib_dout := BRAM1_DO(15 downto  0);
            when "01" => iib_dout := BRAM0_DO(31 downto 16);
            when "00" => iib_dout := BRAM0_DO(15 downto  0);
            when others => null;
          end case;
        when others => null;
      end case;
    end if;

    -- ibus monitor 
    --   a ibus transaction are captured if the address is in alim window
    --   and the access is not refering to ibd_ibmon itself
    
    -- ibus address monitor
    if IB_MREQ.aval='1' and r.aval_1='0' then
      n.ibaddr := IB_MREQ.addr;
      n.addrsame := '0';
      if IB_MREQ.addr = r.ibaddr then
        n.addrsame := '1';
      end if;
      n.addrwind := '0';
      if unsigned(IB_MREQ.addr)>=unsigned(r.lolim) and   -- and in addr window
         unsigned(IB_MREQ.addr)<=unsigned(r.hilim) then
        n.addrwind := '1';
      end if;
    end if;
    n.aval_1 := IB_MREQ.aval;
    
    -- ibus data  monitor
    if IB_MREQ.aval='1' and iibena='1' then   -- aval and (re or we)
      if IB_MREQ.we='1' then                -- for write of din
        n.ibdata := IB_MREQ.din;
      else                                  -- for read of dout
        n.ibdata := IB_SRES_SUM.dout;
      end if;
    end if;
      
    -- track state and decide on storage
    ibtake := '0';
    if IB_MREQ.aval='1' and iibena='1' then   -- aval and (re or we)
      if r.addrwind='1' and r.ibsel='0' then    -- and in window and not self
        if (r.locena='1' and IB_MREQ.cacc='0' and IB_MREQ.racc='0') or
           (r.remena='1' and IB_MREQ.racc='1') or
           (r.conena='1' and IB_MREQ.cacc='1') then
          ibtake := '1';
        end if;
      end if;
    end if;

    if ibtake = '1' then                -- if capture active
      n.ibwe   := IB_MREQ.we;             -- keep track of some state
      n.ibrmw  := IB_MREQ.rmw;
      n.ibbe0  := IB_MREQ.be0;
      n.ibbe1  := IB_MREQ.be1;
      n.ibcacc := IB_MREQ.cacc;
      n.ibracc := IB_MREQ.racc;
      
      if r.ibtake_1 = '0' then            -- if initial cycle of a transaction
        n.iback  := IB_SRES_SUM.ack;
        n.ibbusy := IB_SRES_SUM.busy;
        n.ibnbusy := (others=>'0');
      else                                -- if non-initial cycles
        n.iback  := r.iback or IB_SRES_SUM.ack;
        if r.ibnbusy /= ibnbusylast then      -- and count  
          n.ibnbusy := slv(unsigned(r.ibnbusy) + 1);
        end if;
      end if;
      n.ibnak  := not IB_SRES_SUM.ack;
      n.ibtout := IB_SRES_SUM.busy;

      if IB_SRES_SUM.busy = '0' then    -- if last cycle of a transaction
        n.arm1r := r.rcolr and IB_MREQ.re;
        n.arm1w := r.rcolw and IB_MREQ.we;
        n.arm2r := r.arm1r and r.addrsame and IB_MREQ.re;
        n.arm2w := r.arm1w and r.addrsame and IB_MREQ.we;
        n.rcol  := ((r.arm2r and IB_MREQ.re) or
                    (r.arm2w and IB_MREQ.we)) and r.addrsame;
      end if;
      
    else                                -- if capture not active
      if r.go='1' and r.ibtake_1='1' then -- active and transaction just ended
        ibramen := '1';
        ibramwe := '1';
        laddr_inc := '1';
        n.ibburst := '1';                   -- assume burst
      end if;
      if r.ibtake_1 = '1' then            -- ibus transaction just ended
        n.ibndly := (others=>'0');          -- clear delay counter
      else                                -- just idle
        if r.ibndly /= ibndlylast then      -- count cycles
          n.ibndly := slv(unsigned(r.ibndly) + 1);
        end if;
      end if;
    end if;

    if IB_MREQ.aval = '0' then          -- if aval gone
      n.ibburst := '0';                   -- clear burst flag
    end if;

    iaddrinc := (others=>'0');
    iaddroff := (others=>'0');
    iaddrinc(0) := not (r.rcol and r.go);
    iaddroff(0) :=     (r.rcol and r.go);
    
    if laddr_inc = '1' then
      n.laddr := slv(unsigned(r.laddr) + unsigned(iaddrinc));
      if r.go='1' and r.laddr=laddrlast then
        n.wrap := '1';
        if r.wstop = '1' then
          n.go   := '0';
        end if;
      end if;
    end if;
    
    idat3 := (others=>'0');
    idat3(dat3_ibf_burst)  := r.ibburst;
    idat3(dat3_ibf_tout)   := r.ibtout;
    idat3(dat3_ibf_nak)    := r.ibnak;
    idat3(dat3_ibf_ack)    := r.iback;
    idat3(dat3_ibf_busy)   := r.ibbusy;
    idat3(dat3_ibf_we)     := r.ibwe;
    idat3(dat3_ibf_rmw)    := r.ibrmw;
    idat3(dat3_ibf_nbusy)  := r.ibnbusy;
    idat2                  := r.ibndly;
    idat1                  := r.ibdata;
    idat0(dat0_ibf_be1)    := r.ibbe1;
    idat0(dat0_ibf_be0)    := r.ibbe0;
    idat0(dat0_ibf_racc)   := r.ibracc;
    idat0(dat0_ibf_addr)   := r.ibaddr;
    idat0(dat0_ibf_cacc)   := r.ibcacc;
    
    n.ibtake_1 := ibtake;
    
    N_REGS <= n;

    BRAM_EN   <= ibramen;
    BRAM_WE   <= ibramwe;
    BRAM_ADDR <= slv(unsigned(R_REGS.laddr) - unsigned(iaddroff));
    
    BRAM1_DI  <= idat3 & idat2;
    BRAM0_DI  <= idat1 & idat0;
      
    IB_SRES.dout <= iib_dout;
    IB_SRES.ack  <= iib_ack;
    IB_SRES.busy <= iib_busy;

  end process proc_next;

end syn;
