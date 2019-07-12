-- $Id: rlink_tba.vhd 1181 2019-07-08 17:00:50Z mueller $
-- SPDX-License-Identifier: GPL-3.0-or-later
-- Copyright 2007-2014 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
--
------------------------------------------------------------------------------
-- Module Name:    rlink_tba - syn
-- Description:    rlink test bench adapter
--
-- Dependencies:   -
-- Test bench:     -
-- Target Devices: generic [synthesizable, but only used in tb's]
-- Tool versions:  xst 8.2-14.7; ghdl 0.18-0.31
--
-- Revision History: 
-- Date         Rev Version  Comment
-- 2014-09-27   595   4.0    now full rlink v4 iface
-- 2014-08-15   583   3.5    rb_mreq addr now 16 bit; add state r_txal;
-- 2011-11-22   432   3.0.2  now numeric_std clean
-- 2011-11-19   427   3.0.1  fix crc8_update usage;
-- 2010-12-24   347   3.0    rename rritba->rlink_tba, CP_*->RL_*; rbus v3 port;
-- 2010-06-18   306   2.5.1  rename rbus data fields to _rbf_
-- 2010-06-07   302   2.5    use sop/eop framing instead of soc+chaining
-- 2010-05-05   289   1.0.3  drop dead snooper code and unneeded unsigned casts
-- 2008-03-02   121   1.0.2  remove snoopers
-- 2007-10-12    88   1.0.1  avoid ieee.std_logic_unsigned, use cast to unsigned
-- 2007-09-09    81   1.0    Initial version 
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.slvtypes.all;
use work.comlib.all;
use work.rlinklib.all;
use work.rlinktblib.all;

entity rlink_tba is                     -- rlink test bench adapter
  port (
    CLK  : in slbit;                    -- clock
    RESET  : in slbit;                  -- reset
    CNTL : in rlink_tba_cntl_type;      -- control port
    DI : in slv16;                      -- input data
    STAT : out rlink_tba_stat_type;     -- status port
    DO : out slv16;                     -- output data
    RL_DI : out slv9;                   -- rlink: data in
    RL_ENA : out slbit;                 -- rlink: data enable
    RL_BUSY : in slbit;                 -- rlink: data busy
    RL_DO : in slv9;                    -- rlink: data out
    RL_VAL : in slbit;                  -- rlink: data valid
    RL_HOLD : out slbit                 -- rlink: data hold
  );
end entity rlink_tba;


architecture syn of rlink_tba is

  constant d_f_cflag   : integer := 8;                -- d9: comma flag
  subtype  d_f_data   is integer range  7 downto  0;  -- d9: data field

  subtype  f_byte1    is integer range 15 downto 8;
  subtype  f_byte0    is integer range  7 downto 0;

  type txstate_type is (
    s_txidle,                           -- s_txidle: wait for ENA
    s_txsop,                            -- s_txsop: send sop
    s_txeop,                            -- s_txeop: send eop
    s_txcmd,                            -- s_txcmd: send cmd
    s_txal,                             -- s_txal: send addr lsb
    s_txah,                             -- s_txah: send addr msb
    s_txcl,                             -- s_txcl: send blk count lsb
    s_txch,                             -- s_txcl: send blk count msb
    s_txdl,                             -- s_txdl: send data lsb
    s_txdh,                             -- s_txdh: send data msb
    s_txcrcl1,                          -- s_txcrcl1: send cmd crc lsb in wblk
    s_txcrch1,                          -- s_txcrch1: send cmd crc msb in wblk
    s_txwbld,                           -- s_txwbld: wblk data load
    s_txwbdl,                           -- s_txwbdl: wblk send data lsb
    s_txwbdh,                           -- s_txwbdh: wblk send data msb
    s_txcrcl2,                          -- s_txcrcl2: send final crc lsb
    s_txcrch2                           -- s_txcrch2: send final crc msb
  );
  
  type txregs_type is record
    state : txstate_type;               -- state
    ccmd : slv3;                        -- current command
    snum : slv5;                        -- command sequence number
    crc : slv16;                        -- crc (cmd and data)
    braddr : slv16;                     -- block read address
    bdata : slv16;                      -- block data
    bloop : slbit;                      -- block loop flag
    tcnt : slv16;                       -- tcnt (down count for wblk)
    sopdone : slbit;                    -- sop send
    eoppend : slbit;                    -- eop pending
  end record txregs_type;

  constant txregs_init : txregs_type := (
    s_txidle,                           -- state
    "000",                              -- ccmd
    "00000",                            -- snum
    (others=>'0'),                      -- crc
    (others=>'0'),                      -- braddr
    (others=>'0'),                      -- bdata
    '0',                                -- bloop
    (others=>'0'),                      -- tcnt
    '0','0'                             -- sopdone, eoppend
  );

  type rxstate_type is (
    s_rxidle,                           -- s_rxidle: wait for ENA
    s_rxcmd,                            -- s_rxcmd: wait cmd
    s_rxcl,                             -- s_rxcl: wait cnt lsb
    s_rxch,                             -- s_rxcl: wait cnt msb
    s_rxbabo,                           -- s_rxbabo: wait babo
    s_rxdcl,                            -- s_rxdcl: wait dcnt lsb
    s_rxdch,                            -- s_rxdch: wait dcnt msb
    s_rxdl,                             -- s_rxdl: wait data lsb
    s_rxdh,                             -- s_rxdh: wait data msb
    s_rxstat,                           -- s_rxstat: wait status
    s_rxcrcl,                           -- s_rxcrcl: wait crc lsb
    s_rxcrch,                           -- s_rxcrch: wait crc msb
    s_rxapl,                            -- s_rxapl: wait attn pat lsb
    s_rxaph,                            -- s_rxaph: wait attn pat msb
    s_rxacl,                            -- s_rxapl: wait attn crc lsb
    s_rxach                             -- s_rxaph: wait attn crc msb
  );
  
  type rxregs_type is record
    state : rxstate_type;               -- state
    ccmd : slv3;                        -- current command
    crc : slv16;                        -- crc
    bwaddr : slv16;                     -- block write address
    data : slv16;                       -- received data
    dcnt : slv16;                       -- done count
    tcnt : slv16;                       -- tcnt (down count for rblk)
    ack : slbit;                        -- ack flag
    err : slbit;                        -- crc error flag
    stat : slv8;                        -- stat
    apend : slbit;                      -- attn pending
    ano : slbit;                        -- attn notify seen
    apat : slv16;                       -- attn pat
  end record rxregs_type;

  constant rxregs_init : rxregs_type := (
             s_rxidle,                  -- state
             "000",                     -- ccmd
             (others=>'0'),             -- crc
             (others=>'0'),             -- bwaddr
             (others=>'0'),             -- data
             (others=>'0'),             -- dcnt
             (others=>'0'),             -- tcnt
             '0','0',                   -- ack, err
             (others=>'0'),             -- stat
             '0','0',                   -- apend, ano
             (others=>'0')              -- attn pat
           );
  
  signal R_TXREGS : txregs_type := txregs_init;  -- TX state registers
  signal N_TXREGS : txregs_type := txregs_init;  -- TX next value state regs

  signal R_RXREGS : rxregs_type := rxregs_init;  -- RX state registers
  signal N_RXREGS : rxregs_type := rxregs_init;  -- RX next value state regs

  signal TXBUSY : slbit := '0';
  signal RXBUSY : slbit := '0';

  signal STAT_L : rlink_tba_stat_type := rlink_tba_stat_init; -- local, readable

begin
  
  proc_regs: process (CLK)
  begin

    if rising_edge(CLK) then
      if RESET = '1' then
        R_TXREGS <= txregs_init;
        R_RXREGS <= rxregs_init;
      else
        R_TXREGS <= N_TXREGS;
        R_RXREGS <= N_RXREGS;
      end if;
    end if;

  end process proc_regs;

  -- tx FSM ==================================================================
  
  proc_txnext: process (R_TXREGS, CNTL, DI, RL_BUSY)
    variable r : txregs_type := txregs_init;
    variable n : txregs_type := txregs_init;

    variable itxbusy : slbit := '0';
    variable icpdi : slv9 := (others=>'0');
    variable iena : slbit := '0';
    variable ibre : slbit := '0';
    variable do_crc : slbit := '0';

  begin

    r := R_TXREGS;
    n := R_TXREGS;

    itxbusy := '1';
    icpdi := (others=>'0');
    iena  := '0';
    ibre  := '0';
    do_crc := '0';

    if CNTL.eop='1' and r.state/= s_txidle then -- if eop requested and busy
      n.eoppend := '1';                           -- queue it
    end if;
    
    case r.state is
      when s_txidle =>                  -- s_txidle: wait for ENA ------------
        itxbusy := '0';
        if CNTL.ena = '1' then            -- cmd requested
          n.ccmd := CNTL.cmd;
          if CNTL.eop = '1' then            -- if eop requested with ENA
            n.eoppend := '1';                 -- queue it, eop after this cmd
          end if;
          if r.sopdone = '0' then           -- if not in active packet
            n.snum := (others=>'0');          -- set snum=0
            n.state := s_txsop;               -- send sop
          else
            n.state := s_txcmd;
          end if;
        else                              -- no cmd requested
          if CNTL.eop='1' and r.sopdone='1' then   -- if eop req and in packet
            n.state := s_txeop;                      -- send eop  
          end if;
        end if;
        
      when s_txsop =>                   -- s_txsop: send sop -----------------
        n.sopdone := '1';
        icpdi := c_rlink_dat_sop;
        iena  := '1';
        if RL_BUSY = '0' then
          n.crc   := (others=>'0');
          n.state := s_txcmd;
        end if;

      when s_txeop =>                   -- s_txeop: send eop -----------------
        n.sopdone := '0';
        n.eoppend := '0';
        icpdi := c_rlink_dat_eop;
        iena  := '1';
        if RL_BUSY = '0' then
          n.crc := (others=>'0');
          n.state := s_txidle;
        end if;

      when s_txcmd =>                   -- s_txcmd: send cmd -----------------
        n.tcnt   := CNTL.cnt;
        n.braddr := (others=>'0');
        icpdi(c_rlink_cmd_rbf_seq)  := r.snum;
        icpdi(c_rlink_cmd_rbf_code) := r.ccmd;
        iena := '1';
        if RL_BUSY = '0' then
          do_crc := '1';
          n.snum := slv(unsigned(r.snum) + 1);-- otherwise just increment snum
          case r.ccmd is
            when c_rlink_cmd_labo => n.state := s_txcrcl2; 
            when c_rlink_cmd_attn => n.state := s_txcrcl2; 
            when others => n.state := s_txal; 
          end case;
        end if;

      when s_txal =>                    -- s_txal: send addr lsb -------------
        icpdi := '0' & CNTL.addr(f_byte0);
        iena  := '1';
        if RL_BUSY = '0' then
          do_crc := '1';
          n.state := s_txah;
        end if;
        
      when s_txah =>                    -- s_txah: send addr msb -------------
        icpdi := '0' & CNTL.addr(f_byte1);
        iena  := '1';
        if RL_BUSY = '0' then
          do_crc := '1';
          case r.ccmd is
            when c_rlink_cmd_rreg => n.state := s_txcrcl2; 
            when c_rlink_cmd_rblk => n.state := s_txcl; 
            when c_rlink_cmd_wblk => n.state := s_txcl; 
            when others => n.state := s_txdl; 
          end case;
        end if;
        
      when s_txcl =>                    -- s_txcl: send blk count lsb -------
        icpdi := '0' & CNTL.cnt(f_byte0);
        iena  := '1';
        if RL_BUSY = '0' then
          do_crc := '1';
          n.state := s_txch;
        end if;
        
      when s_txch =>                    -- s_txch: send blk count msb -------
        icpdi := '0' & CNTL.cnt(f_byte1);
        iena  := '1';
        if RL_BUSY = '0' then
          do_crc := '1';
          if r.ccmd = c_rlink_cmd_wblk then
            n.state := s_txcrcl1;
          else
            n.state := s_txcrcl2;
          end if;
        end if;
        
      when s_txdl =>                    -- s_txdl: send data lsb -------------
        icpdi := '0' & DI(d_f_data);
        iena  := '1';
        if RL_BUSY = '0' then
          do_crc := '1';
          n.state := s_txdh;
        end if;
        
      when s_txdh =>                    -- s_txdh: send data msb -------------
        icpdi := '0' & DI(f_byte1);
        iena  := '1';
        if RL_BUSY = '0' then
          do_crc := '1';
          n.state := s_txcrcl2;
        end if;

      when s_txcrcl1 =>                 -- s_txcrcl1: send cmd crc lsb in wblk
        icpdi := '0' & r.crc(f_byte0);
        iena  := '1';
        if RL_BUSY = '0' then
          n.state := s_txcrch1;
        end if;

      when s_txcrch1 =>                 -- s_txcrch1: send cmd crc msb in wblk
        icpdi := '0' & r.crc(f_byte1);
        iena  := '1';
        if RL_BUSY = '0' then
          n.state := s_txwbld;
        end if;

      when s_txwbld =>                  -- s_txwbld: wblk data load ----------
                                        -- this state runs when s_wreg is 
                                        -- executed in rlink, thus doesn't cost
                                        -- an extra cycle in 2nd+ iteration.
        ibre     := '1';
        n.bdata  := DI;
        n.tcnt   := slv(unsigned(r.tcnt)   - 1);
        n.braddr := slv(unsigned(r.braddr) + 1);
        if unsigned(r.tcnt) = 1 then
          n.bloop := '0';
        else
          n.bloop := '1';
        end if;
        n.state := s_txwbdl;

      when s_txwbdl =>                  -- s_txwbdl: wblk send data lsb ------
        icpdi := '0' & r.bdata(f_byte0);
        iena  := '1';
        if RL_BUSY = '0' then
          do_crc := '1';
          n.state := s_txwbdh;
        end if;

      when s_txwbdh =>                  -- s_txwbdh: wblk send data msb ------
        icpdi := '0' & r.bdata(f_byte1);
        iena  := '1';
        if RL_BUSY = '0' then
          do_crc := '1';
          if r.bloop = '1' then
            n.state := s_txwbld;
          else
            n.state := s_txcrcl2;
          end if;
        end if;
        
      when s_txcrcl2 =>                 -- s_txcrcl2: send final crc lsb -----
        icpdi := '0' & r.crc(f_byte0);
        iena  := '1';
        if RL_BUSY = '0' then
          n.state := s_txcrch2;
        end if;
        
      when s_txcrch2 =>                 -- s_txcrch2: send final crc msb -----
        icpdi := '0' & r.crc(f_byte1);
        iena  := '1';
        if RL_BUSY = '0' then
          if r.eoppend = '1' or unsigned(r.snum)=31 then
            n.state := s_txeop;
          else
            n.state := s_txidle;
          end if;
        end if;
        
      when others => null;              -- <> --------------------------------
    end case;

    if do_crc = '1' then
      n.crc := crc16_update(r.crc, icpdi(d_f_data));
    end if;
    
    N_TXREGS <= n;

    TXBUSY   <= itxbusy;

    STAT_L.braddr <= r.braddr;
    STAT_L.bre    <= ibre;

    RL_DI  <= icpdi;
    RL_ENA <= iena;
    
  end process proc_txnext;

  -- rx FSM ==================================================================

  proc_rxnext: process (R_RXREGS, CNTL, RL_DO, RL_VAL)
    variable r : rxregs_type := rxregs_init;
    variable n : rxregs_type := rxregs_init;

    variable irxbusy : slbit := '0';
    variable ibwe : slbit := '0';
    variable do_crc : slbit := '0';
    variable ido : slv16 := (others=>'0');

  begin

    r := R_RXREGS;
    n := R_RXREGS;

    n.ack := '0';
    n.ano := '0';

    irxbusy := '1';
    ibwe := '0';
    do_crc := '0';
    ido := r.data;

    case r.state is
      when s_rxidle =>                  -- s_rxidle: wait --------------------
        n.crc := (others=>'0');
        n.err := '0';

        if RL_VAL = '1' then
          if RL_DO = c_rlink_dat_attn then -- attn seen ?
            n.state := s_rxapl;
          elsif RL_DO = c_rlink_dat_sop then
            n.state := s_rxcmd;
          end if;
        else
          irxbusy := '0';                  -- signal rx not busy
        end if;

      when s_rxcmd =>                   -- s_rxcmd: wait cmd  ----------------
       if RL_VAL = '1' then
          if RL_DO = c_rlink_dat_eop then
            n.state := s_rxidle;
          else
            n.bwaddr := (others=>'0');
            do_crc := '1';
            n.ccmd := RL_DO(n.ccmd'range);
            case RL_DO(n.ccmd'range) is
              when c_rlink_cmd_rreg => n.state := s_rxdl; 
              when c_rlink_cmd_rblk => n.state := s_rxcl; 
              when c_rlink_cmd_wreg => n.state := s_rxstat; 
              when c_rlink_cmd_wblk => n.state := s_rxdcl; 
              when c_rlink_cmd_labo => n.state := s_rxbabo; 
              when c_rlink_cmd_attn => n.state := s_rxdl; 
              when c_rlink_cmd_init => n.state := s_rxstat; 
              when others => null; 
            end case;
          end if;
       else
         irxbusy := '0';                  -- signal rx not busy
       end if;

      when s_rxcl =>                    -- s_rxcl: wait cnt lsb --------------
        if RL_VAL = '1' then
          do_crc := '1';
          n.tcnt(f_byte0) := RL_DO(d_f_data);
          n.state := s_rxch; 
        end if;

      when s_rxch =>                    -- s_rxch: wait cnt msb --------------
        if RL_VAL = '1' then
          do_crc := '1';
          n.tcnt(f_byte1) := RL_DO(d_f_data);
          n.state := s_rxdl;
        end if;

      when s_rxbabo =>                  -- s_rxbabo: wait babo ---------------
        if RL_VAL = '1' then
          do_crc := '1';
          n.data(15 downto 0) := (others=>'0');
          n.data(f_byte0) := RL_DO(d_f_data);
          n.state := s_rxstat;
        end if;

      when s_rxdl =>                    -- s_rxdl: wait data lsb -------------
        if RL_VAL = '1' then
          do_crc := '1';
          n.data(f_byte0) := RL_DO(d_f_data);
          n.state := s_rxdh;
        end if;
        
      when s_rxdh =>                    -- s_rxdh: wait data msb -------------
        if RL_VAL = '1' then
          do_crc := '1';
          n.data(f_byte1) := RL_DO(d_f_data);
          n.tcnt   := slv(unsigned(r.tcnt)   - 1);
          n.bwaddr := slv(unsigned(r.bwaddr) + 1);
          if r.ccmd = c_rlink_cmd_rblk then
            ido(f_byte1) := RL_DO(d_f_data);
            ibwe := '1';
          end if;
          if r.ccmd /= c_rlink_cmd_rblk then
            n.state := s_rxstat;
          elsif unsigned(r.tcnt) = 1 then
            n.state := s_rxdcl;
          else
            n.state := s_rxdl;
          end if;
        end if;

      when s_rxdcl =>                   -- s_rxdcl: wait dcnt lsb ------------
        if RL_VAL = '1' then
          do_crc := '1';
          n.dcnt(f_byte0) := RL_DO(d_f_data);
          n.state := s_rxdch;
        end if;
        
      when s_rxdch =>                   -- s_rxdch: wait dcnt msb ------------
        if RL_VAL = '1' then
          do_crc := '1';
          n.dcnt(f_byte1) := RL_DO(d_f_data);
          n.state := s_rxstat;
        end if;
        
      when s_rxstat =>                  -- s_rxstat: wait status -------------
        if RL_VAL = '1' then
          do_crc := '1';
          n.stat := RL_DO(d_f_data);
          n.apend := RL_DO(c_rlink_stat_rbf_attn); -- update attn status
          n.state := s_rxcrcl;
        end if;
        
      when s_rxcrcl =>                  -- s_rxcrcl: wait crc lsb ------------
        if RL_VAL = '1' then
          if r.crc(f_byte0) /= RL_DO(d_f_data) then
            n.err := '1';
          end if;
          n.state := s_rxcrch;
        end if;
        
      when s_rxcrch =>                  -- s_rxcrch: wait crc msb ------------
        if RL_VAL = '1' then
          if r.crc(f_byte1) /= RL_DO(d_f_data) then
            n.err := '1';
          end if;
          n.ack := '1';
          n.state := s_rxcmd;
        end if;

      when s_rxapl =>                   -- s_rxapl: wait attn pat lsb --------
        if RL_VAL = '1' then
          do_crc := '1';
          n.apat(f_byte0) := RL_DO(d_f_data);
          n.state := s_rxaph;
        end if;
        
      when s_rxaph =>                   -- s_rxaph: wait attn pat msb --------
        if RL_VAL = '1' then
          do_crc := '1';
          n.apat(f_byte1) := RL_DO(d_f_data);
          n.state := s_rxacl;
        end if;        

      when s_rxacl =>                   -- s_rxacl: wait attn crc lsb --------
        if RL_VAL = '1' then
          if r.crc(f_byte0) /= RL_DO(d_f_data) then
            n.err := '1';
          end if;
          n.state := s_rxach;
        end if;
        
      when s_rxach =>                   -- s_rxach: wait attn crc msb --------
        if RL_VAL = '1' then
          if r.crc(f_byte1) /= RL_DO(d_f_data) then
            n.err := '1';
          end if;
          n.ano := '1';
          n.state := s_rxidle;
        end if;
        
      when others => null;              -- <> --------------------------------
    end case;

    if do_crc = '1' then
      n.crc := crc16_update(r.crc, RL_DO(d_f_data));
    end if;
    
    N_RXREGS <= n;

    RXBUSY   <= irxbusy;

    DO   <= ido;
    STAT_L.stat   <= r.stat;
    STAT_L.ack    <= r.ack;
    STAT_L.err    <= r.err;
    STAT_L.bwaddr <= r.bwaddr;
    STAT_L.bwe    <= ibwe;
    STAT_L.dcnt   <= r.dcnt;
    STAT_L.apend  <= r.apend;
    STAT_L.ano    <= r.ano;
    STAT_L.apat   <= r.apat;
    
    RL_HOLD <= '0';
    
  end process proc_rxnext;

  STAT_L.busy <= RXBUSY or TXBUSY;
  STAT <= STAT_L;  

end syn;
