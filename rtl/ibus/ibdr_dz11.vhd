-- $Id: ibdr_dz11.vhd 1181 2019-07-08 17:00:50Z mueller $
-- SPDX-License-Identifier: GPL-3.0-or-later
-- Copyright 2019- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
--
------------------------------------------------------------------------------
-- Module Name:    ibdr_dz11 - syn
-- Description:    ibus dev(rem): DZ11
--
-- Dependencies:   fifo_simple_dram
--                 ib_rlim_slv
-- Test bench:     xxdp: zdzaj0
-- Target Devices: generic
-- Tool versions:  ise 8.2-14.7; 2017.2; ghdl 0.35
--
-- Revision History: 
-- Date         Rev Version  Comment
-- 2019-05-19  1150   1.0    Initial version
-- 2019-05-01  1144   0.1    First draft
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.slvtypes.all;
use work.memlib.all;
use work.iblib.all;

-- ----------------------------------------------------------------------------
entity ibdr_dz11 is                     -- ibus dev(rem): DZ11
                                        -- fixed address: 160100
  generic (
    IB_ADDR : slv16 := slv(to_unsigned(8#160100#,16));
    AWIDTH : natural :=  5);            -- fifo address width
  port (
    CLK : in slbit;                     -- clock
    RESET : in slbit;                   -- system reset
    BRESET : in slbit;                  -- ibus reset
    RLIM_CEV : in  slv8;                -- clock enable vector
    RB_LAM : out slbit;                 -- remote attention
    IB_MREQ : in ib_mreq_type;          -- ibus request
    IB_SRES : out ib_sres_type;         -- ibus response
    EI_REQ_RX : out slbit;              -- interrupt request, receiver
    EI_REQ_TX : out slbit;              -- interrupt request, transmitter
    EI_ACK_RX : in slbit;               -- interrupt acknowledge, receiver
    EI_ACK_TX : in slbit                -- interrupt acknowledge, transmitter
  );
end ibdr_dz11;

architecture syn of ibdr_dz11 is

  -- loc view register naming, offsets and bit definitions
  constant ibaddr_csr      : slv2 := "00";  -- csr      address offset
  constant ibaddr_rbuf_lpr : slv2 := "01";  -- rbuf/lpr address offset
  constant ibaddr_tcr      : slv2 := "10";  -- tcr      address offset
  constant ibaddr_msr_tdr  : slv2 := "11";  -- msr/tdr  address offset

  constant csr_ibf_trdy :   integer := 15;
  constant csr_ibf_tie :    integer := 14;
  constant csr_ibf_sa :     integer := 13;
  constant csr_ibf_sae :    integer := 12;
  subtype  csr_ibf_tline    is integer range 10 downto  8;
  constant csr_ibf_rdone :  integer :=  7;
  constant csr_ibf_rie :    integer :=  6;
  constant csr_ibf_mse :    integer :=  5;
  constant csr_ibf_clr :    integer :=  4;
  constant csr_ibf_maint :  integer :=  3;

  constant rbuf_ibf_val :   integer := 15;
  constant rbuf_ibf_ferr :  integer := 13;
  subtype  rbuf_ibf_line    is integer range 10 downto  8;
  subtype  rbuf_ibf_data    is integer range  7 downto  0;

  constant lpr_ibf_rxon :   integer := 12;
  subtype  lpr_ibf_line     is integer range  2 downto  0;

  subtype  tcr_ibf_dtr      is integer range 15 downto  8;
  subtype  tcr_ibf_lena     is integer range  7 downto  0;

  subtype  msr_ibf_co       is integer range 15 downto  8;
  subtype  msr_ibf_ring     is integer range  7 downto  0;

  subtype  tdr_ibf_brk      is integer range 15 downto  8;
  subtype  tdr_ibf_tbuf     is integer range  7 downto  0;

  -- rem view register naming, offsets and bit definitions
  constant ibaddr_cntl : slv2 := "00";  -- cntl address offset
  constant ibaddr_stat : slv2 := "01";  -- stat address offset
  constant ibaddr_fuse : slv2 := "10";  -- fuse address offset
  constant ibaddr_fdat : slv2 := "11";  -- fdat address offset

  -- rem-r view
  subtype  cntl_ibf_awdth   is integer range 10 downto  8;
  subtype  cntl_ibf_ssel    is integer range  4 downto  3;  -- also wr
  constant cntl_ibf_sam:    integer :=  7;                  -- also wr
  constant cntl_ibf_mse :   integer :=  2;
  constant cntl_ibf_maint : integer :=  1;
  -- rem-w view
  subtype  cntl_ibf_data    is integer range 15 downto  8;
  subtype  cntl_ibf_rrlim   is integer range 14 downto 12;
  subtype  cntl_ibf_trlim   is integer range 10 downto  8;
  constant cntl_ibf_rclr :  integer :=  6;
  constant cntl_ibf_tclr :  integer :=  5;
  --       cntl_ibf_ssel    is integer range  4 downto  3;
  subtype  cntl_ibf_func    is integer range  2 downto  0;
  
  constant func_noop   : slv3 := "000";   -- func: noop
  constant func_sco    : slv3 := "001";   -- func: set CO
  constant func_sring  : slv3 := "010";   -- func: set RING
  constant func_srlim  : slv3 := "011";   -- func: set RLIM

  constant ssel_dtle   : slv2 := "00";    -- ssel: get DTR  and LENA
  constant ssel_brrx   : slv2 := "01";    -- ssel: get BRK  and RXON
  constant ssel_cori   : slv2 := "10";    -- ssel: get CO   and RING
  constant ssel_rlcn   : slv2 := "11";    -- ssel: get RLIM and CNTL
  
  constant cal_dtr     : slv3 := "000";   -- cal: DTR
  constant cal_brk     : slv3 := "001";   -- cal: BRK
  constant cal_rxon    : slv3 := "010";   -- cal: RXON
  constant cal_csr     : slv3 := "011";   -- cal: CSR
  
  subtype  sdlle_ibf_dtr    is integer range 15 downto  8;
  subtype  sdlle_ibf_lena   is integer range  7 downto  0;
  subtype  sbrrx_ibf_brk    is integer range 15 downto  8;
  subtype  sbrrx_ibf_rxon   is integer range  7 downto  0;
  subtype  scori_ibf_co     is integer range 15 downto  8;
  subtype  scori_ibf_ring   is integer range  7 downto  0;
  subtype  srlcn_ibf_rrlim  is integer range 14 downto 12;
  subtype  srlcn_ibf_trlim  is integer range 10 downto  8;  
  constant srlcn_ibf_rir :  integer :=  7;
  constant srlcn_ibf_tir :  integer :=  6;
  constant srlcn_ibf_mse :  integer :=  5;
  constant srlcn_ibf_maint: integer :=  3;

  subtype  fuse_ibf_rsize   is integer range AWIDTH-1+8 downto 8;
  subtype  fuse_ibf_tsize   is integer range AWIDTH-1   downto 0;

  constant fdat_ibf_val :   integer := 15;
  constant fdat_ibf_last :  integer := 14;
  constant fdat_ibf_ferr :  integer := 13;
  constant fdat_ibf_cal  :  integer := 11;
  subtype  fdat_ibf_line    is integer range 10 downto  8;
  subtype  fdat_ibf_data    is integer range  7 downto  0;
  
  constant fbuf_ibf_cal :   integer := 12;
  constant fbuf_ibf_ferr :  integer := 11;
  subtype  fbuf_ibf_line    is integer range 10 downto  8;
  subtype  fbuf_ibf_data    is integer range  7 downto  0;
  
  type regs_type is record              -- state registers
    ibsel : slbit;                      -- ibus select
    ssel : slv2;                        -- rcsr: status select
    rrlim : slv3;                       -- rcsr: receiver rate limit
    trlim : slv3;                       -- rcsr: transmitter rate limit
    dtr : slv8;                         -- line state: dtr
    lena : slv8;                        -- line state: lena
    brk : slv8;                         -- line state: brk
    rxon : slv8;                        -- line state: rxon
    co : slv8;                          -- line state: co
    ring : slv8;                        -- line state: ring
    trdy : slbit;                       -- csr: transmitter ready
    tie : slbit;                        -- csr: transmitter ie
    sa : slbit;                         -- csr: silo alarm
    sae : slbit;                        -- csr: silo alarm enable
    tline : slv3;                       -- csr: transmit line
    rdone : slbit;                      -- csr: receiver done
    rie : slbit;                        -- csr: receiver ie
    mse : slbit;                        -- csr: master scan enable
    clr : slbit;                        -- csr: clear
    maint : slbit;                      -- csr: maintenance mode
    sam : slbit;                        -- sae monitor
    lcnt : slv3;                        -- line counter
    scnt : slv5;                        -- silo counter
    qdtr : slbit;                       -- queue DTR alert
    qbrk : slbit;                       -- queue BRK alert
    qrxon : slbit;                      -- queue RXON alert
    qcsr : slbit;                       -- queue CSR alert
    qclr : slbit;                       -- queue CLR alert
    rintreq : slbit;                    -- rx interrupt request
    tintreq : slbit;                    -- tx interrupt request
  end record regs_type;
  
  constant regs_init : regs_type := (
    '0',                                -- ibsel
    "00","000","000",                   -- ssel,rrlim,trlim
    (others=>'0'),                      -- dtr
    (others=>'0'),                      -- lena
    (others=>'0'),                      -- brk
    (others=>'0'),                      -- rxon
    (others=>'0'),                      -- co
    (others=>'0'),                      -- ring
    '0','0','0','0',                    -- trdy,tie,sa,sae
    "000",                              -- tline
    '0','0','0','0','0',                -- rdone,rie,mse,clr,maint
    '0',                                -- sam
    (others=>'0'),                      -- lcnt
    (others=>'0'),                      -- scnt
    '0','0','0','0','0',                -- qdtr,qbrk,qrxon,qcsr,qclr
    '0','0'                             -- rintreq,tintreq
    );

  constant c_fuse1 : slv(AWIDTH-1 downto 0) := slv(to_unsigned(1,AWIDTH));
  
  signal R_REGS : regs_type := regs_init;
  signal N_REGS : regs_type := regs_init;
  
  signal RBUF_CE : slbit := '0';
  signal RBUF_WE : slbit := '0';
  signal RBUF_DI : slv12 := (others=>'0');
  signal RBUF_DO : slv12 := (others=>'0');
  signal RBUF_RESET : slbit := '0';
  signal RBUF_EMPTY : slbit := '0';
  signal RBUF_FULL  : slbit := '0';
  signal RBUF_FUSE  : slv(AWIDTH-1 downto 0) := (others=>'0');
  
  signal TBUF_CE : slbit := '0';
  signal TBUF_WE : slbit := '0';
  signal TBUF_DI : slv13 := (others=>'0');
  signal TBUF_DO : slv13 := (others=>'0');
  signal TBUF_RESET : slbit := '0';
  signal TBUF_EMPTY : slbit := '0';
  signal TBUF_FULL  : slbit := '0';
  signal TBUF_FUSE  : slv(AWIDTH-1 downto 0) := (others=>'0');
  
  signal RRLIM_START : slbit := '0';
  signal RRLIM_BUSY  : slbit := '0';
  signal TRLIM_START : slbit := '0';
  signal TRLIM_BUSY  : slbit := '0';

  pure function toint (val : slv3) return integer is
  begin
    return to_integer(unsigned(val));
  end function toint;

begin
  assert AWIDTH>=5 and AWIDTH<=7 
    report "assert(AWIDTH>=5 and AWIDTH<=7): unsupported AWIDTH"
    severity failure;
  
  RBUF : fifo_simple_dram
    generic map (
      AWIDTH => AWIDTH,
      DWIDTH => 12)                     -- FER+LINE(3)+BUF(8)
    port map (
      CLK   => CLK,
      RESET => RBUF_RESET,
      CE    => RBUF_CE,
      WE    => RBUF_WE,
      DI    => RBUF_DI,
      DO    => RBUF_DO,
      EMPTY => RBUF_EMPTY,
      FULL  => RBUF_FULL,
      SIZE  => RBUF_FUSE
    );
    
  TBUF : fifo_simple_dram
    generic map (
      AWIDTH => AWIDTH,
      DWIDTH => 13)                     -- CAL+FER+LINE(3)+BUF(8)
    port map (
      CLK   => CLK,
      RESET => TBUF_RESET,
      CE    => TBUF_CE,
      WE    => TBUF_WE,
      DI    => TBUF_DI,
      DO    => TBUF_DO,
      EMPTY => TBUF_EMPTY,
      FULL  => TBUF_FULL,
      SIZE  => TBUF_FUSE
    );  
  
  RRLIM : ib_rlim_slv
    port map (
      CLK      => CLK,
      RESET    => RESET,
      RLIM_CEV => RLIM_CEV,
      SEL      => R_REGS.rrlim,
      START    => RRLIM_START,
      STOP     => BRESET,
      DONE     => open,
      BUSY     => RRLIM_BUSY
    );

  TRLIM : ib_rlim_slv
    port map (
      CLK      => CLK,
      RESET    => RESET,
      RLIM_CEV => RLIM_CEV,
      SEL      => R_REGS.trlim,
      START    => TRLIM_START,
      STOP     => BRESET,
      DONE     => open,
      BUSY     => TRLIM_BUSY
    );
  
  proc_regs: process (CLK)
  begin
    if rising_edge(CLK) then
      if BRESET='1' or R_REGS.clr='1' then
        R_REGS <= regs_init;
        if RESET = '0' then               -- if RESET=0 we do just an ibus reset
          R_REGS.ssel  <= N_REGS.ssel;      -- keep SSEL field
          R_REGS.rrlim <= N_REGS.rrlim;     -- keep RRLIM field
          R_REGS.trlim <= N_REGS.trlim;     -- keep TRLIM field
          R_REGS.qclr  <= N_REGS.qclr;      -- keep clr cal request
          R_REGS.dtr   <= N_REGS.dtr;       -- keep DTR  (model cntl)
          R_REGS.co    <= N_REGS.co;        -- keep CO   (model cntl)
          R_REGS.ring  <= N_REGS.ring;      -- keep RING (model cntl)
        end if;
      else
        R_REGS <= N_REGS;
      end if;
    end if;
  end process proc_regs;
  
  proc_next : process (R_REGS, IB_MREQ, EI_ACK_RX, EI_ACK_TX, RESET,
                       RBUF_DO, RBUF_EMPTY, RBUF_FULL, RBUF_FUSE, RRLIM_BUSY,
                       TBUF_DO, TBUF_EMPTY, TBUF_FULL, TBUF_FUSE, TRLIM_BUSY)
    variable r : regs_type := regs_init;
    variable n : regs_type := regs_init;
    variable idout : slv16 := (others=>'0');
    variable ibreq : slbit := '0';
    variable iback : slbit := '0';
    variable ibrd : slbit := '0';
    variable ibwr : slbit := '0';
    variable ibw0 : slbit := '0';
    variable ibw1 : slbit := '0';
    variable ilam : slbit := '0';
    variable irbufdi   : slv12 := (others=>'0');
    variable irbufce   : slbit := '0';
    variable irbufwe   : slbit := '0';
    variable irbufrst  : slbit := '0';
    variable irrlimsta : slbit := '0';
    variable itbufdi   : slv13 := (others=>'0');
    variable itbufce   : slbit := '0';
    variable itbufwe   : slbit := '0';
    variable itbufrst  : slbit := '0';
    variable itrlimsta : slbit := '0';
    variable ixbuffull : slbit := '0';
    variable iscntclr  : slbit := '0';
  begin
    
    r := R_REGS;
    n := R_REGS;

    idout := (others=>'0');
    ibreq := IB_MREQ.re or IB_MREQ.we;
    iback := r.ibsel and ibreq;
    ibrd  := IB_MREQ.re;
    ibwr  := IB_MREQ.we;
    ibw0  := IB_MREQ.we and IB_MREQ.be0;
    ibw1  := IB_MREQ.we and IB_MREQ.be1;
    ilam  := '0';
    irbufdi   := (others=>'0');
    irbufce   := '0';
    irbufwe   := '0';
    irbufrst  := RESET and not r.mse;
    irrlimsta := '0';
    itbufdi   := (others=>'0');
    itbufce   := '0';
    itbufwe   := '0';
    itbufrst  := RESET;
    itrlimsta := '0';
    iscntclr  := not r.mse;
    
    -- setup for rbuf writes
    if r.maint = '0' then               -- not in maint mode (rem fifo write)
      irbufdi(fbuf_ibf_ferr) := IB_MREQ.din(fdat_ibf_ferr);
      irbufdi(fbuf_ibf_line) := IB_MREQ.din(fdat_ibf_line);
      irbufdi(fbuf_ibf_data) := IB_MREQ.din(fdat_ibf_data);
    else                                -- in maint mode (loc tbuf write)
      irbufdi(fbuf_ibf_ferr) := '0';      -- brk ignored on maint mode
      irbufdi(fbuf_ibf_line) := r.tline;
      irbufdi(fbuf_ibf_data) := IB_MREQ.din(tdr_ibf_tbuf);
    end if;
      
    -- ibus address decoder
    n.ibsel := '0';
    if IB_MREQ.aval='1' and
       IB_MREQ.addr(12 downto 3)=IB_ADDR(12 downto 3) then
      n.ibsel := '1';
    end if;
    
    -- ibus transactions
    if r.ibsel = '1' then               -- ibus selected ---------------------

      -- setup for tbuf writes generated from ibus accesses
      itbufdi(fbuf_ibf_ferr) := r.brk(toint(r.tline));
      itbufdi(fbuf_ibf_line) := r.tline;
      itbufdi(fbuf_ibf_data) := IB_MREQ.din(tdr_ibf_tbuf);
        
      if IB_MREQ.racc = '1' then          -- rri view: rem side access -------
        
        case IB_MREQ.addr(2 downto 1) is

          when ibaddr_cntl =>             -- CNTL -- control --------------
            idout(cntl_ibf_awdth) := slv(to_unsigned(AWIDTH,3));
            idout(cntl_ibf_sam)   := r.sam;
            idout(cntl_ibf_ssel)  := r.ssel;
            idout(cntl_ibf_mse)   := r.mse;
            idout(cntl_ibf_maint) := r.maint;
            if ibwr = '1' then
              if IB_MREQ.din(cntl_ibf_sam) = '1' then
                n.sam := '0';
              end if;
              if IB_MREQ.din(cntl_ibf_rclr) = '1' then
                irbufrst := '1';
              end if;
              if IB_MREQ.din(cntl_ibf_tclr) = '1' then
                itbufrst := '1';
              end if;
              n.ssel := IB_MREQ.din(cntl_ibf_ssel);
              case IB_MREQ.din(cntl_ibf_func) is -- handle cntl.func ------
                when func_sco =>                   -- func: set CO ------
                  n.co    := IB_MREQ.din(cntl_ibf_data);
                when func_sring =>                 -- func: set RING ----
                  n.ring  := IB_MREQ.din(cntl_ibf_data);
                when func_srlim =>                 -- func: set RLIM ----
                  n.rrlim := IB_MREQ.din(cntl_ibf_rrlim);
                  n.trlim := IB_MREQ.din(cntl_ibf_trlim);
                when others => null;
              end case;
            end if;

          when ibaddr_stat =>             -- STAT -- status ---------------
            case r.ssel is
              when ssel_dtle =>             -- ssel: get DTR  and LENA
                idout(sdlle_ibf_dtr)  := r.dtr;
                idout(sdlle_ibf_lena) := r.lena;
              when ssel_brrx =>             -- ssel: get BRK  and RXON
                idout(sbrrx_ibf_brk)  := r.brk;
                idout(sbrrx_ibf_rxon) := r.rxon;
              when ssel_cori =>             -- ssel: get CO   and RING
                idout(scori_ibf_co)   := r.co;
                idout(scori_ibf_ring) := r.ring;
              when ssel_rlcn =>             -- ssel: get CNTL and RLIM
                idout(srlcn_ibf_rrlim) := r.rrlim;
                idout(srlcn_ibf_trlim) := r.trlim;
                idout(srlcn_ibf_rir)   := r.rintreq;
                idout(srlcn_ibf_tir)   := r.tintreq;
                idout(srlcn_ibf_mse)   := r.mse;
                idout(srlcn_ibf_maint) := r.maint;
              when others => null;
            end case;
            if ibrd = '1' then            -- advance ssel on read
              n.ssel := slv(unsigned(r.ssel) + 1);
            end if;
            if ibwr = '1' then            -- stat is read-only
              iback := '0';
            end if;

          when ibaddr_fuse =>             -- FUSE -- fifo usage -----------
            idout(fuse_ibf_rsize) := RBUF_FUSE;
            idout(fuse_ibf_tsize) := TBUF_FUSE;
            
          when ibaddr_fdat =>             -- FDAT -- fifo read/write ------
            idout(fdat_ibf_val)  := not TBUF_EMPTY;
            if TBUF_FUSE = c_fuse1 then
              idout(fdat_ibf_last) := '1';
            end if;
            idout(fdat_ibf_ferr) := TBUF_DO(fbuf_ibf_ferr);
            idout(fdat_ibf_cal)  := TBUF_DO(fbuf_ibf_cal);
            idout(fdat_ibf_line) := TBUF_DO(fbuf_ibf_line);
            idout(fdat_ibf_data) := TBUF_DO(fbuf_ibf_data);
            if ibrd = '1' then              -- fifo read
              if TBUF_EMPTY = '0' then        -- fifo not empty
                itbufce := '1';                 -- read from fifo
                itbufwe := '0';
              else                            -- read from empty fifo
                iback := '0';                   -- signal nak
              end if;
            end if;
            if ibwr = '1' then              -- fifo write
              if RBUF_FULL = '0' then         -- fifo not full
                if r.mse='1' and r.maint='0' then -- running and not in maint
                  if r.rxon(toint(IB_MREQ.din(fdat_ibf_line))) = '1' then
                    irbufce  := '1';                -- write to fifo
                    irbufwe  := '1';                -- with default irbufdi
                  else
                    -- usually the backend is woken up to send more data by an
                    -- attn send when the last RBUF value is read. When all
                    -- data is dropped that never happens. So send an attn
                    -- when a value is dropped and the RBUF is empty.
                    if RBUF_EMPTY = '0' then      -- for drop on empty fifo
                      ilam := '1';                  -- ask for more data
                    end if;
                  end if;
                end if;
              else                            -- write to full fifo
                iback := '0';                   -- signal nak
              end if;
            end if;
            
          when others => null;
        end case; -- IB_MREQ.addr
        
      else                                -- cpu view: loc side access -------
        case IB_MREQ.addr(2 downto 1) is
            
          when ibaddr_csr =>              -- CSR  -- control/status -------
            idout(csr_ibf_trdy)  := r.trdy;
            idout(csr_ibf_tie)   := r.tie;
            idout(csr_ibf_sa)    := r.sa;
            idout(csr_ibf_sae)   := r.sae;
            idout(csr_ibf_tline) := r.tline;
            idout(csr_ibf_rdone) := r.rdone;
            idout(csr_ibf_rie)   := r.rie;
            idout(csr_ibf_mse)   := r.mse;
            idout(csr_ibf_clr)   := r.clr;
            idout(csr_ibf_maint) := r.maint;
            if ibw1 = '1' then
              n.tie := IB_MREQ.din(csr_ibf_tie);
              if IB_MREQ.din(csr_ibf_tie) = '1' then
                if r.tie='0' and r.trdy='1' then    -- tie 0->1 and trdy
                  n.rintreq := '1';                   -- request interrupt
                end if;
              else
                n.tintreq := '0';
              end if;
              n.sae := IB_MREQ.din(csr_ibf_sae);
              if IB_MREQ.din(csr_ibf_sae) = '1' then
                n.sam := '1';
              end if;
            end if;
            if ibw0 = '1' then
              n.rie   := IB_MREQ.din(csr_ibf_rie);
              if IB_MREQ.din(csr_ibf_rie) = '1' then
                if r.rie='0' and                    -- rie 0->1
                   ((r.sae='0' and r.rdone='1') or    -- and no silo and rdone 
                    (r.sae='1' and r.sa='1'))         --  or    silo and alarm
                then
                  n.rintreq := '1';
                end if;
              else
                n.rintreq := '0';
              end if;
              n.mse   := IB_MREQ.din(csr_ibf_mse);
              if IB_MREQ.din(csr_ibf_mse) = '0' then    -- mse clear
                n.rdone := '0';
                n.trdy  := '0';
              end if;
              if r.mse /= IB_MREQ.din(csr_ibf_mse) then -- mse change
                n.qcsr := '1';
              end if;
              if IB_MREQ.din(csr_ibf_clr) = '1' then    -- clr set ?
                n.clr  := '1';                            -- request clr
                n.qclr := '1';                            -- queue clr cal
              end if;
              n.maint := IB_MREQ.din(csr_ibf_maint);
              if r.maint /= IB_MREQ.din(csr_ibf_maint) then -- maint change
                n.qcsr := '1';
              end if;
            end if;
            
          when ibaddr_rbuf_lpr =>         -- RBUF/LPR ---------------------
            idout(rbuf_ibf_val)  := r.rdone;
            idout(rbuf_ibf_ferr) := RBUF_DO(fbuf_ibf_ferr);
            idout(rbuf_ibf_line) := RBUF_DO(fbuf_ibf_line);
            idout(rbuf_ibf_data) := RBUF_DO(fbuf_ibf_data);
            if ibrd = '1' then              -- RBUF read
              if r.rdone = '1' then
                irbufce := '1';               -- read next value from fifo
                irbufwe := '0';
                if RBUF_FUSE=c_fuse1 and r.maint='0' then   -- last val ?
                  ilam := '1';                  -- rri lam
                end if;
                n.rdone   := '0';             -- clear rdone
                n.sa      := '0';             -- clear silo alarm
                n.rintreq := '0';             -- clear interrupt
                iscntclr  := '1';             -- clear silo count
              end if;
            end if;
            if ibwr = '1' then              -- LPR write
              n.rxon(toint(IB_MREQ.din(lpr_ibf_line))) :=
                IB_MREQ.din(lpr_ibf_rxon);
              if r.rxon(toint(IB_MREQ.din(lpr_ibf_line))) /=
                   IB_MREQ.din(lpr_ibf_rxon) then -- if changed
                n.qrxon := '1';                     -- queue rxon cal
              end if;
            end if;

          when ibaddr_tcr =>              -- TCR  -- transmit control ---
            idout(tcr_ibf_dtr)   := r.dtr;
            idout(tcr_ibf_lena)  := r.lena;
            if ibw1 = '1' then              -- DTR written
              n.dtr  := IB_MREQ.din(tcr_ibf_dtr);
              if r.dtr /= IB_MREQ.din(tcr_ibf_dtr) then -- if changed
                n.qdtr := '1';                            -- queue dtr cal
              end if;
            end if;
            if ibw0 = '1' then              -- LENA written
              n.lena := IB_MREQ.din(tcr_ibf_lena);
              -- check if ready and active line is disabled
              if r.trdy = '1' and
                 IB_MREQ.din(tcr_ibf_lena)(toint(r.tline)) = '0' then
                n.trdy    := '0';             -- clear ready
                n.tintreq := '0';             -- clear interrupt
              end if;
            end if;
          
          when ibaddr_msr_tdr =>          -- MSR/TDR ----------------------
            idout(msr_ibf_co)    := r.co;
            idout(msr_ibf_ring)  := r.ring;
            if ibw1 = '1' then              -- BRK written
              n.brk  := IB_MREQ.din(tdr_ibf_brk);
              if r.brk /= IB_MREQ.din(tdr_ibf_brk) then -- if changed
                n.qbrk := '1';                            -- queue brk cal
              end if;
            end if;
            if ibw0 = '1' then              -- TBUF written
              if r.trdy = '1' then            -- ignore buf write when rdy=0
                n.trdy    := '0';               -- clear ready
                n.tintreq := '0';               -- clear interrupt
                if r.maint = '0' then           -- not in maint mode
                  if TBUF_FULL = '0' then         -- fifo not full
                    itbufce  := '1';              -- write to fifo
                    itbufwe  := '1';              -- with default itbufdi
                  end if;
                else                            -- in maint mode
                  if RBUF_FULL = '0' then         -- fifo not full
                    if r.rxon(toint(r.tline)) = '1' then -- line enabled ?
                      irbufce  := '1';              -- write to fifo
                      irbufwe  := '1';              -- with default irbufdi
                    end if;                  
                  end if;                  
                end if;
              end if;
            end if;
            
          when others => null;
        end case; -- IB_MREQ.addr
      end if; -- IB_MREQ.racc

      -- silo counter logic
      if iscntclr = '1' then
        n.scnt := (others=>'0');
      elsif irbufwe = '1' then
        if r.scnt(4) = '0' then
          n.scnt := slv(unsigned(r.scnt) + 1);
        end if;
      end if;
      
    else                                -- ibus not selected -----------------
      -- handle rx done, timer and interrupt
      if r.sae = '0' then                 -- silo alarm disabled
        if RBUF_EMPTY='0' and RRLIM_BUSY='0' then -- not empty and not busy ?
          if r.rdone = '0' then                     -- rdone not set ?
            n.rdone   := '1';                         -- set rdone
            irrlimsta := '1';                         -- start timer
            if r.rie = '1' then                       -- rx irupt enabled ?
              n.rintreq := '1';                         -- request rx irupt
            end if;
          end if;          
        end if;

      else                                -- silo alarm enabled
        if RBUF_EMPTY = '0' then            -- not empty ?
          if r.rdone = '0' then               -- rdone not set ?
            n.rdone := '1';                     -- set rdone
            if r.scnt(4)='1' and RRLIM_BUSY='0' then  -- silo16 and not busy ?
              if r.sa = '0' then                      -- sa not set ?
                n.sa      := '1';                        -- set sa
                irrlimsta := '1';                        -- start timer
                if r.rie = '1' then                      -- rx irupt enabled ?
                  n.rintreq := '1';                        -- request rx irupt
                end if;
              end if;
            end if;
          end if;
        end if;

      end if; -- else r.sae='0'
      
      -- handle tx ready, tline, timer and interrupt
      if r.maint = '0' then
        ixbuffull := TBUF_FULL;
      else
        ixbuffull := RBUF_FULL;
      end if;
      
      if ixbuffull='0' and TRLIM_BUSY='0' then  -- not full and not busy ?
        if (r.qdtr or r.qbrk or r.qrxon or r.qcsr) = '0' then -- no cal queued
          if r.mse = '1' and r.trdy = '0' then    -- searching ?
            if r.lena(toint(r.lcnt)) = '1' then     -- line found
              n.tline := r.lcnt;                      -- remember line
              n.trdy  := '1';                         -- set ready
              itrlimsta := '1';                       -- start timer
              if r.tie='1' then
                n.tintreq := '1';                     -- request interrupt
              end if;
            end if;
            -- incrementing lcnt here ensures that the start point for the next
            -- search (n.lcnt) is the line one past the current winner (r.lcnt).
            n.lcnt := slv(unsigned(r.lcnt) + 1);    -- go for next line
          end if;
        end if;
      end if;
     
      -- handle queue change alerts
      if TBUF_FULL = '0' then             -- fifo space available ?
        itbufdi(fbuf_ibf_cal)  := '1';
        if r.qdtr = '1' then                -- cal DTR pending
          n.qdtr := '0';
          itbufdi(fbuf_ibf_line) := cal_dtr;
          itbufdi(fbuf_ibf_data) := r.dtr; 
          itbufce := '1';
          itbufwe := '1';
        elsif r.qbrk = '1' then             -- cal BRK pending
          n.qbrk := '0';
          itbufdi(fbuf_ibf_line) := cal_brk;
          itbufdi(fbuf_ibf_data) := r.brk; 
          itbufce := '1';
          itbufwe := '1';
        elsif r.qrxon = '1' then            -- cal RXON pending
          n.qrxon := '0';
          itbufdi(fbuf_ibf_line) := cal_rxon;
          itbufdi(fbuf_ibf_data) := r.rxon; 
          itbufce := '1';
          itbufwe := '1';
        elsif r.qcsr='1' or r.qclr='1' then  -- cal CSR pending
          n.qcsr := '0';
          n.qclr := '0';
          itbufdi(fbuf_ibf_line) := cal_csr;
          itbufdi(fbuf_ibf_data) := (others=>'0');
          itbufdi(csr_ibf_mse)   := r.mse;
          itbufdi(csr_ibf_clr)   := r.qclr;
          itbufdi(csr_ibf_maint) := r.maint;
          itbufce := '1';
          itbufwe := '1';
        end if;
      end if;
    end if; -- else r.ibsel='1'

    if itbufce='1' and itbufwe='1' then -- write to tx fifo
      if TBUF_EMPTY='1' then              -- first write to empty tx fifo
        ilam     := '1';                    -- request attention
      end if;
    end if;
    
    -- other state changes
  
    if EI_ACK_RX = '1' then
      n.rintreq := '0';
    end if;
    if EI_ACK_TX = '1' then
      n.tintreq := '0';
    end if;

    N_REGS <= n;
    
    RBUF_RESET  <= irbufrst;
    RBUF_CE     <= irbufce;
    RBUF_WE     <= irbufwe;
    RBUF_DI     <= irbufdi;
    RRLIM_START <= irrlimsta;

    TBUF_RESET  <= itbufrst;
    TBUF_CE     <= itbufce;
    TBUF_WE     <= itbufwe;
    TBUF_DI     <= itbufdi;
    TRLIM_START <= itrlimsta;

    IB_SRES.dout <= idout;
    IB_SRES.ack  <= iback;
    IB_SRES.busy <= '0';

    RB_LAM    <= ilam;
    EI_REQ_RX <= r.rintreq;
    EI_REQ_TX <= r.tintreq;
       
  end process proc_next;

end syn;
